function f_genV(ims, name, framerate)

% Generate a video from image series
% Inputs:
%   ims:    images
%   name:   output video name
%   framerate: frame rate


ims = abs(squeeze(ims));
ims = (ims-min(ims(:)))/(max(ims(:))-min(ims(:)));

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
