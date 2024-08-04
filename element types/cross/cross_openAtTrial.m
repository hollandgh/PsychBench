siz = this.size;
lineWidth = this.lineWidth;
color = this.color;


%Make object display on a texture.
%In openAtTrial instead of open cause textures Psychtoolbox holds can use
%significant memory, so only hold for each object during its trial instead of
%for all objects at same time at experiment startup.

%Open texture for drawing, sized to fit display, with object background color (users can set in .backColor, default = transparent)
n_texture = element_openTexture(siz);
textureCenter = (siz+1)/2;

%Draw display centered on texture using PTB DrawLines.
%Don't need smoothing input to DrawLines cause drawn horz/vert.
coords = [
    textureCenter(1) textureCenter(1) 0                siz(1)
    0                siz(2)           textureCenter(2) textureCenter(2)
    ];
Screen('DrawLines', n_texture, coords, lineWidth, color);

%We have first image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, n_texture);


this.n_texture = n_texture;