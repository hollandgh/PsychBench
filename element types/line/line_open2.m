global GL


widths = this.width;
colors = this.color;
numLines = this.numLines;
points_texture = this.points_texture;
textureSize = this.textureSize;
centerOffset = this.centerOffset;


%Make object display on a texture...


%Request object background color = transparent.
%Transparent version of line color prevents artifacts if adjacent pixels are blended, e.g. if rotation.
if all2(colors == repmat(colors(1,:), size(colors, 1), 1))
    %One line or all line colors equal
    c = [colors(1,:) 0];
else
    %Multiple colors--just use mean color 0.5
    c = [0.5 0.5 0.5 0];
end
this = element_setBackColor(this, c);


%Format for input to PTB DrawLines.
%Include flip ordering so for multiple lines maybe overlapping draw with first above last to match convention for property .depth (+ = behind).
%---
widths = flip(widths);

x(1:2:numLines*2,:) = colors;
x(2:2:numLines*2,:) = colors;
x = transpose(flip(x, 1));
colors = x;

points_texture = transpose(flip(points_texture, 1));
%---


if this.backColor(4) == 0
        %Transparent background color accepted...
        
    if all2(colors == repmat(colors(:,1), 1, size(colors, 2)))
        %and one line or all line colors equal -> can apply non-standard alpha blending trick for accurate rendering of line edges at overlaps
        
        %Open texture for drawing, sized to fit display, background = object background color
        n_texture = element_openTexture(textureSize, [], [], 'GL_ONE', 'GL_ONE');

        %Draw display centered on texture using PTB DrawLines
        moglcore('glBlendEquation', GL.MAX);
        Screen('DrawLines', n_texture, points_texture, widths, colors, [], 1);
        moglcore('glBlendEquation', GL.FUNC_ADD);
    else
        %but not all colors equal -> can't do trick.
        %Force standard alpha blending on minimizes line edge blending artifacts across both background and line overlaps on transparent background.
        %Alpha blending off would give perfect edges at background but greater artifacts at overlaps.
        %If user needs perfect at both background and overlaps, can set opaque background in .backColor.
        %OR
        %Bug in PTB DrawLines requires alpha blending on for smoothed lines even when drawing to transparent texture.
        %TODO: If bug gets fixed, allow transparent colors cause could draw perfectly on transparent texture with alpha blending off unless lines overlap.
        
        n_texture = element_openTexture(textureSize, [], [], 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

        Screen('DrawLines', n_texture, points_texture, widths, colors, [], 1);
    end
else
        %Overriden to opaque background color -> standard alpha blending on + alpha channel off is default and works perfectly for all cases
        
        n_texture = element_openTexture(textureSize);

        Screen('DrawLines', n_texture, points_texture, widths, colors, [], 1);
end

%Static display with image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, n_texture, [], [], centerOffset);


this.n_texture = n_texture;