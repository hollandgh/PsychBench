pathAndFileName = this.pathAndFileName;
height = this.height;
startTimeInMovie = this.startTimeInMovie;
speed = this.speed;
repeat = this.repeat;
volume = this.volume;
n_window = this.n_window;
windowSize = resources.screen.windowSize;
frameInterval = experiment.frameInterval;


%Open movie from file using PTB OpenMovie

%In openAtTrial instead of open cause Psychtoolbox holding movies open could use
%significant resources, so only hold for each object during its trial instead of
%for all objects at same time at experiment startup.
if volume == 0
    %SYNC START METHOD (NO AUDIO)
    %No audio, asynchronous / manual timing
    
    [n_movie, length_file, fps_file, width_file, height_file] = Screen('OpenMovie', n_window, pathAndFileName, 4, [], 2);
else
    %AUDIO METHOD
    %Normal auto timing
    
    [n_movie, length_file, fps_file, width_file, height_file] = Screen('OpenMovie', n_window, pathAndFileName);
end

%If reverse movie from start and not repeat set time at end of movie else will end immediately
    if ~(startTimeInMovie <= length_file)
        error(['Property .startTimeInMovie must be <= length of file (' num2str(length_file) ' sec).'])
    end
if speed < 0 && startTimeInMovie == 0
    startTimeInMovie = length_file;
%if speed < 0 && startTimeInMovie == 0 set startTimeInMovie = length to play whole movie in reverse (special case)
end

%Movie image interval
if fps_file > 0
    imageInterval_file = 1/fps_file;
else
    %Use experiment frame interval if fps_file fails
    imageInterval_file = frameInterval;
end

%Set display dimensions
if      strcmpi(height, 'f')
    %Fit to screen
    siz_file = [width_file height_file];
    siz = siz_file*min(windowSize./siz_file);
    height = siz(2);
end

    
%Set start time in movie using PTB SetMovieTimeIndex
Screen('SetMovieTimeIndex', n_movie, startTimeInMovie);

%PTB PlayMovie starts movie buffering in memory.
%Movie actually starts playing later in runFrame script.
Screen('PlayMovie', n_movie, speed, repeat, volume);


this.height = height;
this.startTimeInMovie = startTimeInMovie;
this.n_movie = n_movie;
this.imageInterval_file = imageInterval_file;