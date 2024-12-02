%Giles Holland 2022-24


        %(Handle deprecated)
        %---
        if isfield(this, 'startTimeInSound')
            if ~isempty(this.startTimeInSound)
                this.phase = this.startTimeInSound;
            %else default value in phase
            end
        end
        if isfield(this, 'repeat')
            if ~isempty(this.repeat)
                if is01(this.repeat)
                    if this.repeat
                        this.maxNumLoops = inf;
                    else
                        this.maxNumLoops = 1;
                    end
                end
            %else default value in maxNumLoops
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
maxNumLoops = this.maxNumLoops;
breakInterval = this.breakInterval;
phase = this.phase;
speed = this.speed;
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
if ~(isOneNum(maxNumLoops) && maxNumLoops > 0)
    error('Property .maxNumLoops must be a number > 0.')
end
if ~(isOneNum(breakInterval) && breakInterval >= 0)
    error('Property .breakInterval must be a number >= 0.')
end
if ~isOneNum(phase)
    error('Property .phase must be a number.')
end
if ~(isOneNum(speed) && any(speed == [-1 1]))
    error('Property .speed must be 1 or -1.')
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


%Stimulus start/end will not be locked to frame start/end
this = element_floatStart(this);
this = element_floatEnd(this);