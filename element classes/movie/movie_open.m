%SYNC START (NO AUDIO) METHOD
%In normal (audio) method, movie audio start time is not precisely specified or
%measured--it occurs after the first Screen('GetMovieImage') call with some
%minimal latency, not precisely at next frame start / screen refresh when the
%display starts. To precisely sync movie time course with display start time,
%user can set volume = 0 to disable movie audio. Object can then take movie
%course start time = display start time, and manually times all image changes
%based on that using their times in the movie time course. To do this, need to
%open the movie in asynchronous mode so Screen('GetMovieImage') can return
%textures ahead of time, not dependent on real time, and never skip them.


%PREPROCESS INPUT PROPERTIES FOR DATA TYPE, UNITS
%---
%Standardize strings from "x"/'x' to 'x'.
this.fileName = var2Char(this.fileName);
this.height = var2Char(this.height);

%Convert deg units to px
this.height = element_deg2px(this.height);
%---


fileName = this.fileName;
height = this.height;
startTimeInMovie = this.startTimeInMovie;
speed = this.speed;
repeat = this.repeat;
volume = this.volume;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isRowChar(fileName) && ~isempty(fileName))
    error('Property .fileName must be a string.')
end
if ~(isOneNum(height) && height > 0 || isa(height, 'char') && strcmpi(height, 'f'))
    error('Property .height must be a number > 0, or the string "f".')
end
if ~(isOneNum(startTimeInMovie) && startTimeInMovie >= 0)
    error('Property .startTimeInMovie must be a number >= 0.')
end
if ~(isOneNum(speed) && speed ~= 0)
    error('Property .speed must be a number not = 0.')
end
if ~(isTrueOrFalse(repeat) || isOneNum(repeat, 'numeric') && any(repeat == [2 1+4 1+8 1+4+8]))
    error('Property .repeat must be true/false. Or it can be a number--see Psychtoolbox Screen(''PlayMovie?'').')
end
if ~(isOneNum(volume) && volume >= 0 && volume <= 1)
    error('Property .volume must be a number between 0-1.')
end
%---


%Get full path + file name even if user set a relative path or just a file name on MATLAB search path (PTB OpenMovie needs full path).
%Returns [] if file does not exist or is just a file name but not on MATLAB search path.
pathAndFileName = whereFile(fileName);
    if isempty(pathAndFileName)
        error(['Cannot find file ' fileName '.'])
    end
    
%Format true/false to numeric for PTB PlayMovie
if ~repeat
    repeat = [];
else
    repeat = double(repeat);
end


this.pathAndFileName = pathAndFileName;
this.repeat = repeat;

%Initialize some record properties for runFrame
this.n_texture = [];
this.n_nextTexture = [];
this.nextTextureTime = [];
this.lastTextureEndTime = [];