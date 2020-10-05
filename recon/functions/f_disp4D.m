function f_disp4D(fname, recon, framerate, angle, num_col, num_row)

% Generate an avi video from 3D image series with concatenated display of slice dimension
% Inputs:
%        ims:  3D dynamic images
%      fname:  output video name
%  framerate:  frame rate
%      angle:  specified rotated angle of displayed images 
%    num_col:  number of columns in the concatenated display of slice dimension
%    num_row:  number of rows in the concatenated display of slice dimension


datafname = fname;

recon_cs = abs(recon)/max(abs(recon(:)));
imt = (1/1.75);
recon_cs(recon_cs>imt) =imt;
recon_cs = recon_cs./max(recon_cs(:)) .* 1 ;
        
im4D = abs(recon);
im4D = permute(im4D,[1 2 4 3]); % move time dim to 3rd dim

for n_frame = 1:size(im4D,3)
    im3D = im4D(:,:,n_frame,:); 
    if size(im4D,4) == 16
        ims(:,:,n_frame) = from16(im3D);
    elseif size(im4D,4) == 20
        ims(:,:,n_frame) = from20(im3D);
    else
        ims(:,:,n_frame)= f_save_3d_static_img(squeeze(im3D), angle, num_col, num_row);
    end
end

videoname2 = strcat(datafname(1:end-4),'.avi');
f_genV(ims, videoname2, framerate);

end

function ims = from16(im3D)
    im1 = cat(2, im3D(:,:,1,1), im3D(:,:,1,2), im3D(:,:,1,3), im3D(:,:,1,4));
    im2 = cat(2, im3D(:,:,1,5), im3D(:,:,1,6), im3D(:,:,1,7), im3D(:,:,1,8));
    im3 = cat(2, im3D(:,:,1,9), im3D(:,:,1,10), im3D(:,:,1,11), im3D(:,:,1,12));
    im4 = cat(2, im3D(:,:,1,13), im3D(:,:,1,14), im3D(:,:,1,15), im3D(:,:,1,16));
    ims = cat(1, im1, im2, im3, im4);
end

function ims = from20(im3D)
    im1 = cat(2, im3D(:,:,1,1), im3D(:,:,1,2), im3D(:,:,1,3), im3D(:,:,1,4), im3D(:,:,1,5));
    im2 = cat(2, im3D(:,:,1,6), im3D(:,:,1,7), im3D(:,:,1,8), im3D(:,:,1,9), im3D(:,:,1,10));
    im3 = cat(2, im3D(:,:,1,11), im3D(:,:,1,12), im3D(:,:,1,13), im3D(:,:,1,14), im3D(:,:,1,15));
    im4 = cat(2, im3D(:,:,1,16), im3D(:,:,1,17), im3D(:,:,1,18), im3D(:,:,1,19), im3D(:,:,1,20));
    ims = cat(1, im1, im2, im3, im4);
end


