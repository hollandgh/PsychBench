numAngularChecks = this.numAngularChecks;
flickerFrequency = this.flickerFrequency;
angularTemporalFrequency = this.angularTemporalFrequency;
radialTemporalFrequency = this.radialTemporalFrequency;
angularTemporalFrequencyBalanced = this.angularTemporalFrequencyBalanced;
radialTemporalFrequencyBalanced = this.radialTemporalFrequencyBalanced;
fps = this.fps;
numImages = this.numImages;
nn_dartboardTextures = this.nn_dartboardTextures;
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
        this = element_draw(this, nn_dartboardTextures(i));
            
    elseif  angularTemporalFrequency ~= 0
        %Angular phase drift
        
        t = nextFrameTime-startTime;

        %Build total display on display texture.
        %Apply drift rotation.
        drift = angularTemporalFrequency*t*720/numAngularChecks;
        Screen('DrawTexture', n_texture, nn_dartboardTextures(1), [], [], drift)
        
        %Dynamic display so use element_draw instead of element_redraw.
        %Tell element_draw to re-blank the texture so ready for next draw to it in next runFrame iteration.
        this = element_draw(this, n_texture, [], [], [], '-blank');

    elseif  radialTemporalFrequency ~= 0 || angularTemporalFrequencyBalanced ~= 0 || radialTemporalFrequencyBalanced ~= 0
        %Radial phase drift, Phase drift balanced

        t = nextFrameTime-startTime;

        %Get image for next frame.
        %t = 0 -> 1.
        i = mod(floor(fps*t), numImages)+1;
        
        this = element_draw(this, nn_dartboardTextures(i));

    else
        %Static dartboard.
        %Same texture every frame so use element_redraw instead of element_draw for efficiency.
        this = element_redraw(this, nn_dartboardTextures(1));
            
    end
end