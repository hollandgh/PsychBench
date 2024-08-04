siz = this.size;
innerRadius = this.innerRadius;
radiusIncrement = this.radiusIncrement;
lineWidth = this.lineWidth;
color = this.color;


%Make object display on a texture.
%In openAtTrial instead of open cause textures Psychtoolbox holds can use
%significant memory, so only hold for each object during its trial instead of
%for all objects at same time at experiment startup.

%Open texture for drawing, sized to fit display, with object background color (users can set in .backColor, default = transparent)
n_texture = element_openTexture(siz);
        
%PTB DrawLines with antialiasing on and maybe overlapping lines requires alpha blending to minimize edge transparency artifacts.
%If user needs perfect they can set this.backColor = opaque.
Screen('BlendFunction', n_texture, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

textureCenter = (siz+1)/2;


%Number of circles outside inner circle to draw to fill area, based on diagonal of area
numOuterCircles = floor((sum(siz.^2)^(1/2)/2-innerRadius)/radiusIncrement);
%Radii of all circles including inner
radii = innerRadius+(0:numOuterCircles)*radiusIncrement;
%Rects of all circles
rects = [repmat(-radii, 2, 1); repmat(+radii, 2, 1)]+repmat(transpose(textureCenter), 2, numOuterCircles+1);
%Approx compensate for PTB bug (?) that circle "pen width" seem to be ~1.4x larger than line width
w = max(round(0.7*lineWidth), 1);

%Draw circles centered on texture using PTB FrameOval
Screen('FrameOval', n_texture, color, rects, w)


%Draw lines centered on texture using PTB DrawLines.
%Enable antialiasing (smoothing).
r = siz(1)/2;
lineCoords = [
    -r +r -r +r
    -r +r +r -r
    ]+repmat(transpose(textureCenter), 1, 4);
Screen('DrawLines', n_texture, lineCoords, lineWidth, color, [], 1);


%We have first image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, n_texture);


this.n_texture = n_texture;