if WITHPTB
    siz = this.size;
    lineWidth = this.lineWidth;
    color = this.color;
    n_window = this.n_window;


    %Make object display on a texture.
    %In openAtTrial instead of open cause textures Psychtoolbox holds can use
    %significant memory, so only hold for each object during its trial instead of
    %for all objects at same time at experiment startup.

    %Open texture sized to fit display with transparent background using PTB OpenOffscreenWindow
    n_texture = Screen('OpenOffscreenWindow', n_window, [0 0 0 0], [0 0 siz]);
    textureCenter = (siz+1)/2;

    %Draw display centered on texture using PTB DrawLines.
    %Don't need smoothing input to DrawLines cause drawn horz/vert.
    coords = [
        textureCenter(1) textureCenter(1) 0                siz(1)
        0                siz(2)           textureCenter(2) textureCenter(2)
        ];
    Screen('DrawLines', n_texture, coords, lineWidth, color);


    this.n_texture = n_texture;
end