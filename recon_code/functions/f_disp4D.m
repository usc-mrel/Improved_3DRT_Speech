function f_disp4D(fname, recon, framerate, angle, num_col, num_row)

% ZYH, 04/27/2015

% directory + file name
% datafname = strcat(pwd, '/', fname);
datafname = fname;
% load(datafname, '*');

recon_cs = abs(recon)/max(abs(recon(:)));
imt = (1/1.75);
recon_cs(recon_cs>imt) =imt;
recon_cs = recon_cs./max(recon_cs(:)) .* 1 ; % 0.75
        
im4D = abs(recon);
im4D = permute(im4D,[1 2 4 3]); % move time dim to 3rd dim
%for zz=1:size(im4D,4)
%    temp = im4D(:,:,:,zz);
%    temp2 = temp./max(temp(:));
%    temp2(temp2>imt) = imt;
%    im4D(:,:,:,zz) = temp2;
%end

% montage(im4D(:,:,1,:));
% myMontage = getframe(gca);
% ims = zeros([size(myMontage.cdata,1), size(myMontage.cdata,2), size(im4D,3)]);

for n_frame = 1:size(im4D,3)
    im3D = im4D(:,:,n_frame,:);
%     for n_z = 1:size(im4D,4)
%         im3D(:,:,1,n_z) = rot90(im3D(:,:,1,n_z),1);
%     end
    
    if size(im4D,4) == 16
        ims(:,:,n_frame) = from16(im3D);
    elseif size(im4D,4) == 20
        ims(:,:,n_frame) = from20(im3D);
    else
        ims(:,:,n_frame)= f_save_3d_static_img(squeeze(im3D), angle, num_col, num_row);
%         % hard code the half max
%         h = montage(im3D, 'DisplayRange',[0 max(abs(im3D(:)))/2]);
%         ims(:,:,n_frame) = h.CData;
    end
end
% close all;

% hard code
% imceil=0.025;
% ims(ims>imceil)=imceil;
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


