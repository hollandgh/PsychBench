%TODO: Vectorize Fourier, move stuff like repmat out of frames


global GL
    

if this.numDots > 0 && ~this.isEnding
    fps = this.fps;
    azimuth = this.azimuth;
    elevation = this.elevation;
    azimuthVelocity = this.azimuthVelocity;
    dotSize = this.dotSize;
    color = this.color;
    maxNumLoops = this.maxNumLoops;
    phase = this.phase;
    speed = this.speed;
    stickWidth = this.stickWidth;
    nn_stickMarkers = this.nn_stickMarkers;
    showMarkerNums = this.showMarkerNums;
    position = this.position;
    backColor = this.backColor;
    dataRep = this.dataRep;
    data = this.data;
    numHarmonics = this.numHarmonics;
    numImages = this.numImages;
    numImagesWithBreak = this.numImagesWithBreak;
    numDots = this.numDots;
    nn_showDots = this.nn_showDots;
    periods = this.periods;
    phases = this.phases;
    translationVelocity = this.translationVelocity;
    translationPosition = this.translationPosition;
    n_texture = this.n_texture;
    textureCenter = this.textureCenter;
    isStarting = this.isStarting;
    startTime = this.startTime;
    %mid time of next frame (frame being prepared)
    nextFrameTime = trial.nextFrameTime;


    %Update display for next frame...
    %Don't draw in last frame.


    %Time relative to object start (object frame 1 start)
    t = nextFrameTime-startTime;
    %Time difference from prev iteration
    dt = nextFrameTime-trial.frameTimes(3);




    %Get image
    %======================================================================
    if strcmp(dataRep, 'mm')


    %loop true/false ingored for mm
    if t > maxNumLoops*periods(1)
        %Past maximum number of loops -> END OBJECT ON ITS OWN
        this = element_end(this);
        return
    end
    
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
    n_image = floor(speed*fps*t+phase)+1;
    if n_image > phase+maxNumLoops*numImagesWithBreak
        %Past maximum number of loops through motion data length regardless of start point -> END OBJECT ON ITS OWN
        this = element_end(this);
        return
    end
    %Wrap image number
    n_image = mod(n_image-1, numImagesWithBreak)+1;
    
    if n_image > numImages
        %In inter-repeat interval
        return
    end
    data = data(:,:,n_image);




    %======================================================================
    end




    %Rotate here if azimuth vel cause need t
    if azimuthVelocity ~= 0
        azimuth = azimuth+azimuthVelocity*t;
        
        az = azimuth;
        el = elevation;
        data = [cosd(el) 0 sind(el); 0 1 0; -sind(el) 0 cosd(el)]*[cosd(az) -sind(az) 0; sind(az) cosd(az) 0; 0 0 1]*data;
    end

    %Translate by trans vel.
    %Increment using dt so walks in a circle if have az vel.
    if translationVelocity ~= 0
        translationPosition = translationPosition+translationVelocity*(dt)*sind(azimuth);
        data(2,:) = data(2,:)+translationPosition;
    end

    %Project onto 2D
    data = [data(2,:); -data(3,:)];
    
    %Translate from centered at [0 0] -> centered on texture
    data = data+repmat(transpose(textureCenter), [1 numDots]);

    if showMarkerNums
        %Draw static display: marker numbers
        if dotSize > 0
            if isStarting
                if backColor(4) == 0
                    moglcore('glBlendEquation', GL.MAX);
                    for n_dot = nn_showDots
                        n_dot_s = num2str(n_dot);
                        Screen('DrawText', n_texture, n_dot_s, data(1,n_dot), data(2,n_dot));
                    end
                    moglcore('glBlendEquation', GL.FUNC_ADD);
                else
                    for n_dot = nn_showDots
                        n_dot_s = num2str(n_dot);
                        Screen('DrawText', n_texture, n_dot_s, data(1,n_dot), data(2,n_dot));
                    end
                end
            end
            this = element_redraw(this, n_texture);
        end
    else
        %Draw dynamic display: dots and/or lines
                if backColor(4) == 0
                    %Transparent texture background -> use alpha blending trick
                    moglcore('glBlendEquation', GL.MAX);
                    if dotSize > 0
                        dd = data(:,nn_showDots);
                        Screen('DrawDots', n_texture, dd, dotSize, color, [], 1);
                    end
                    if stickWidth > 0
                        dd = data(:,nn_stickMarkers);
                        Screen('DrawLines', n_texture, dd, stickWidth, color, [], 1);
                    end
                    moglcore('glBlendEquation', GL.FUNC_ADD);
                else
                    if dotSize > 0
                        dd = data(:,nn_showDots);
                        Screen('DrawDots', n_texture, dd, dotSize, color, [], 1);
                    end
                    if stickWidth > 0
                        dd = data(:,nn_stickMarkers);
                        Screen('DrawLines', n_texture, dd, stickWidth, color, [], 1);
                    end
                end
            this = element_draw(this, n_texture, [], [], [], '-blank');
    end


this.translationPosition = translationPosition;
end