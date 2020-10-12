% Reconstruction script for the paper:
%
% Ziwei Zhao*, Yongwan Lim*, Dani Byrd, Shrikanth Narayanan, 
% Krishna S. Nayak. "Improved 3D Real-Time MRI of Speech Production".
%
% This code performs a constrained reconstruction for dynamic 3D images.
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

addpath('../Improved_3DRT_Speech/recon/functions');    % please change the path
directory = '../Improved_3DRT_Speech/';                % please change the path
outdirectory = 'results/';
fileInfo = dir(strcat(directory, 'data/3d_*'));
index = {'ori','vd'};

for i  =  1 : length(fileInfo)

    cd(strcat(directory, 'data/' , fileInfo(i).name, '/')); 
    file = dir(strcat('lac10132019_','*.mat'));
    
    param.imsize       = [84 84 12];  
    param.narms        = 1;     % number of arms per kx-ky plane to use
    param.slices2recon = 1:12;  % slices to reconstruct (1st slice has low SNR so it'd be better not to recon)
    param.coil2recon   = 1:8;   % coil dimensions 
    param.cfreq        = 0;     % center frequency 
    param.lambda_sTV   = 0.008; % parameter for spatial TV
    param.lambda_tTV   = 0.03;  % parameter for temporal TV
    param.niter        = 300;   % number of iteration in BART recon
    param.admm_rho     = 0.05;  % ADMM parameter
    param.TR           = 5.048/1000; % [ms]
    param.folder_index = i;
    param.tempwin      = 12;    % number of spiral arms per time point
    param.windowsize   = 100;   % number of time frames for one reconstruction
     
    %% Reconstruction 
    matfname = fullfile(file.folder, file.name);                     

    [recon, coilmap, reconInfo] = recon_sos_3d(matfname, param);

    %% Save results
    suffix = sprintf('3d_%s_Nt%d_TRs%d_rt%.5f_rs%.5f_frames%d_niter%d', ...
    index{i}, reconInfo.nframes, reconInfo.temp_win, reconInfo.lambda_tTV, reconInfo.lambda_sTV, reconInfo.windowsize, reconInfo.niter);
     
    [pathstr, name, ext] = fileparts(matfname);
    
    outpath  = strcat(directory, outdirectory, fileInfo(i).name, '/'); 
    mkdir(outpath); cd(outpath); 
    volfname = strcat(name, '_', suffix);
    volfname = strcat(outpath, volfname);

    save(strcat(volfname,'.mat'), 'recon', 'coilmap', 'reconInfo');

    %% Generate parallel sagittal views video
    display4Dimages(strcat(volfname,'.avi'), recon(:,:,1:12,:), 1/(reconInfo.temp_win*reconInfo.TR), 0, 4, 3);
    cd(directory);
    
end


