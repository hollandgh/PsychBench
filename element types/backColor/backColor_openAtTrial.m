color = this.color;
windowSize = devices.screen.windowSize;


%Make object display on a texture.
%In openAtTrial instead of open cause textures Psychtoolbox holds can use
%significant memory, so only hold for each object during its trial instead of
%for all objects at same time at experiment startup.
%Open texture for drawing, sized to fit window, with specified background color.
n_texture = element_openTexture(windowSize, color);

%We have first image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, n_texture);


this.n_texture = n_texture;