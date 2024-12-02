siz = this.size;
lineWidth = this.lineWidth;
color = this.color;


%Make object display on a texture

%Request object background color = transparent.
%Transparent version of cross color prevents artifacts if adjacent pixels are blended, e.g. if rotation.
c = [color 0];
this = element_setBackColor(this, c);

%Open texture for drawing, sized to fit display, background = object background color
n_texture = element_openTexture(siz);
textureCenter = (siz+1)/2;

%Draw display centered on texture using PTB DrawLines.
%Don't need smoothing input to DrawLines cause drawn horz/vert, so no blending.
coords = [
    textureCenter(1) textureCenter(1) 0                siz(1)
    0                siz(2)           textureCenter(2) textureCenter(2)
    ];
Screen('DrawLines', n_texture, coords, lineWidth, color);

%Static display with image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, n_texture);


this.n_texture = n_texture;