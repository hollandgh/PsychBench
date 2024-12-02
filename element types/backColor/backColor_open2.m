color = this.color;
windowSize = devices.screen.windowSize;


%Make object display as a texture.
%Open texture for drawing, sized to fit window, with specified background color.
n_texture = element_openTexture(windowSize, color);

%Static display with image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, n_texture);


this.n_texture = n_texture;