textureSize = this.textureSize;


%Open texture for drawing, sized to fit display, with object background color (users can set in .backColor, default = transparent).
%In openAtTrial instead of open cause textures Psychtoolbox holds can use
%significant memory, so only hold for each object during its trial instead of
%for all objects at same time at experiment startup.
n_texture = element_openTexture(textureSize);


this.n_texture = n_texture;