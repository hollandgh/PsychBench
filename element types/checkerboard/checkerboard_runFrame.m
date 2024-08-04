flickerFrequency = this.flickerFrequency;
nn_textures = this.nn_textures;
isEnding = this.isEnding;
startTime = this.startTime;
nextFrameTime = trial.nextFrameTime;


%Draw display to window to show in next frame.
%Display starts showing at object frame 1 start (screen refresh) after this script runs in object frame 0.
%Don't draw in last object frame cause then there is no next frame.
%element_draw/redraw automatically applies all core display functionality.
if ~isEnding
    if flickerFrequency == 0
        %Static checkerboard.
        %Same texture every frame so use element_redraw instead of element_draw for efficiency.
        this = element_redraw(this, nn_textures(1));
            
    else
        t = nextFrameTime-startTime;
        %Get flicker 1/2 for next frame.
        %t = 0 -> 1.
        i = ceil(sin(2*pi*flickerFrequency*t+pi)/2)+1;

        %Show texture for flicker (i).
        %Changing textures so use element_draw.
        this = element_draw(this, nn_textures(i));
            
    end
end