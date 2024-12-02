%Giles Holland 2022-24


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
        if isfield(this, 'repeat')
            if ~isempty(this.repeat)
                if is01(this.repeat) || isOneNum(this.repeat)
                    if this.repeat >= 1
                        this.maxNumLoops = inf;
                        this.loopMode = double(this.repeat);
                    else
                        this.maxNumLoops = 1;
                    end
                end
            %else default values in maxNumloops, loopMode
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
maxNumLoops = this.maxNumLoops;
phase = this.phase;
loopMode = this.loopMode;
speed = this.speed;
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
if ~(isRowNum(times) && numel(times) == 2 && all(times >= 0))
    error('Property .times must be a 1x2 vector with numbers >= 0.')
end
if ~(isOneNum(maxNumLoops) && maxNumLoops > 0)
    error('Property .maxNumLoops must be a number > 0.')
end
if ~isOneNum(phase)
    error('Property .phase must be a number.')
end
if ~isOneNum(loopMode)
    error('Property .loopMode must be a number.')
end
if ~(isOneNum(speed) && speed ~= 0)
    error('Property .speed must be a number not = 0.')
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


this.fileName = pathfileName;

%Initialize some record properties for first iteration of runFrame
this.n_texture = [];
this.lastTextureEndTime = [];