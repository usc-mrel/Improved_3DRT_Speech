function f_genV(ims, name, framerate)

% genMP4(ims, name, range)
%
% Generate mp4 from image series, such as for DCE
% Inputs:
%   ims:    images
%   name:   output video name
%   framerate: frame rate
%
% ZYH, 07/23/2014

ims = abs(squeeze(ims));

ims = (ims-min(ims(:)))/(max(ims(:))-min(ims(:)));
% for n_im = 1:size(ims,3)
%     im = ims(:,:,n_im);
%     ims(:,:,n_im) = ims(:,:,n_im)/max(im(:));
% end

if ndims(ims) ~= 3
    error('ERROR: Wrong data dimension');
end
nims = size(ims,3);
ims = permute(ims, [1 2 4 3]);

if nargin<3, framerate=nims/10; end  % 10 sec of video
if nargin<2, name = 'unNamed'; end

writerObj = VideoWriter(name,'Motion JPEG AVI');
writerObj.FrameRate = framerate;
open(writerObj);
writeVideo(writerObj,ims);
close(writerObj);