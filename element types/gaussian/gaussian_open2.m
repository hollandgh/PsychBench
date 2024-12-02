sigma = this.sigma;
siz = this.size;
color = this.color;


%Make display data.
%Maybe slow, so encapsulate in a function and do shared so only computes once 
%for all objects of this type with the same function input values.
%---
data = element_doShared(@makeDisplayData, sigma, siz, color);
%---


%Convert image data to texture
n_texture  = element_openTexture([], [], data);

%Static display with image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, n_texture);


this.n_texture = n_texture;


%end script




function data = makeDisplayData(sigma, siz, color) %local function


if isempty(siz)
    siz = 6*sigma;
end

%Get coordinate grid xx, yy (px).
%Center coordinate grid about 0 for perfect symmetry about center.
r = round(siz)/2;
[xx, yy] = meshgrid(-r(1):r(1), -r(2):r(2));

%Alpha channel = Gaussian 0-1 centered on coordinate grid
alpha = exp(-(xx.^2/(2*sigma(1)^2) + yy.^2/(2*sigma(2)^2)));

%Constant color.
%Prevents artifacts if adjacent pixels are blended, e.g. if rotation.
color = repmat(reshape(color, [1 1 3]), size(xx));

data = cat(3, color, alpha);

    
end %makeDisplayData