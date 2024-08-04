color = this.color;
textureSize = this.textureSize;


%Open texture for drawing, sized to fit display, with object background color (users can set in .backColor, default = transparent).
%In openAtTrial instead of open cause textures Psychtoolbox holds can use
%significant memory, so only hold for each object during its trial instead of
%for all objects at same time at experiment startup.
n_texture = element_openTexture(textureSize);

%If transparent object background, standard blend factors GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA will minimize dot edge artifacts at both background and dot overlaps.
%Alpha blending off (GL_ONE, GL_ZERO) for transparent background would give perfect edges at background but greater artifacts at overlaps.
%If user needs perfect at both they can set background = opaque in .backColor.
Screen('BlendFunction', n_texture, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');


this.n_texture = n_texture;