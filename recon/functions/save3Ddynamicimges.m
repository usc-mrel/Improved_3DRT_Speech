function result = save3Ddynamicimges (img, rot_angle, num_col, num_row)

% Converts the 3D dynamic images (x-y-z-t) to concatenated display of 2D image series
% (x-y-t) with specified rotated angle, columns and rows
%
% Inputs:   
%         img:  3D image series with x-y-z-t dimensions
%   rot_angle:  rotated angle of the images
%     num_col:  number of columns in the concatenated display of z dimension
%     num_row:  number of rows in the concatenated display of z dimension
% Output:
%      result:  2D concatenated image series


nframes = size(img,4);
result = zeros(size(img,1)*num_row, size(img,2)*num_col,nframes);
for t=1:nframes
    result(:,:,t) =f_save_3d_static_img(img(:,:,:,t), rot_angle, num_col, num_row);
end
