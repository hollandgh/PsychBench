fileName = this.fileName;
dataExpr = this.dataExpr;
beepFrequency = this.beepFrequency;
times = this.times;
maxNumLoops = this.maxNumLoops;
breakInterval = this.breakInterval;
phase = this.phase;
speed = this.speed;
volume = this.volume;
n_masterStream = devices.speaker.n_masterStream;


%Load, process sound.
%Maybe slow, so encapsulate in a function and do shared so only computes once 
%for all objects of this type with the same function input values.
%---
[data, sampleRate, maxNumLoops] = element_doShared(@loadSound, fileName, dataExpr, beepFrequency, times, maxNumLoops, devices.speaker.sampleRate, devices.speaker.numChannels);
%---


%If negative speed reverse data, then also speed, phase so can use same algo.
%Also then if phase = 0 and no loops, plays in reverse instead of ends immediately.
if speed < 0
    data = flip(data, 2);
    speed = -speed;
    phase = -phase;
end

%Add silent interval
data = [data zeros(2, round(breakInterval*sampleRate))];

%phase -> samples, wrap to 0 ... numSamples
phase = mod(round(phase*sampleRate), size(data, 2));
data = [data(:,phase+1:end) data(:,1:phase)];

%Open sound stream using PTB PsychPortAudio('OpenSlave')
n_stream = PsychPortAudio('OpenSlave', n_masterStream);

%Fill stream buffer with sound data
PsychPortAudio('FillBuffer', n_stream, data);

%Scale volume
PsychPortAudio('Volume', n_stream, volume);

%Format for PTB PsychPortAudio('Start')
if maxNumLoops == inf
    maxNumLoops = 0;
end


this.maxNumLoops = maxNumLoops;
this.n_stream = n_stream;


%end script




function [data, sampleRate, maxNumLoops] = loadSound(fileName, dataExpr, beepFrequency, times, maxNumLoops, speaker_sampleRate, speaker_numChannels) %local function


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
    times = floor(times*sampleRate);
    times(2) = min(times(2), size(data, 2));
        if ~(times(1) < times(2))
            error(['In property .times: .times(1) must be < .times(2) and sound data duration (' num2str(size(data, 2)/sampleRate) ' sec).'])
        end
    data = data(:,times(1)+1:times(2));
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
    times = floor(times*sampleRate);
    times(2) = min(times(2), size(data, 2));
        if ~(times(1) < times(2))
            error(['In property .times: .times(1) must be < .times(2) and sound file duration (' num2str(size(data, 2)/sampleRate) ' sec).'])
        end
    data = data(:,times(1)+1:times(2));
else
    %Beep

    maxNumLoops = inf;

    sampleRate = speaker_sampleRate;

    %75% volume beep
    data = repmat(0.75*sin(2*pi*beepFrequency*((1:sampleRate)-1)/sampleRate-1), speaker_numChannels, 1);
end


end %loadSound