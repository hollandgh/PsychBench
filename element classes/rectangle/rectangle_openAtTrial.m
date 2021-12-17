if WITHPTB
    siz = this.size;
    showFill = this.showFill;
    color = this.color;
    showBorder = this.showBorder;
    borderWidth = this.borderWidth;
    borderColor = this.borderColor;
    n_window = this.n_window;


    %Make object display on a texture.
    %In openAtTrial instead of open cause textures Psychtoolbox holds can use
    %significant memory, so only hold for each object during its trial instead of
    %for all objects at same time at experiment startup.

    %Open texture sized to fit display with transparent background using PTB OpenOffscreenWindow
    n_texture = Screen('OpenOffscreenWindow', n_window, [0 0 0 0], [0 0 siz]);

    %Draw display centered on texture using PTB FillRect, FrameRect
    if showFill
        %Fill texture with color
        Screen('FillRect', n_texture, color)    
    end
    if showBorder
        %Draw border to texture
        Screen('FrameRect', n_texture, borderColor, [0 0 siz], borderWidth)
    end


    this.n_texture = n_texture;
end