shape = this.shape;
siz = this.size;
sigma = this.sigma;
backSize = this.backSize;
color = this.color;


    %Make display texture
if      any(strcmpi(shape, {'square' 'rectangle'}))
    %Open texture for drawing, sized to fit display, with background = mask color.
    %Turn off alpha blending, Turn on writing to all channels.
    n_texture = element_openTexture(backSize, color, [], 'GL_ONE', 'GL_ZERO', [1 1 1 1]);

    %Replace pixels with transparent aperture centered on texture using PTB FillRect.
    %Transparent version of surround color prevents artifacts if adjacent pixels are blended, e.g. if rotation.
    rect = [0 0 siz]+repmat(-(siz+1)/2+(backSize+1)/2, 1, 2);
    Screen('FillRect', n_texture, [color 0], rect)
    
elseif  any(strcmpi(shape, {'circle' 'oval'}))
    n_texture = element_openTexture(backSize, color, [], 'GL_ONE', 'GL_ZERO', [1 1 1 1]);

    rect = [0 0 siz]+repmat(-(siz+1)/2+(backSize+1)/2, 1, 2);
    Screen('FillOval', n_texture, [color 0], rect)
    
elseif  strcmpi(shape, 'gaussian')
    %Make Gaussian display data.
    %Maybe slow, so encapsulate in a function and do shared so only computes once 
    %for all objects of this type with the same function input values.
    gaussianData = element_doShared(@makeGaussianDisplayData, sigma, backSize, color);
    
    %Convert image data made in _open to texture
    n_texture  = element_openTexture([], [], gaussianData);
    
end

%Static display with image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, n_texture);


this.n_texture = n_texture;


%end script




function data = makeGaussianDisplayData(sigma, backSize, color) %local function


%Get coordinate grid xx, yy (px).
%Center coordinate grid about 0 for perfect symmetry about center.
r = round(backSize)/2;
[xx, yy] = meshgrid(-r(1):r(1), -r(2):r(2));

%Alpha channel = negative Gaussian 0-1 centered on coordinate grid
alpha = 1-exp(-(xx.^2/(2*sigma(1)^2) + yy.^2/(2*sigma(2)^2)));

%Constant color.
%Prevents artifacts if adjacent pixels are blended, e.g. if rotation.
color = repmat(reshape(color, [1 1 3]), size(xx));

data = cat(3, color, alpha);

    
end %makeGaussianDisplayData