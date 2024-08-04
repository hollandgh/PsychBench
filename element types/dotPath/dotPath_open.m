%Giles Holland 2022, 23


        %(Handle deprecated)
        %---
        if isfield(this, 'startTimeInPath')
            if ~isempty(this.startTimeInPath)
                this.phase = this.startTimeInPath;
            %else default value in phase
            end
        end
        %---


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.height = element_deg2px(this.height);
this.sizeMult = element_deg2px(this.sizeMult);
this.dotSize = element_deg2px(this.dotSize);

%Standardize strings from "x"/'x' to 'x'
this.fileName = var2char(this.fileName);
this.dataExpr = var2char(this.dataExpr);
%---


fileName = this.fileName;
dataExpr = this.dataExpr;
fps = this.fps;
height = this.height;
sizeMult = this.sizeMult;
dotSize = this.dotSize;
color = this.color;
times = this.times;
showTimes = this.showTimes;
speed = this.speed;
repeat = this.repeat;
breakInterval = this.breakInterval;
phase = this.phase;
n_window = this.n_window;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isRowChar(fileName) || isempty(fileName))
    error('Property .fileName must be a string or [].')
end
if ~isempty(fileName)
    [~, ~, e] = fileparts(fileName);
    if isempty(e)
        fileName = [fileName '.mat'];
    elseif ~strcmpi(e, '.mat')
        error('In property .fileName: Must be a .mat file.')
    end
    this.fileName = fileName;
end

if ~(isRowChar(dataExpr) || isempty(dataExpr))
    error('Property .dataExpr must be a string or [].')
end

if ~(~isempty(fileName) || ~isempty(dataExpr))
    error('One of properties .fileName or .dataExpr must be set.')
end

if ~(isOneNum(fps) && fps > 0)
    error('Property .fps must be a number > 0.')
end

    if ~(~isempty(height) || ~isempty(sizeMult))
        error('One of properties .height or .sizeMult must be set.')
    end
if ~isempty(sizeMult)
    if ~(isOneNum(sizeMult) && sizeMult > 0)
        error('Property .sizeMult must be a number > 0, or [].')
    end
else
    if ~(isOneNum(height) && height > 0)
        error('Property .height must be a number > 0, or [].')
    end
end

if ~(isOneNum(dotSize) && dotSize > 0)
    error('Property .dotSize must be a number > 0.')
end
if ~isRgb1(color)
    error('Property .color must be a 1x3 vector with numbers between 0-1.')
end
if ~(isRowNum(times) && numel(times) == 2 && all(times >= 0))
    error('Property .times must be a 1x2 vector of numbers >= 0.')
end
if ~(isRowNum(showTimes) && numel(showTimes) == 2 && all(showTimes >= 0))
    error('Property .showTimes must be a 1x2 vector of numbers >= 0.')
end
if ~isOneNum(speed)
    error('Property .speed must be a number.')
end
if ~is01(repeat)
    error('Property .repeat must be true/false.')
end
if ~(isOneNum(breakInterval) && breakInterval >= 0)
    error('Property .breakInterval must be a number >= 0.')
end
if ~isOneNum(phase)
    error('Property .phase must be a number.')
end
%---


    if dotSize > 0
        [minDotSize, maxDotSize] = Screen('DrawDots', n_window);
        if ~(dotSize >= minDotSize && dotSize <= maxDotSize)
            error(['In property .dotSize: ' num2str(dotSize) ' px is out of range. On your system dots must be between ' num2str(minDotSize) '-' num2str(maxDotSize) ' px.'])
        end
    end


%Load data.
%Encapsulate in a function and share so only computes once for all objects of
%this type with the same function input values. 
%---
data = element_doShared(@loadData, fileName, dataExpr, fps, times);
%---


%Size
siz = row(max(data, [], 2)-min(data, [], 2));
if isempty(sizeMult)
        %Scale height to .height
        sizeMult = height/siz(2);
    if sizeMult == inf
        %Height = 0 -> fall back to scale width to .height
        sizeMult = height/siz(1);
    end
    if sizeMult == inf
        %Both width, height = 0 -> no scaling needed
        sizeMult = 1;
    end
