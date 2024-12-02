orientation = this.orientation;
flickerFrequency = this.flickerFrequency;
temporalFrequency = this.temporalFrequency;
temporalFrequencyBalanced = this.temporalFrequencyBalanced;
fps = this.fps;
apertureInterval = this.apertureInterval;
maxNumLoops = this.maxNumLoops;
numImages = this.numImages;
frequency = this.frequency;
rect_display = this.rect_display;
nn_checkerboardTextures = this.nn_checkerboardTextures;
nn_apertureTextures = this.nn_apertureTextures;
n_texture = this.n_texture;
isEnding = this.isEnding;
startTime = this.startTime;
nextFrameTime = trial.nextFrameTime;


%Draw display to window to show in next frame.
%Display starts showing at object frame 1 start (screen refresh) after this script runs in object frame 0.
%Don't draw in last object frame cause then there is no next frame.
if ~isEnding
    t = nextFrameTime-startTime;
        
    %Build total display on display texture...
        
    if      flickerFrequency > 0        
        %Flicker
        %Get flicker 1/2 for next frame.
        %t = 0 -> 1.
        i = mod(floor(flickerFrequency*t*2), 2)+1;
        Screen('DrawTexture', n_texture, nn_checkerboardTextures(i))
            
    elseif  temporalFrequency(1) ~= 0
        %Horizontal phase drift
        %Apply drift velocity, periodic by 1 spatial period so when drawn offset on the smaller display texture appears to drift smoothly within boundaries
        drift = rem(temporalFrequency(1)*t, 1)/frequency(1)*[cosd(orientation) sind(orientation)];
        r = rect_display+repmat(drift, 1, 2);
        Screen('DrawTexture', n_texture, nn_checkerboardTextures(1), [], r)

    elseif  temporalFrequency(2) ~= 0
        %Vertical phase drift
        drift = rem(temporalFrequency(2)*t, 1)/frequency(2)*[-sind(orientation) cosd(orientation)];
        r = rect_display+repmat(drift, 1, 2);
        Screen('DrawTexture', n_texture, nn_checkerboardTextures(1), [], r)
        
    elseif  any(temporalFrequencyBalanced ~= 0)
        %Phase drift balanced
        %Get image for next frame.
        %t = 0 -> 1.
        i = mod(floor(fps*t), numImages)+1;
        Screen('DrawTexture', n_texture, nn_checkerboardTextures(i))

    else
        %Static checkerboard
        Screen('DrawTexture', n_texture, nn_checkerboardTextures(1))
        
    end
    
    if ~isempty(nn_apertureTextures)
        %Get aperture, including wrap, for next frame
        %t = 0 -> 1.
        i = floor(t/apertureInterval)+1;
        if i > maxNumLoops*numel(nn_apertureTextures)
            %Past maximum number of passes through checkerboard -> END OBJECT ON ITS OWN
            this = element_end(this);
            return
        end
        i = mod(i-1, numel(nn_apertureTextures))+1;
            
        %By default DrawTexture draws texture centered and unscaled
        Screen('DrawTexture', n_texture, nn_apertureTextures(i))
    end
    
    %Dynamic display so use element_draw instead of element_redraw.
    %Tell element_draw to re-blank the texture so ready for next draw to it in next runFrame iteration.
    %element_draw automatically applies all core display functionality.
    this = element_draw(this, n_texture, [], [], [], '-blank');
end