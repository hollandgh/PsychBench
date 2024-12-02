numAngularChecks = this.numAngularChecks;
flickerFrequency = this.flickerFrequency;
angularTemporalFrequency = this.angularTemporalFrequency;
radialTemporalFrequency = this.radialTemporalFrequency;
angularTemporalFrequencyBalanced = this.angularTemporalFrequencyBalanced;
radialTemporalFrequencyBalanced = this.radialTemporalFrequencyBalanced;
fps = this.fps;
apertureInterval = this.apertureInterval;
maxNumLoops = this.maxNumLoops;
numImages = this.numImages;
nn_dartboardTextures = this.nn_dartboardTextures;
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
        Screen('DrawTexture', n_texture, nn_dartboardTextures(i))
            
    elseif  angularTemporalFrequency ~= 0
        %Angular phase drift
        %Apply drift rotation
        drift = angularTemporalFrequency*t*720/numAngularChecks;
        Screen('DrawTexture', n_texture, nn_dartboardTextures(1), [], [], drift)

    elseif  radialTemporalFrequency ~= 0 || angularTemporalFrequencyBalanced ~= 0 || radialTemporalFrequencyBalanced ~= 0
        %Radial phase drift, Phase drift balanced
        %Get image for next frame.
        %t = 0 -> 1.
        i = mod(floor(fps*t), numImages)+1;
        Screen('DrawTexture', n_texture, nn_dartboardTextures(i))

    else
        %Static dartboard
        Screen('DrawTexture', n_texture, nn_dartboardTextures(1))
        
    end
    
    if ~isempty(nn_apertureTextures)
        %Get aperture, including wrap, for next frame
        %t = 0 -> 1.
        i = floor(t/apertureInterval)+1;
        if i > maxNumLoops*numel(nn_apertureTextures)
            %Past maximum number of passes through dartboard -> END OBJECT ON ITS OWN
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