shape = this.shape;
siz = this.size;
backSize = this.backSize;
color = this.color;
gaussianData = this.gaussianData;


    %Make display texture.
    %In openAtTrial instead of open cause textures Psychtoolbox holds can use
    %significant memory, so only hold for each object during its trial instead of
    %for all objects at same time at experiment startup.
if      any(strcmpi(shape, {'square' 'rectangle'}))
    %Open texture for drawing, sized to fit display, with background = mask color
    n_texture = element_openTexture(backSize, color);

    %Turn off alpha blending, Turn on writing to all channels
    Screen('BlendFunction', n_texture, 'GL_ONE', 'GL_ZERO', [1 1 1 1]);

    %Replace pixels with transparent aperture centered on texture using PTB FillRect
    rect = [0 0 siz]+repmat(-(siz+1)/2+(backSize+1)/2, 1, 2);
    Screen('FillRect', n_texture, [0 0 0 0], rect)
    
elseif  any(strcmpi(shape, {'circle' 'oval'}))
    n_texture = element_openTexture(backSize, color);

    Screen('BlendFunction', n_texture, 'GL_ONE', 'GL_ZERO', [1 1 1 1]);

    rect = [0 0 siz]+repmat(-(siz+1)/2+(backSize+1)/2, 1, 2);
    Screen('FillOval', n_texture, [0 0 0 0], rect)
    
elseif  strcmpi(shape, 'gaussian')
    %Convert image data made in _open to texture
    n_texture  = element_openTexture([], [], gaussianData);
    
end

%We have first image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, n_texture);


this.n_texture = n_texture;