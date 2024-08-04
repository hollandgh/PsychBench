%Giles Holland 2022, 23


        %(Handle deprecated)
        %---
        if isfield(this, 'mask')
            if ~isempty(this.mask)
                %mask ignored, treated as crop
                this.crop = this.mask;
            %else default value in crop
            end
        end
        if isfield(this, 'startTimeInMovie')
            if ~isempty(this.startTimeInMovie)
                this.phase = this.startTimeInMovie;
            %else default value in phase
            end
        end
        %---


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.height = element_deg2px(this.height);

%Standardize strings from "x"/'x' to 'x'
this.fileName = var2char(this.fileName);
this.height = var2char(this.height);
%---


fileName = this.fileName;
crop = this.crop;
height = this.height;
times = this.times;
speed = this.speed;
repeat = this.repeat;
phase = this.phase;
grayscale = this.grayscale;
volume = this.volume;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isRowChar(fileName) && ~isempty(fileName))
    error('Property .fileName must be a string.')
end

crop = round(crop);
if ~(isRowNum(crop) && numel(crop) == 4 && all(crop >= 0) && all(crop(1:2) < crop(3:4)))
    error('Property .crop must be a 1x4 vector with numbers >= 0, and (1) < (3) and (2) < (4).')
end
this.crop = crop;

if ~(isOneNum(height) && height > 0 || isa(height, 'char') && strisini(height, {'fit' 'fitw' 'fith' 'fill' 'px'}))
    error('Property .height must be a number > 0, or a string "fit", "fitw", "fith", "fill", or "px".')
end
if ~(isRowNum(times) && numel(times) == 2 && times(1) >= 0 && times(2) > times(1))
    error('Property .times must be a 1x2 vector with (1) >= 0 and (2) > (1).')
end
if ~(isOneNum(speed) && speed ~= 0)
    error('Property .speed must be a number not = 0.')
end

if ~(is01(repeat) || isOneNum(repeat, 'numeric') && any(repeat == [2 1+4 1+8 1+4+8]))
    error('Property .repeat must be true/false. Or it can be a number--see Psychtoolbox Screen(''PlayMovie?'').')
end
if repeat > 0
    if ~isequaln(times, [0 inf])
        error('Currently if property .repeat = true, .times cannot be set.')
    end
end

if ~isOneNum(phase)
    error('Property .phase must be a number.')
end
if ~is01(grayscale)
    error('Property .grayscale must be true/false.')
end
if ~(isOneNum(volume) && volume >= 0 && volume <= 1)
    error('Property .volume must be a number between 0-1.')
end
%---


%Get full path + file name even if user set a relative path or just a file name on MATLAB search path (PTB OpenMovie needs full path).
%Returns [] if file does not exist or is just a file name but not on MATLAB search path.
pathfileName = whereFile(fileName);
    if isempty(pathfileName)
        error([fileName ' does not exist or is not on the MATLAB search path.'])
    end
    
%Format true/false to numeric for PTB PlayMovie
repeat = double(repeat);


this.fileName = pathfileName;
this.repeat = repeat;

%Initialize some record properties for first iteration of runFrame
this.n_texture = [];
this.lastTextureEndTime = [];