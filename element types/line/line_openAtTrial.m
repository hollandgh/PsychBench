widths = this.width;
colors = this.color;
points_texture = this.points_texture;
textureSize = this.textureSize;
centerOffset = this.centerOffset;


%Make object display on a texture...
%In openAtTrial instead of open cause textures Psychtoolbox holds can use
%significant memory, so only hold for each object during its trial instead of
%for all objects at same time at experiment startup.

%Open texture for drawing, sized to fit display, with object background color (users can set in .backColor, default = transparent)
n_texture = element_openTexture(textureSize);

%If transparent object background, standard blend factors GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA will minimize line edge artifacts at both background and line overlaps.
%Alpha blending off (GL_ONE, GL_ZERO) for transparent background would give perfect edges at background but greater artifacts at overlaps.
%If user needs perfect at both they can set background = opaque in .backColor.
Screen('BlendFunction', n_texture, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%Draw display centered on texture using PTB DrawLines
Screen('DrawLines', n_texture, points_texture, widths, colors, [], 1);

%We have first image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, n_texture, [], [], centerOffset);


this.n_texture = n_texture;