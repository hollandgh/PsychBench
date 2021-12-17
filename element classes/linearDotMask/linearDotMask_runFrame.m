%ADJUSTABLE PROPERTIES
%Check for adjustments to adjustable input properties since previous frame
%---
if this.isAdjusted.numDots
    siz = this.size;
    numDots = this.numDots;
    numDots_prev = this.prev.numDots;
    dotDirection = this.dotDirection;
    dotSpeed = this.dotSpeed;
    dotLifetime = this.dotLifetime;
    rect = this.rect;
    dotPositions = this.dotPositions;
    dotDirections = this.dotDirections;
    dotSpeeds = this.dotSpeeds;
    dotLifetimes = this.dotLifetimes;
    dotAges = this.dotAges;


        %Error check adjusted value.
        %Only need to check value, not data type (numeric) or size (1) cause adjustment can't change those.
        if ~(isIntegerVal(numDots) && numDots >= 0)
            error('Property .numDots must be an integer >= 0.')
        end


        d = numDots-numDots_prev;
    if d > 0
        %Number of dots increased.
        %Add dots at initial positions, directions, speeds, lifetimes, ages.
        dotPositions(:,end+1:numDots) = [rect(1)+rand(1,d)*siz(1); rect(2)+rand(1,d)*siz(2)];
        dotDirections(end+1:numDots) = dotDirection(1)+(2*rand(1,d)-1)*dotDirection(2);
        dotSpeeds(end+1:numDots) = dotSpeed(1)+(2*rand(1,d)-1)*dotSpeed(2);
        dotLifetimes(end+1:numDots) = dotLifetime(1)+(2*rand(1,d)-1)*dotLifetime(2);
        dotAges(end+1:numDots) = rand(1,d).*dotLifetimes(numDots_prev+1:numDots);
    else
        %Number of dots decreased
        dotPositions = dotPositions(:,1:numDots);
        dotDirections = dotDirections(1:numDots);
        dotSpeeds = dotSpeeds(1:numDots);
        dotLifetimes = dotLifetimes(1:numDots);
        dotAges = dotAges(1:numDots);
    end


    this.dotPositions = dotPositions;
    this.dotDirections = dotDirections;
    this.dotSpeeds = dotSpeeds;
    this.dotLifetimes = dotLifetimes;
    this.dotAges = dotAges;
end
%---




siz = this.size;
numDots = this.numDots;
dotDirection = this.dotDirection;
dotSpeed = this.dotSpeed;
dotLifetime = this.dotLifetime;
dotSize = this.dotSize;
color = this.color;
nn_eyes = this.nn_eyes;
rect = this.rect;
dotPositions = this.dotPositions;
dotDirections = this.dotDirections;
dotSpeeds = this.dotSpeeds;
dotLifetimes = this.dotLifetimes;
dotAges = this.dotAges;
n_window = this.n_window;
isEnding = this.isEnding;
    %start time of next frame (frame being prepared)
nextFrameTime = trial.nextFrameTime;
stereo = resources.screen.stereo;
    
    
if numDots > 0 && ~isEnding
    %Update display for next frame...
    %Don't draw in last frame.
    
    
    %Time difference from prev iteration
    dt = nextFrameTime-trial.frameTimes(2);
    
    if dotLifetime(1) < inf
        %Age dots and check for deaths
        dotAges = dotAges+dt;
        nn_regenerateDots = dotAges > dotLifetimes;
        
        if any(nn_regenerateDots)
            %Regenerate (randomize) dead dots
            
            numRegenerateDots = numel(find(nn_regenerateDots));

            dotPositions(:,nn_regenerateDots) = [rect(1)+rand(1,numRegenerateDots)*siz(1); rect(2)+rand(1,numRegenerateDots)*siz(2)];
            dotDirections(nn_regenerateDots) = dotDirection(1)+(2*rand(1,numRegenerateDots)-1)*dotDirection(2);
            dotSpeeds(nn_regenerateDots) = dotSpeed(1)+(2*rand(1,numRegenerateDots)-1)*dotSpeed(2);
            dotLifetimes(nn_regenerateDots) = dotLifetime(1)+(2*rand(1,numRegenerateDots)-1)*dotLifetime(2);
            dotAges(nn_regenerateDots) = 0;
        end
    end

    %Move dots
    dotPositions(1,:) = dotPositions(1,:)+dotSpeeds.*cosd(dotDirections)*dt;
        % - cause y = down on screen
    dotPositions(2,:) = dotPositions(2,:)+dotSpeeds.*sind(dotDirections)*dt;
    
    %Rescue dots falling off edge to opposite side.
    %Has to be opposite side else if there is any direction coherence dots will cluster up toward the end of that direction.
    nn_wrapDots = dotPositions(1,:) < rect(1);
    dotPositions(1,nn_wrapDots) = dotPositions(1,nn_wrapDots)+siz(1);
    nn_wrapDots = dotPositions(1,:) > rect(3);
    dotPositions(1,nn_wrapDots) = dotPositions(1,nn_wrapDots)-siz(1);
    nn_wrapDots = dotPositions(2,:) < rect(2);
    dotPositions(2,nn_wrapDots) = dotPositions(2,nn_wrapDots)+siz(2);
    nn_wrapDots = dotPositions(2,:) > rect(4);
    dotPositions(2,nn_wrapDots) = dotPositions(2,nn_wrapDots)-siz(2);
    
    
    if WITHPTB
        %Draw display to screen to show in next frame.
        %Display starts showing at object frame 1 start (screen refresh) after this script runs in object frame 0.
        %Don't draw in last object frame cause then there is no next frame.
        %Direct draw to screen instead of texture method cause uses PTB DrawDots with
        %round dots, which needs alpha blending enabled on target surface, which means
        %final background must be present.
        %dotSize, color, nn_eyes, opacity applied here.
        if stereo == 0
                Screen('DrawDots', n_window, dotPositions, dotSize, color, [], 1);
        else
            for n_eye = nn_eyes
                this = element_setEye(this, n_eye);
                Screen('DrawDots', n_window, dotPositions, dotSize, color, [], 1);
            end
        end
        
        
    else %WITHMGL
        %MGLTODOTENT REPLACE WITH GLUDISK OR SIMILAR WHEN AVAILABLE
        if stereo == 0
                mglPoints2(dotPositions(1,:), dotPositions(2,:), dotSize, color)
        else
            for n_eye = nn_eyes
                this = element_setEye(this, n_eye);

                mglPoints2(dotPositions(1,:), dotPositions(2,:), dotSize, color)
            end
        end
        
        
    end
    

this.dotPositions = dotPositions;
this.dotDirections = dotDirections;
this.dotSpeeds = dotSpeeds;
this.dotLifetimes = dotLifetimes;
this.dotAges = dotAges;
end