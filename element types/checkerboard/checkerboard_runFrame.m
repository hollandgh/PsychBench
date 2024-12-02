orientation = this.orientation;
flickerFrequency = this.flickerFrequency;
temporalFrequency = this.temporalFrequency;
temporalFrequencyBalanced = this.temporalFrequencyBalanced;
fps = this.fps;
numImages = this.numImages;
frequency = this.frequency;
rect_display = this.rect_display;
nn_checkerboardTextures = this.nn_checkerboardTextures;
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
        this = element_draw(this, nn_checkerboardTextures(i));
            
    elseif  temporalFrequency(1) ~= 0
        %Horizontal phase drift
        
        t = nextFrameTime-startTime;

        %Build total display on display texture.
        %Apply drift velocity, periodic by 1 spatial period so when drawn offset on the smaller display texture appears to drift smoothly within boundaries.
        drift = rem(temporalFrequency(1)*t, 1)/frequency(1)*[cosd(orientation) sind(orientation)];
        r = rect_display+repmat(drift, 1, 2);
        Screen('DrawTexture', n_texture, nn_checkerboardTextures(1), [], r)
        
        %Dynamic display so use element_draw instead of element_redraw.
        %Don't need to re-blank texture for next draw cause will fully overdraw texture with no blending with its background color.
        this = element_draw(this, n_texture);

    elseif  temporalFrequency(2) ~= 0
        %Vertical phase drift
        
        t = nextFrameTime-startTime;

        drift = rem(temporalFrequency(2)*t, 1)/frequency(2)*[-sind(orientation) cosd(orientation)];
        r = rect_display+repmat(drift, 1, 2);
        Screen('DrawTexture', n_texture, nn_checkerboardTextures(1), [], r)
        
        this = element_draw(this, n_texture);

    elseif  any(temporalFrequencyBalanced ~= 0)
        %Phase drift balanced
        
        t = nextFrameTime-startTime;

        %Get image for next frame.
        %t = 0 -> 1.
        i = mod(floor(fps*t), numImages)+1;

        this = element_draw(this, nn_checkerboardTextures(i));

    else
        %Static checkerboard.
        %Same texture every frame so use element_redraw instead of element_draw for efficiency
        this = element_redraw(this, nn_checkerboardTextures(1));

    end
end