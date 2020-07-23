function result = f_save_3d_dynamic_img (img, rot_angle, num_col, num_row)

nframes = size(img,4);
result = zeros(size(img,1)*num_row, size(img,2)*num_col,nframes);
for t=1:nframes
    result(:,:,t) =f_save_3d_static_img(img(:,:,:,t), rot_angle, num_col, num_row);
end