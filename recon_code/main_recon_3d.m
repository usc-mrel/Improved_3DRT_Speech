% Improved_3DRT_SOSP_Speech.m
%
%
% Created by:   Yongwan Lim
% Modified by:  Ziwei Zhao
% Emails:       yongwanl@usc.edu
%               ziweiz@usc.edu
%
%                    06/07/2020

clear all; 
close all; 
clc;

directory = '/Users/zhaoziwei/Documents/MATLAB/3D RT Ziwei/demo/';
outdirectory = 'results/';
fileInfo = dir(strcat(directory, 'data/3d_*'));
index = {'ori','vd'};

for i  =  1 : 2  

    cd(strcat(directory, 'data/' , fileInfo(i).name, '/')); 
    file = dir(strcat('lac10132019_','*ed.mat'));
    
    param.imsize       = [84 84 12];  
    param.narms        = 1;     % number of arms per kx-ky plane to use
    param.slices2recon = 1:12;  % slices to reconstruct (1st slice has low SNR so it'd be better not to recon)
    param.coil2recon   = 7; % 1:8; 
    param.cfreq        = 0;     % center frequency 
    param.lambda_sTV   = 0.008; 
    param.lambda_tTV   = 0.03;  
    param.niter        = 5;     % number of iteration in BART recon
    param.admm_rho     = 0.05;  % ADMM parameter
    param.TR           = 5.048/1000;
    param.folder_index = i;
    param.tempwin      = 12;    % number of spiral arms per time point
    param.windowsize   = 50;    % number of time frames for one reconstruction
     
    %% Reconstruction 
    matfname = fullfile(file.folder, file.name);                     

   [recon, coilmap, reconInfo] = recon3dsos_3d(matfname, param);

    %% Save results
    suffix = sprintf('3d_%s_Nt%d_TRs%d_rt%.5f_rs%.5f_frames%d_niter%d', ...
    index{i}, reconInfo.nframes, reconInfo.temp_win, reconInfo.lambda_tTV, reconInfo.lambda_sTV, reconInfo.windowsize, reconInfo.niter);
     
    [pathstr, name, ext] = fileparts(matfname);
    outpath  = strcat(directory, outdirectory, fileInfo(i).name, '/'); cd(outpath); 
    volfname = strcat(name, '_', suffix);
    volfname = strcat(outpath, volfname);

    save(strcat(volfname,'.mat'), 'recon', 'coilmap', 'reconInfo');

    %% Generate parallel sagittal views video
    f_disp4D(strcat(volfname,'.avi'), recon(:,:,1:12,:), 1/(reconInfo.temp_win*reconInfo.TR), 0, 4, 3);
    cd(directory);
    
end


