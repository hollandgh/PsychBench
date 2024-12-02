global GL


siz = this.size;
innerRadius = this.innerRadius;
radiusIncrement = this.radiusIncrement;
lineWidth = this.lineWidth;
color = this.color;


%Make object display on a texture...


%Request object background color = transparent.
%Transparent version of circle/line color prevents artifacts if adjacent pixels are blended, e.g. if rotation.
c = [color 0];
this = element_setBackColor(this, c);
backColor = this.backColor;

%Open texture for drawing, sized to fit display, background = object background color
if backColor(4) == 0
    %Transparent background color accepted -> apply non-standard alpha blending trick for more accurate rendering of line edges at overlaps
    n_texture = element_openTexture(siz, [], [], 'GL_ONE', 'GL_ONE');
else
    %Overriden to opaque background color
    n_texture = element_openTexture(siz);
end


textureCenter = (siz+1)/2;

%Number of circles outside inner circle to draw to fill area, based on diagonal of area
numOuterCircles = floor((sum(siz.^2)^(1/2)/2-innerRadius)/radiusIncrement);
%Radii of all circles including inner
radii = innerRadius+(0:numOuterCircles)*radiusIncrement;
%Rects of all circles
rects = [repmat(-radii, 2, 1); repmat(+radii, 2, 1)]+repmat(transpose(textureCenter), 2, numOuterCircles+1);
%Approx compensate for PTB bug (?) that circle "pen width" seem to be ~1.4x larger than line width
circleLineWidth_fix = max(round(0.7*lineWidth), 1);

%Format for input to PTB DrawLines
r = siz(1)/2;
lineCoords = [
    -r +r -r +r
    -r +r +r -r
    ]+repmat(transpose(textureCenter), 1, 4);

if backColor(4) == 0
    moglcore('glBlendEquation', GL.MAX);
    
    %Draw circles centered on texture using PTB FrameOval
    Screen('FrameOval', n_texture, color, rects, circleLineWidth_fix)

    %Draw lines centered on texture using PTB DrawLines.
    %Enable antialiasing (smoothing).
    Screen('DrawLines', n_texture, lineCoords, lineWidth, color, [], 1);
    
    moglcore('glBlendEquation', GL.FUNC_ADD);
else
    Screen('FrameOval', n_texture, color, rects, circleLineWidth_fix)

    Screen('DrawLines', n_texture, lineCoords, lineWidth, color, [], 1);
end


%Static display with image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, n_texture);


this.n_texture = n_texture;