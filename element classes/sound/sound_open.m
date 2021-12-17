%TODO
%- start time, end time in file
%- sound recording




%==========================================================================
if WITHPTB

    
    
    
%PREPROCESS INPUT PROPERTIES FOR DATA TYPE, UNITS
%---
%Standardize strings from "x"/'x' to 'x'.
this.fileName = var2Char(this.fileName);
this.dataExpr = var2Char(this.dataExpr);
%---


fileName = this.fileName;
dataExpr = this.dataExpr;
beepFrequency = this.beepFrequency;
startTimeInSound = this.startTimeInSound;
speed = this.speed;
repeat = this.repeat;
volume = this.volume;
reportTimeout = this.reportTimeout;
audio = resources.audio;
    

%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isRowChar(dataExpr) || isempty(dataExpr))
    error('Property .dataExpr must be a string or [].')
end
if isempty(dataExpr)
    if ~(isRowChar(fileName) || isempty(fileName))
        error('Property .fileName must be a string or [].')
    end
end
if isempty(dataExpr) && isempty(fileName)
    if ~(isOneNum(beepFrequency) && beepFrequency > 0)
        error('Property .beepFrequency must be a number > 0.')
    end
end

if ~(isOneNum(startTimeInSound) && startTimeInSound >= 0)
    error('Property .startTimeInSound must be a number >= 0.')
end
if ~(isOneNum(speed) && any(speed == [-1 1]))
    error('Property .speed must be 1 or -1.')
end
if ~isTrueOrFalse(repeat)
    error('Property .repeat must be true/false.')
end
if ~(isOneNum(volume) && volume >= 0 && volume <= 1)
    error('Property .volume must be a number between 0-1.')
end
if ~(isOneNum(reportTimeout) && reportTimeout >= 0)
    error('Property .reportTimeout must be a number >= 0.')
end
%---


%Load, process sound.
%Maybe slow, so encapsulate in a function and share so only computes once for
%all objects of the class with the same function input values.
%---
[data, sampleRate, repeat] = element_doShared(@load__processSound_ptb, fileName, dataExpr, beepFrequency, repeat, audio);
%---


%Reverse
if speed < 0
    data = fliplr(data);
end

%Apply start time in sound
    phase = round(startTimeInSound*sampleRate);
        if ~(phase <= size(data, 2))
            error('Property .startTimeInSound must be <= length of sound.')
        end
if speed < 0 && phase > 0
    phase = size(data, 2)-phase;
%if speed < 0 && phase = 0 leave phase = 0 to play whole sound in reverse (special case)
end
if repeat
    data = [data(:,phase+1:end) data(:,1:phase)];
else
    data =  data(:,phase+1:end);
end


this.repeat = repeat;
%data is large, so set shared so only holds one value in memory for all objects
%of the class with the same index property values.
%---
this = element_setShared(this, 'data', data, {'fileName' 'dataExpr' 'beepFrequency' 'repeat'});
%---
this.soundDuration = [];




%==========================================================================
else %WITHMGL




%PREPROCESS INPUT PROPERTIES FOR DATA TYPE, UNITS
%---
%Standardize strings from "x"/'x' to 'x'.
this.fileName = var2Char(this.fileName);
%---


fileName = this.fileName;
    

%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isRowChar(fileName) && ~isempty(fileName))
    error('Property .fileName must be a string.')
end
%---


[data, sampleRate] = element_doShared(@load__processSound_mgl, fileName);

%Get full path + file name even if on MATLAB search path cause mglInstallSound needs it
fileName = whereFile(fileName);

soundDuration = size(data, 2)/sampleRate;


this.fileName = fileName;
this.data = [];
this.soundDuration = soundDuration;




%==========================================================================
end




%end sound_open




function [data, sampleRate, repeat] = load__processSound_ptb(fileName, dataExpr, beepFrequency, repeat, audio) %local function


if ~isempty(dataExpr)
    %Get sound from channels x samples matrix in base workspace

    sampleRate = audio.sampleRate_r;

    try
        data = evalin('base', dataExpr);
    catch X
            error(['In property .dataExpr: Cannot get ' dataExpr ' in the base MATLAB workspace.'])
    end
        if ~(isa(data, 'numeric') && ismatrix(data) && ~isempty(data))
            error(['In property .dataExpr: ' dataExpr ' must be a matrix with channels in rows and samples in columns.'])
        end
elseif ~isempty(fileName)
    %Load sound from file

    try
        [data, sampleRate] = audioread(fileName);
    catch X
            error(['Cannot load ' fileName '.' 10 ...
                '->' 10 ...
                10 ...
                X.message])
    end
    data = transpose(data);
        if sampleRate ~= audio.sampleRate_r
            error(['Sound file sample rate (' num2str(sampleRate) ' Hz) must = device sample rate (currently ' num2str(audio.sampleRate_r) ' Hz). See audio object properties .sampleRate, .n_device.'])
        end
else
    %Beep

    repeat = true;

    sampleRate = audio.sampleRate_r;

    %75% volume beep
    data = repmat(0.75*sin(2*pi*beepFrequency*((1:sampleRate)-1)/sampleRate-1), audio.numChannels, 1);
end

%Mono sound plays on all channels
if size(data, 1) == 1
    data = repmat(data, audio.numChannels, 1);
end
    %This check needed or PTB FillBuffer gives an error
    if ~(size(data, 1) <= audio.numChannels)
        error(['Number of channels in sound file/data (' num2str(size(data, 1)) ') must be <= number of channels open on audio device (currently ' num2str(audio.numChannels) '). See audio object properties .numChannels, .n_device.'])
    end


end %load__processSound




function [data, sampleRate] = load__processSound_mgl(fileName) %local function


%Load sound from file
try
    [data, sampleRate] = audioread(fileName);
catch X
        error(['Cannot load ' fileName '.' 10 ...
            '->' 10 ...
            10 ...
            X.message])
end
data = transpose(data);


end %load__processSound_mgl