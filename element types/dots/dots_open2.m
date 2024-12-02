global GL


sizes = this.size;
colors = this.color;
type = this.type;
positions_texture = this.positions_texture;
textureSize = this.textureSize;
centerOffset = this.centerOffset;


%Make object display on a texture...

%Request object background color = transparent.
%Transparent version of dot color prevents artifacts if adjacent pixels are blended, e.g. if rotation.
if all2(colors(:,1:3) == repmat(colors(1,1:3), size(colors, 1), 1))
    %One dot or all dot colors equal
    c = [colors(1,1:3) 0];
else
    %Multiple colors--just use mean color 0.5
    c = [0.5 0.5 0.5 0];
end
this = element_setBackColor(this, c);

%Format for input to PTB DrawDots.
%Include flip ordering so for multiple dots maybe overlapping draw with first above last to match convention for property .depth (+ = behind).
sizes = transpose(flip(sizes));
colors = transpose(flip(colors, 1));
type = type-1;
positions_texture = transpose(flip(positions_texture, 1));

if this.backColor(4) == 0 && all(colors(4,:) == 1)
        %Transparent background color accepted and all opaque dots...
        
    if all2(colors(1:3,:) == repmat(colors(1:3,1), 1, size(colors, 2)))
        %and one dot or all dot colors equal -> can apply non-standard alpha blending trick for accurate rendering of dot edges at overlaps, at least for antialiased dot types
        
        %Open texture for drawing, sized to fit display, background = object background color
        n_texture = element_openTexture(textureSize, [], [], 'GL_ONE', 'GL_ONE');

        %Draw display centered on texture using PTB DrawDots
        moglcore('glBlendEquation', GL.MAX);
        Screen('DrawDots', n_texture, positions_texture, sizes, colors, [], type);
        moglcore('glBlendEquation', GL.FUNC_ADD);
    else
        %but not all colors equal -> can't do trick.
        %Force standard alpha blending on minimizes dot edge blending artifacts across both background and dot overlaps on transparent background.
        %Alpha blending off would give perfect edges at background but greater artifacts at overlaps.
        %If user needs perfect at both background and overlaps, can set opaque background in .backColor.
        %Also needs to set opaque background if overlapping dots with top ones having some transparency.
        
        n_texture = element_openTexture(textureSize, [], [], 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

        Screen('DrawDots', n_texture, positions_texture, sizes, colors, [], type);
    end
else
        %Overriden to opaque background color -> standard alpha blending + alpha channel off on is default and works perfectly for all cases
        %or
        %Some transparent dots -> alpha blending off is default for transparent texture and works perfectly unless dots overlap
        
        n_texture = element_openTexture(textureSize);

        Screen('DrawDots', n_texture, positions_texture, sizes, colors, [], type);
end

%Static display with image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, n_texture, [], [], centerOffset);


this.n_texture = n_texture;