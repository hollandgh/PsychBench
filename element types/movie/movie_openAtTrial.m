fileName = this.fileName;
crop = this.crop;
height = this.height;
times = this.times;
speed = this.speed;
repeat = this.repeat;
phase = this.phase;
grayscale = this.grayscale;
volume = this.volume;
n_window = this.n_window;
openRect = devices.screen.openRect;
windowSize = devices.screen.windowSize;
frameInterval = experiment.frameInterval;


%Open movie from file using PTB OpenMovie.
%In openAtTrial instead of open cause Psychtoolbox holding movies open could use
%significant resources, so only hold for each object during its trial instead of
%for all objects at same time at experiment startup.
%[ moviePtr [duration] [fps] [width] [height] [count] [aspectRatio] [hdrStaticMetaData]]=Screen('OpenMovie', windowPtr, moviefile [, async=0] [, preloadSecs=1] [, specialFlags1=0][, pixelFormat=4][, maxNumberThreads=-1][, movieOptions]);
if volume > 0
    specialFlags1 = [];
else
    specialFlags1 = 2;
end
if ~grayscale
    pixelFormat = [];
else
    pixelFormat = 2;
end
[n_movie, duration_file, fps_file, width_image, height_image] = Screen('OpenMovie', n_window, fileName, [], [], specialFlags1, pixelFormat);
    
    
%Crop, size
%---
    size_image = [width_image height_image];

if ~all(crop == [0 0 inf inf])
    %Snap crop to image size, get new image size.
    %Will apply crop at draw.
    %crop(1:2) = pixels before part, so crop(3:4)-crop(1:2) = part [width height], same convention as Psychtoolbox rects.
    
        %Checked at input >= 0, 1 < 3, 2 < 4
        if ~all(crop(1:2) < size_image)
            error('In property .crop: Crop area is outside the movie.')
        end
    crop(3:4) = min(crop(3:4), size_image);
    size_image = crop(3:4)-crop(1:2);
end

if isa(height, 'char')
    if      strcmpi(height, 'fit')
        %Fit whole image to window
        sizeMult = min(windowSize./size_image);
    elseif  strcmpi(height, 'fitw')
        %Fit image width to window
        sizeMult = windowSize(1)/size_image(1);
    elseif  strcmpi(height, 'fith')
        %Fit image height to winow
        sizeMult = windowSize(2)/size_image(2);
    elseif  strcmpi(height, 'fill')
        %Fill window
        sizeMult = max(windowSize./size_image);
    elseif  strcmpi(height, 'px')
        %Show image at 1 px image = 1 px screen.
        %Scale down by partial-window height if users set screen .openRect.
        sizeMult = openRect(4)-openRect(2);
    end
else
        %User set height directly
        sizeMult = height/size_image(2);
end

height = sizeMult*size_image(2);
%---


%Movie image interval
if fps_file > 0
    imageInterval_file = 1/fps_file;
else
    %Use experiment frame interval if fps_file fails
    imageInterval_file = frameInterval;
end


%Combine time limits, phase
    if ~(times(1) < duration_file)
        error(['In property .times: times(1) must be < movie file duration (' num2str(duration_file) ' sec).'])
    end
times(2) = min(times(2), duration_file);
t0 = times(1)+mod(phase, times(2)-times(1));
if speed < 0 && t0 == times(1)
    %If reverse and t0 = start of clip, assume means reverse from end of clip
    t0 = times(2);
end
%Set start time in movie using PTB SetMovieTimeIndex
Screen('SetMovieTimeIndex', n_movie, t0);


%PTB PlayMovie starts movie buffering in memory.
%Movie starts playing later at first GetMovieImage call in runFrame.
Screen('PlayMovie', n_movie, speed, repeat, volume);


this.crop = crop;
this.height = height;
this.n_movie = n_movie;
this.imageInterval_file = imageInterval_file;