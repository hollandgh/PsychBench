frequency = this.frequency;
orientation = this.orientation;
flickerFrequency = this.flickerFrequency;
temporalFrequency = this.temporalFrequency;
rect_display = this.rect_display;
nn_gratingTextures = this.nn_gratingTextures;
n_texture = this.n_texture;
isEnding = this.isEnding;
startTime = this.startTime;
nextFrameTime = trial.nextFrameTime;


%Draw display to window to show in next frame.
%Display starts showing at object frame 1 start (screen refresh) after this script runs in object frame 0.
%Don't draw in last object frame cause then there is no next frame.
%element_draw/redraw automatically applies all core display functionality.
if ~isEnding
    if      flickerFrequency > 0
        %Flicker
        
        t = nextFrameTime-startTime;
        
        %Get flicker 1/2 for next frame.
        %t = 0 -> 1.
        i = mod(floor(flickerFrequency*t*2), 2)+1;

        %Show texture for flicker (i).
        %Dynamic display so use element_draw instead of element_redraw.
        this = element_draw(this, nn_gratingTextures(i));
            
    elseif  temporalFrequency ~= 0
        %Phase drift
        
        t = nextFrameTime-startTime;

        %Build total display on display texture.
        %Apply drift velocity, periodic by 1 spatial period so when drawn offset on the smaller display texture appears to drift smoothly within boundaries.
        drift = rem(temporalFrequency*t, 1)/frequency*[cosd(orientation) sind(orientation)];
        r = rect_display+repmat(drift, 1, 2);
        Screen('DrawTexture', n_texture, nn_gratingTextures(1), [], r)
        
        %Dynamic display so use element_draw instead of element_redraw.
        %Don't need to re-blank texture for next draw cause will fully overdraw texture with no blending with its background color.
        this = element_draw(this, n_texture);

    else
        %Static grating.
        %Same texture every frame so use element_redraw instead of element_draw for efficiency
        this = element_redraw(this, nn_gratingTextures(1));

    end
end