%else user set size multiplier for data units -> deg visual angle directly in .sizeMult
end
data = sizeMult*data;
siz = sizeMult*siz;


%Trim to times to show after using all loaded times for centering and sizing
showTimes = floor(showTimes*fps)+1;
showTimes(2) = min(showTimes(2), size(data, 2)+1);
    if ~(showTimes(1) <= size(data, 2))
        error('In property .showTimes: .showTimes(1) must be < loaded dot path duration.')
    end
    if ~(showTimes(1) < showTimes(2))
        error('In property .showTimes: .showTimes(1) must be < .showTimes(2).')
    end
data = data(:,showTimes(1):showTimes(2)-1);

numImages = size(data, 2);

%If negative speed reverse data, then also speed, phase so can use same algo in frames.
%Also then if phase = 0 and no repeat, plays in reverse instead of ends immediately.
if speed < 0
    data = flip(data, 2);
    speed = -speed;
    phase = -phase;
end

%phase -> images, wrap to 0 ... numImages
phase = mod(phase*fps, numImages);

%Number of images with repeat break.
%Scale by speed so break interval stays as set in sec for speeds ~= 1 given algo in runFrames.
numImagesWithBreak = numImages+round(breakInterval*fps*speed);


%Size of texture we will draw to.
%Sized to fit dot path + padding = dotSize on each side, then dot won't be clipped when at edge.
%(dotSize/2 padding would be sufficient in theory but we use dotSize to be safe and for simplicity.)
textureSize = siz+2*dotSize;


%Translate data from centered at [0 0] -> centered on texture
data = data+repmat(transpose((textureSize+1)/2), [1 size(data, 2)]);



this.speed = speed;
this.phase = phase;
this.data = data;
this.numImages = numImages;
this.numImagesWithBreak = numImagesWithBreak;
this.textureSize = textureSize;




function data = loadData(fileName, dataExpr, fps, times) %local


%Load data
%---
if ~isempty(fileName)
    %Load from file
        
    try
        s = load(fileName);
    catch X
            error(['In property .fileName: Cannot load ' fileName '.' 10 ...
                '->' 10 ...
                10 ...
                X.message])
    end
    
    varNames = row(fieldnames(s));
    if isempty(dataExpr) && numel(varNames) == 1
        %One variable in file and no data expr set -> take variable
        
            data = s.(varNames{1});
    else
        %More than one variable in file or data expr set -> apply data expr to get data set
        
                if isempty(dataExpr)
                    error([fileName ' contains more than one variable. You must specify variable name in property .dataExpr.'])
                end
            i = min([find(ismember(dataExpr, '({.'), 1) length(dataExpr)+1]);
            dataVarName = dataExpr(1:i-1);
            dataIndexes = dataExpr(i:end);
                if ~any(strcmp(dataVarName, fieldnames(s)))
                    error(['Variable "' dataVarName '" does not exist in ' fileName '.'])
                end
            dataVar = s.(dataVarName); %#ok<NASGU>
        try
            data = eval(['dataVar' dataIndexes]);
        catch X
                error(['In property .dataExpr: Cannot get ' dataExpr ' in ' fileName '.' 10 ...
                    '->' 10 ...
                    10 ...
                    X.message])
        end
    end
else
    %Load from base workspace
    
    try
        data = evalin('base', dataExpr);
    catch X
            error(['In property .dataExpr: Cannot get ' dataExpr ' in the base MATLAB workspace.'])
    end
end

%Data is coords (x, y) x images
    if ~(isa(data, 'numeric') && ismatrix(data) && size(data, 1) == 2 && ~isempty(data))
        error('Data must be an 2xn matrix.')
    end
%---


%Trim to time
times = floor(times*fps)+1;
times(2) = min(times(2), size(data, 2)+1);
    if ~(times(1) <= size(data, 2))
        error('In property .times: .times(1) must be < dot path duration.')
    end
    if ~(times(1) < times(2))
        error('In property .times: .times(1) must be < .times(2).')
    end
data = data(:,times(1):times(2)-1);

numImages = size(data, 2);


%Standardize center data at [x y] = [0 0]
data = data-repmat(mean([min(data, [], 2) max(data, [], 2)], 2), 1, numImages);


end %loadData