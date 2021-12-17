%TODO: Vectorize Fourier, move stuff like repmat out of frames
    
    
fps = this.fps;
azimuth = this.azimuth;
elevation = this.elevation;
azimuthVel = this.azimuthVel;
speed = this.speed;
dotSize = this.dotSize;
stickWidth = this.stickWidth;
nn_stickMarkers = this.nn_stickMarkers;
color = this.color;
repeat = this.repeat;
position = this.position;
nn_eyes = this.nn_eyes;
dataRep = this.dataRep;
data = this.data;
numHarmonics = this.numHarmonics;
numImages = this.numImages;
numDots = this.numDots;
nn_showDots = this.nn_showDots;
periods = this.periods;
phases = this.phases;
transVel = this.transVel;
transPosition = this.transPosition;
n_window = this.n_window;
startTime = this.startTime;
isEnding = this.isEnding;
    %start time of next frame (frame being prepared)
nextFrameTime = trial.nextFrameTime;
stereo = resources.screen.stereo;


if numDots > 0 && ~isEnding
    %Update display for next frame...
    %Don't draw in last frame.


    %Time relative to object start (object frame 1 start)
    t = nextFrameTime-startTime;
    %Time difference from prev iteration
    dt = nextFrameTime-trial.frameTimes(2);




    %Get image
    %======================================================================
    if strcmp(dataRep, 'mm')


    periods = repmat(periods, [3 1]);
    phases = repmat(phases, [3 1]);
        x = data(:,:,1);
    for n_harmonic = 1:numHarmonics
        x = x+data(:,:,2*n_harmonic).*sin(n_harmonic*(2*pi./periods*t+phases))+data(:,:,2*n_harmonic+1).*cos(n_harmonic*(2*pi./periods*t+phases));
    end
    data = x;




    %======================================================================
    elseif strcmp(dataRep, 'md')


    %Get md image number that will show for next frame.
            %floor + 1 cause mid of frame with t = 0 -> image 1
            n_image = floor(fps*speed*t)+1;
    if n_image > numImages
        if ~repeat
            %End of images and not set to repeat -> END OBJECT ON ITS OWN
            this = element_end(this);
            return
        else
            %Wrap image number
            n_image = mod(n_image-1, numImages)+1;
        end
    end
    data = data(:,:,n_image);




    %======================================================================
    end




    %Rotate here if azimuth vel cause need t
    if azimuthVel ~= 0
        az = azimuth+azimuthVel*t;
        el = elevation;
        data = [cosd(el) 0 sind(el); 0 1 0; -sind(el) 0 cosd(el)]*[cosd(az) -sind(az) 0; sind(az) cosd(az) 0; 0 0 1]*data;
    end

    %Translate by trans vel.
    %Increment using dt so walks in a circle if have az vel.
    if transVel ~= 0
        transPosition = transPosition+transVel*(dt)*sind(az);
        data(2,:) = data(2,:)+transPosition;
    end

    %Project onto screen
    data = [data(2,:); -data(3,:)];
    %Translate from centered at [0 0] -> centered at object position on screen
    data = data+repmat(transpose(position), [1 numDots]);

    
    if WITHPTB
        %Draw display to screen to show in next frame.
        %Display starts showing at object frame 1 start (screen refresh) after this script runs in object frame 0.
        %Don't draw in last object frame cause then there is no next frame.
        %Direct draw to screen instead of texture method cause uses PTB DrawDots with
        %round dots and DrawLines with smoothing, which needs alpha blending enabled on
        %target surface, which means final background must be present.
        %dotSize, stickWidth, color, nn_eyes, opacity applied here.
        %Checked one of dotSize || stickWidth > 0 so these Screen functions never called for nothing.
        if stereo == 0
                if dotSize > 0
                    dd = data(:,nn_showDots);
                    Screen('DrawDots', n_window, dd, dotSize, color, [], 1);
                end
                if stickWidth > 0
                    dd = data(:,nn_stickMarkers);
                    Screen('DrawLines', n_window, dd, stickWidth, color, [], 1);
                end
        else
            for n_eye = nn_eyes
                this = element_setEye(this, n_eye);

                if dotSize > 0
                    dd = data(:,nn_showDots);
                    Screen('DrawDots', n_window, dd, dotSize, color, [], 1);
                end
                if stickWidth > 0
                    dd = data(:,nn_stickMarkers);
                    Screen('DrawLines', n_window, dd, stickWidth, color, [], 1);
                end
            end
        end
        
        
    else %WITHMGL
        %MGLTODOTENT REPLACE WITH GLUDISK OR SIMILAR WHEN AVAILABLE
        if stereo == 0
                if dotSize > 0
                    dd = data(:,nn_showDots);
                    mglPoints2(dd(1,:), dd(2,:), dotSize, color)
                end
                if stickWidth > 0
                    dd = data(:,nn_stickMarkers);
                    mglLines2(dd(1,1:2:end), dd(2,1:2:end), dd(1,2:2:end), dd(2,2:2:end), stickWidth, color)
                end
        else
            for n_eye = nn_eyes
                this = element_setEye(this, n_eye);

                if dotSize > 0
                    dd = data(:,nn_showDots);
                    mglPoints2(dd(1,:), dd(2,:), dotSize, color)
                end
                if stickWidth > 0
                    dd = data(:,nn_stickMarkers);
                    mglLines2(dd(1,1:2:end), dd(2,1:2:end), dd(1,2:2:end), dd(2,2:2:end), stickWidth, color)
                end
            end
        end
        
        
    end


this.transPosition = transPosition;
end