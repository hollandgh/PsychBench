if this.numDots > 0
    dotSize = this.dotSize;
    showMarkerNums = this.showMarkerNums;
    color = this.color;
    textureSize = this.textureSize;


    %Open texture for drawing, sized to fit display, with object background color (users can set in .backColor, default = transparent).
    %In openAtTrial instead of open cause textures Psychtoolbox holds can use
    %significant memory, so only hold for each object during its trial instead of
    %for all objects at same time at experiment startup.
    n_texture = element_openTexture(textureSize);
        
    %If transparent object background, standard blend factors GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA will minimize dot and line edge artifacts at both background and dot/line overlaps.
    %Alpha blending off (GL_ONE, GL_ZERO) for transparent background would give perfect edges at background but greater artifacts at overlaps.
    %If user needs perfect at both they can set background = opaque in .backColor.
    Screen('BlendFunction', n_texture, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
        
    if showMarkerNums
        Screen('TextFont', n_texture, 'Arial');
        fontSize = round(dotSize*2);
        Screen('TextSize', n_texture, fontSize);
        Screen('TextColor', n_texture, color);
%         Screen('TextBackgroundColor', n_texture, trial.backColor);
    end


    this.n_texture = n_texture;
end