% 3D stack of spirals (pseudo golden-angle in kx-ky and Cartesian kz) reconstuction 
% Constrained reconstruction based on compressed sensing and parallel imaging
% with spatio-temporal TV constraints 
%
% Make dynamic 3D volume after reconstructing 3D data
%
% use BART reconstruction tool (v4.03) 
%
% Created by 
%             Yongwan Lim   yongwanl@usc.edu
% 
% Modified by 
%             Ziwei Zhao    ziweiz@usc.edu
%  
%                            06/07/2020

function [Recon, coilmap, reconInfo] = recon_sos_3d(matfname, param)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    imsize        = param.imsize;       % image size [nx ny nz]
    windowsize    = param.windowsize;   % # of time frames for one recon
    slices2recon  = param.slices2recon; % slices to reconstruct 
    coil2recon    = param.coil2recon;   % coil elementes to use
    cfreq         = param.cfreq;        % freq on which to demodulate k-space data based   

    lambda_sTV    = param.lambda_sTV;
    lambda_tTV    = param.lambda_tTV;   
    niter         = param.niter; 
    admm_rho      = param.admm_rho;
    folder_index  = param.folder_index;  
    temp_win      = param.tempwin;

    TR            = param.TR;
    TE            = 0.45/1000;           
    Ts            = 4e-6;

    HanningSize   = [31 31 5];
    displayFigure = false;

    % Set up BART library
    cur_dir = pwd;
    base_dir = ['/Users/' getenv('USER')];
    bart_dir = [base_dir '/Documents/MATLAB/bart-0.4.03']; % change this baesd on your installation
    cd(bart_dir); 
    startup; 
    cd(cur_dir);

    load(matfname); % Load mat file    

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Coil calibration w/ fully sampled time-averaged data 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Coil Map Estimation\n');

    T0 = tic;

    nsprials = size(kdata,2) - 1;
    nc       = size(kdata,3);    % # of coil elements
    ns       = size(kdata,1);    % # of data samples per spiral

    kdata3DT = zeros([1, size(w,1), nsprials, nc, 1, 1]);
    kloc3DT  = zeros([3, size(w,1), nsprials, 1,  1, 1]);
    w3DT     = zeros([1, size(w,1), nsprials, 1,  1, 1]);

    for n_frame = 1:1
        kloc_temp  = kloc(:, (n_frame-1)*nsprials+1:n_frame*nsprials, :);
        kloc3DT(:,:,:,1,1,n_frame) = permute( kloc_temp,[3 1 2]);
        w3DT(1,:,:,1,1,n_frame) = w(:, (n_frame-1)*nsprials+1:n_frame*nsprials);    
        kdata3DT(1,:,:,:,1,n_frame) = kdata(:, (n_frame-1)*nsprials+1:n_frame*nsprials, :);
    end

    kloc3DT(1,:) = kloc3DT(1,:)*imsize(1);
    kloc3DT(2,:) = kloc3DT(2,:)*imsize(2);
    kloc3DT(3,:) = kloc3DT(3,:)*imsize(3);

    % time-averaged 3D image
    ta3dimg = bart(sprintf('nufft -a -d %d:%d:%d -t',imsize(1),imsize(2),imsize(3)),kloc3DT,kdata3DT.*repmat(w3DT, [1 1 1 nc]));

    if displayFigure
        sos_ta3dimg = sqrt(sum(abs(ta3dimg).^2,4));
        sos_ta3dimg_display = f_save_3d_dynamic_img(double(sos_ta3dimg), 90, 4, 3);
        figure(100), imagesc(abs(sos_ta3dimg_display)), axis image off; colormap('gray');
    end

    window = generatewindows(HanningSize, 3); % 3D Hanning filter

    % time-averaged low-res 3D image
    talr3dimg = convn(ta3dimg, window, 'same'); % Smoothed by convolution with a 3D filter

    talr3dksp = bart('fft -u 7', talr3dimg);    % 3DFT to get kspace

    talr3dksp_zpz ...                           % zeropad along z-direction
        = bart(sprintf('resize -c 0 %d 1 %d 2 %d', imsize(1), imsize(2), imsize(3)*2), talr3dksp);
    coilmap = bart('ecalib -S -m1', talr3dksp_zpz);
    coilmap = (coilmap(:,:,1:2:end,:) +coilmap(:,:,2:2:end,:))/2;

    if displayFigure
        coilmap_display = save3Ddynamicimages(coilmap, 90, 8, 3);
        for cc = 1:nc
            figure(100+cc);
            imagesc(abs(coilmap_display(:,:,cc))), axis image off; colormap('gray');
            title(sprintf('Coil sensitivity: %d',cc)); caxis([0 max(abs(coilmap_display(:)))*0.8]);
        end
    end

    T = toc(T0);
    fprintf('Coil Map Estimation Done: %f s\n', T);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Preparation for Reconstruction
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Data Preparation for Reconstruction\n');    
    T0 = tic;

    % Find the first kz index at the bottom
    if folder_index == 1        % original method
        first_bottom_z_idx = find(kloc(1,:,3) == -0.5);
        first_bottom_z_idx = first_bottom_z_idx(1) - 1;
    else 
        first_bottom_z_idx = 0; % proposed method
    end

    max_nframes = floor((size(kdata,2)-first_bottom_z_idx)/temp_win);    
    nframes = windowsize; 

    if mod(max_nframes,nframes) ~= 0
        cat_num = floor(max_nframes/nframes) + 1; 
    else 
        cat_num = max_nframes/nframes;
    end
    nframes_end = mod(max_nframes, nframes);

    kdata3DT = zeros([1, ns, temp_win, nc, 1, max_nframes]);
    kloc3DT  = zeros([3, ns, temp_win, 1,  1, max_nframes]);
    w3DT     = zeros([1, ns, temp_win, 1,  1, max_nframes]);

    for n_frame = 1 : max_nframes    

        t_idx = (n_frame-1) * temp_win + 1 : n_frame * temp_win;

        if folder_index == 1 
            t_idx = t_idx + first_bottom_z_idx; 
        end

        kloc_temp  = kloc(:, t_idx, :);
        kloc3DT(:,:,:,1,1,n_frame) = permute( kloc_temp,[3 1 2]);
        w3DT(1,:,:,1,1,n_frame) = w(:, t_idx);    
        kdata3DT(1,:,:,:,1,n_frame) = kdata(:, t_idx, :);
    end

    kloc3DT(1,:) = kloc3DT(1,:)*imsize(1);
    kloc3DT(2,:) = kloc3DT(2,:)*imsize(2);
    kloc3DT(3,:) = kloc3DT(3,:)*imsize(3);

    % Adjust center frequency
    tad = ns*Ts;
    t = TE + [0:ns-1]*tad/ns;

    % demodulate k-space data
    temp = squeeze(kdata3DT).*repmat(exp(1i*2*pi*cfreq*t'), 1, temp_win, nc, max_nframes);
    kdata3DT(1,:,:,:,1,:) = temp;
    kdata2DTslices = bart('fft -i -u 4',kdata3DT); % inverse FT along kz 

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Recon = zeros(imsize(1),imsize(2),imsize(3),max_nframes);

    for ij = 1 : cat_num
        if ij == 1
           ttt = 1 : nframes + 2; 
           ddd = 1 : nframes; 
        end
        if ij > 1 && ij < cat_num 
           ttt = (ij-1) * nframes -1 : ij * nframes + 2;
           ddd = (ij-1) * nframes +1 : ij * nframes;
        end
        if ij == cat_num
            if mod(max_nframes,nframes) ~= 0
               ttt = (max_nframes - nframes_end) - 1 : max_nframes;
               ddd = (max_nframes - nframes_end) + 1 : max_nframes;
            else               
               ttt = (ij-1) * nframes -1 : ij * nframes;
               ddd = (ij-1) * nframes +1 : ij * nframes;
            end
        end
        if cat_num == 1
             ttt = 1 : nframes; 
             ddd = 1 : nframes; 
        end

        kdata3DT_input  = kdata3DT(:,:,:,coil2recon,:,ttt);
        kloc3DT_input   = kloc3DT(:,:,:,:,:,ttt);  
        w3DT_input      = w3DT(:,:,:,:,:,ttt);
        coilmap_input   = coilmap(:,:,:,coil2recon);

        weight_name = ['./weight']; 
        writecfl(weight_name, (w3DT_input));
        T0 = tic;
        T = toc(T0);
        fprintf('Data Preparation Done: %f s\n', T);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3D Reconstruction
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        fprintf('3D Reconstruction\n');
        fprintf('[nx ny nz nt] = [%d %d %d %d]\n', imsize(1), imsize(2), imsize(3), nframes);
        bart_cmd = sprintf('pics -S -d4 -u%f -RT:7:0:%f -R T:32:0:%f -i%d -p %s -t', admm_rho, lambda_sTV, lambda_tTV, niter, weight_name); 
        disp(bart_cmd);

        T0 = tic; 

        temp  = bart(bart_cmd, kloc3DT_input, kdata3DT_input, coilmap_input);
        recon = squeeze(temp);

        for zz=1:size(recon,3)
            for tt=1:size(recon,4)
                recon(:,:,zz,tt) = imrotate(recon(:,:,zz,tt),90); 
            end
        end

        if displayFigure      
            figure(110),
            for tt=1:size(recon,4)
                imagesc(abs(recon(:,:,7,tt))); colormap gray; axis image off;    
                title(tt); drawnow;
            end
        end

        if cat_num > 1
            if ij == 1
              recon = recon(:, :, :, 1 : end-2);   
            end
            if ij > 1 && ij < cat_num
               recon = recon(:, :, :, 3 : end-2);
            end
            if ij == cat_num
               recon = recon(:, :, :, 3 : end);
            end
        end

        Recon(:,:,:,ddd) = recon; 


        T = toc(T0);
        fprintf('Reconstruction Done: %f s\n', T);
    end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate reconstruction header    
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [pathstr, name, ext]      = fileparts(matfname);

    reconInfo                 = struct('Date', date, 'Fname', name, 'recon_method','BART (v4.03) pics', 'recon_time',T);

    reconInfo.cmap_method     = 'Espirit';
    reconInfo.imsize          = imsize;       % image size [nx ny nz]
    reconInfo.nframes         = max_nframes;

    reconInfo.slices2recon    = slices2recon; % slices to reconstruct 
    reconInfo.coil2recon      = coil2recon;   % coil elementes to use

    reconInfo.bart_cmd        = bart_cmd;
    reconInfo.HanningSize     = HanningSize; 
    reconInfo.cfreq           = cfreq;        % freq on which to demodulate k-space data based   
    reconInfo.lambda_sTV      = lambda_sTV;
    reconInfo.lambda_tTV      = lambda_tTV;
    reconInfo.temp_win        = temp_win;
    reconInfo.niter           = niter; 
    reconInfo.admm_rho        = admm_rho;
    reconInfo.windowsize      = windowsize;

    reconInfo.TR              = TR;
    reconInfo.TE              = TE;
    reconInfo.Ts              = Ts;

    disp('Reconstruction is done now');

end
