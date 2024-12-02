if this.numDots > 0
    dotSize = this.dotSize;
    showMarkerNums = this.showMarkerNums;
    color = this.color;
    textureSize = this.textureSize;


    %Request object background color = transparent.
    %Transparent version of dot color prevents artifacts if adjacent pixels are blended, e.g. if rotation.
    c = [color 0];
    this = element_setBackColor(this, c);

    %Open texture for drawing, sized to fit display, background = object background color
    if this.backColor(4) == 0
        %Transparent background color accepted -> apply non-standard alpha blending trick for accurate rendering of dot edges at overlaps
        n_texture = element_openTexture(textureSize, [], [], 'GL_ONE', 'GL_ONE');
    else
        %Overriden to opaque background color
        n_texture = element_openTexture(textureSize);
    end
        
    if showMarkerNums
        Screen('TextFont', n_texture, 'Arial');
        fontSize = round(dotSize*2);
        Screen('TextSize', n_texture, fontSize);
        Screen('TextColor', n_texture, color);
    end


    this.n_texture = n_texture;
end