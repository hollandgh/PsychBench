sizes = this.size;
colors = this.color;
type = this.type;
positions_texture = this.positions_texture;
textureSize = this.textureSize;
centerOffset = this.centerOffset;


%Make object display on a texture...
%In openAtTrial instead of open cause textures Psychtoolbox holds can use
%significant memory, so only hold for each object during its trial instead of
%for all objects at same time at experiment startup.

%Open texture for drawing, sized to fit display, with object background color (users can set in .backColor, default = transparent)
n_texture = element_openTexture(textureSize);

%Draw display centered on texture using PTB DrawDots
Screen('DrawDots', n_texture, positions_texture, sizes, colors, [], type);

%We have first image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, n_texture, [], [], centerOffset);


this.n_texture = n_texture;