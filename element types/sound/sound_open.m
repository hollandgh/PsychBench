%Giles Holland 2022, 23


        %(Handle deprecated)
        %---
        if isfield(this, 'startTimeInSound')
            if ~isempty(this.startTimeInSound)
                this.phase = this.startTimeInSound;
            %else default value in phase
            end
        end
        %---


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Standardize strings from "x"/'x' to 'x'
this.fileName = var2char(this.fileName);
this.dataExpr = var2char(this.dataExpr);
%---


fileName = this.fileName;
dataExpr = this.dataExpr;
beepFrequency = this.beepFrequency;
times = this.times;
speed = this.speed;
repeat = this.repeat;
phase = this.phase;
volume = this.volume;
reportTimeout = this.reportTimeout;
    

%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isRowChar(fileName) || isempty(fileName))
    error('Property .fileName must be a string or [].')
end
if ~(isRowChar(dataExpr) || isempty(dataExpr))
    error('Property .dataExpr must be a string or [].')
end
if ~(isempty(fileName) || isempty(dataExpr))
    error('Only one of properties .fileName and .dataExpr can be set.')
end
if isempty(fileName) && isempty(dataExpr)
    if ~(isOneNum(beepFrequency) && beepFrequency > 0)
        error('Property .beepFrequency must be a number > 0.')
    end
end

if ~(isRowNum(times) && numel(times) == 2 && all(times >= 0))
    error('Property .times must be a 1x2 vector of numbers >= 0.')
end
if ~(isOneNum(speed) && any(speed == [-1 1]))
    error('Property .speed must be 1 or -1.')
end
if ~is01(repeat)
    error('Property .repeat must be true/false.')
end
if ~isOneNum(phase)
    error('Property .phase must be a number.')
end
if ~(isOneNum(volume) && volume >= 0 && volume <= 1)
    error('Property .volume must be a number between 0-1.')
end
if ~(isOneNum(reportTimeout) && reportTimeout >= 0)
    error('Property .reportTimeout must be a number >= 0.')
end
%---


%Tell PsychBench this object will use PortAudio for sound output.
%Opens PortAudio output master stream if not already opened by another object.
%User can specify PortAudio options in pb_prefs() or with a speaker object in their experiment script.
%Returns speaker object with properties containing more info, also available in later type scripts in devices.speaker.
%Replaces PTB InitializePsychSound, PsychPortAudio('Open'), ('Close') for the master stream.
[this, ~, speaker] = element_openSpeaker(this);
speaker_sampleRate = speaker.sampleRate_r;
speaker_numChannels = speaker.numChannels;


%Load, process sound.
%Maybe slow, so encapsulate in a function and do shared so only computes once 
%for all objects of this type with the same function input values.
%---
[data, sampleRate, repeat] = element_doShared(@loadSound, fileName, dataExpr, beepFrequency, times, repeat, speaker_sampleRate, speaker_numChannels);
%---


%If negative speed reverse data, then also speed, phase so can use same algo.
%Also then if phase = 0 and no repeat, plays in reverse instead of ends immediately.
if speed < 0
    data = flip(data, 2);
    speed = -speed;
    phase = -phase;
end

%phase -> samples, wrap to 0 ... numSamples
phase = mod(round(phase*sampleRate), size(data, 2));
if repeat
    data = [data(:,phase+1:end) data(:,1:phase)];
else
    data =  data(:,phase+1:end);
end


%Stimulus start/end will not be locked to frame start/end
this = element_floatStart(this);
this = element_floatEnd(this);


this.repeat = repeat;
%data is large, so set shared so only holds one value in memory for all objects
%of this type with the same type-specific property values set by user
%---
this = element_setShared(this, 'data', data);
%---


%end sound_open




function [data, sampleRate, repeat] = loadSound(fileName, dataExpr, beepFrequency, times, repeat, speaker_sampleRate, speaker_numChannels) %local function


if ~isempty(dataExpr)
    %Get sound from samples x channels matrix in base workspace

    sampleRate = speaker_sampleRate;

    try
        data = evalin('base', dataExpr);
    catch X
            error(['In property .dataExpr: Cannot get ' dataExpr ' in the base MATLAB workspace.'])
    end
        if ~(isa(data, 'numeric') && ismatrix(data) && ~isempty(data))
            error(['In property .dataExpr: ' dataExpr ' must be a matrix with rows corresponding to samples and columns corresponding to channels.'])
        end
    %Transpose for channels x samples convention of PTB FillBuffer
    data = transpose(data);
    
    %Mono sound plays on all channels
    if size(data, 1) == 1
        data = repmat(data, speaker_numChannels, 1);
    end
        %This check needed or PTB FillBuffer gives an error
        if ~(size(data, 1) <= speaker_numChannels)
            error([dataExpr ' must be a matrix with rows corresponding to samples and columns corresponding to channels.' 10 ...
                '(or)' 10 ...
                'Number of channels in data (' num2str(size(data, 1)) ') must be <= number of channels open on sound device (currently ' num2str(speaker_numChannels) '). You can change the sound device or its number of channels to open in pb_prefs() -> speaker tab. Or to change for only this experiment, make a speaker object and set properties .n_device and/or .numChannels.'])
        end
    
    %Trim to time
    times = floor(times*sampleRate)+1;
    times(2) = min(times(2), size(data, 2)+1);
        if ~(times(1) <= size(data, 2))
            error('In property .times: .times(1) must be < sound data duration.')
        end
        if ~(times(1) < times(2))
            error('In property .times: .times(1) must be < .times(2).')
        end
    data = data(:,times(1):times(2)-1);
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
    %Transpose for channels x samples convention of PTB FillBuffer
    data = transpose(data);
    
        if sampleRate ~= speaker_sampleRate
            error(['Sound file sample rate (' num2str(sampleRate) ' Hz) must = device sample rate (currently ' num2str(speaker_sampleRate) ' Hz). You can change the sound device or its sample rate in pb_prefs() -> speaker tab. Or to change for only this experiment, make a speaker object and set properties .n_device and/or .sampleRate. Note different devices can use different sample rates. If you set a sample rate the current device cannot use, Psychtoolbox will give an error.'])
        end
    %Mono sound plays on all channels
    if size(data, 1) == 1
        data = repmat(data, speaker_numChannels, 1);
    end
        %This check needed or PTB FillBuffer gives an error
        if ~(size(data, 1) <= speaker_numChannels)
            error(['Number of channels in sound file/data (' num2str(size(data, 1)) ') must be <= number of channels open on sound device (currently ' num2str(speaker_numChannels) '). You can change the sound device or number of channels to open in pb_prefs() -> speaker tab. Or to change for only this experiment, make a speaker object and set properties .n_device and/or .numChannels.'])
        end
    
    %Trim to time
    times = floor(times*sampleRate)+1;
    times(2) = min(times(2), size(data, 2)+1);
        if ~(times(1) <= size(data, 2))
            error('In property .times: .times(1) must be < file duration.')
        end
        if ~(times(1) < times(2))
            error('In property .times: .times(1) must be < .times(2).')
        end
    data = data(:,times(1):times(2)-1);
else
    %Beep

    repeat = true;

    sampleRate = speaker_sampleRate;

    %75% volume beep
    data = repmat(0.75*sin(2*pi*beepFrequency*((1:sampleRate)-1)/sampleRate-1), speaker_numChannels, 1);
end


end %loadSound