flickerFrequency = this.flickerFrequency;
apertureInterval = this.apertureInterval;
nn_textures = this.nn_textures;
isEnding = this.isEnding;
startTime = this.startTime;
nextFrameTime = trial.nextFrameTime;


%Draw display to window to show in next frame.
%Display starts showing at object frame 1 start (screen refresh) after this script runs in object frame 0.
%Don't draw in last object frame cause then there is no next frame.
%element_draw/redraw automatically applies all core display functionality.
if ~isEnding
    if flickerFrequency == 0 && apertureInterval == inf
            %Static dartboard.
            %Same texture every frame so use element_redraw instead of element_draw for efficiency.
            this = element_redraw(this, nn_textures(1,1));
            
    else
            t = nextFrameTime-startTime;
        if flickerFrequency > 0
            %Get flicker 1/2 for next frame.
            %t = 0 -> 1.
            i = ceil(sin(2*pi*flickerFrequency*t+pi)/2)+1;
        else
            i = 1;
        end
        if apertureInterval < inf
            %Get aperture, including wrap, for next frame
            j = floor(t/apertureInterval)+1;
            j = mod(j-1, size(nn_textures, 2))+1;
        else
            j = 1;
        end
        
            %Show texture for flicker (i), aperture (j).
            %Changing textures so use element_draw.
            this = element_draw(this, nn_textures(i,j));
            
    end
end