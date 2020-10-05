function result = save3Dstaticimges (img, rot_angle, num_col, num_row)

% Converts the 3D static images (x-y-z) to concatenated display of 2D image series
% with specified rotated angle, columns and rows
%
% Inputs:   
%         img:  3D images with x-y-z dimensions
%   rot_angle:  rotated angle of the images
%     num_col:  number of columns in the concatenated display of z dimension
%     num_row:  number of rows in the concatenated display of z dimension
% Output:
%      result:  2D concatenated images 


result = [];

for bb=1:num_row
    concat_ver = [];
    for aa=1:num_col
        slice_idx = aa+(bb-1)*num_col;
        concat_ver = [concat_ver imrotate(squeeze(img(:,:,slice_idx)),rot_angle)];
    end
    result = [result; concat_ver];
end
end
