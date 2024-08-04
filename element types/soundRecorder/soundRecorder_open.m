%Giles Holland 2022


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Standardize strings from "x"/'x' to 'x'
this.fileName = var2char(this.fileName);
%---


fileName = this.fileName;
numberFile = this.numberFile;
minNumDigitsInFileName = this.minNumDigitsInFileName;
bitDepth = this.bitDepth;
bitRate = this.bitRate;
reportTimeout = this.reportTimeout;
    

%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isRowChar(fileName) && any(fileName(1:end-1) == '.'))
    error('Property .fileName must be a string including file extension.')
end

if ~is01(numberFile)
    error('Property .numberFile must be true/false.')
end
if numberFile
    if ~(isOneNum(minNumDigitsInFileName) && isIntegerVal(minNumDigitsInFileName) && minNumDigitsInFileName > 0)
        error('Property .minNumDigitsInFileName must be an integer > 0.')
    end
end

if      strcmpi(fileName(end-3:end), '.wav') || strcmpi(fileName(end-4:end), '.flac')
    if ~(isOneNum(bitDepth) && ismember(bitDepth, [8 16 24 32 64]))
        error('Property .bitDepth must be 8, 16, 24, 32, 64.')
    end
elseif  any(strcmpi(fileName(end-3:end), {'.m4a' '.mp4'}))
    if ~(isOneNum(bitRate) && bitRate > 0)
        error('Property .bitRate must be a number > 0.')
    end
end

if ~(isOneNum(reportTimeout) && reportTimeout >= 0)
    error('Property .reportTimeout must be a number >= 0.')
end
%---


%Make folder for sound file if doesn't exist
[path, ~, ~] = fileparts(fileName);
[~, x] = whereFile(path);
if isempty(x)
    try
        [tf, XMsg] = mkdir(path); if ~tf, error(XMsg), end
    catch X
            error(['Cannot make folder ' path '.' 10 ...
                '->' 10 ...
                10 ...
                X.message])
    end
    
elseif ~numberFile
        %Check if exists at experiment start cause better to error then than part way through experiment.
        %Will re-check in close script in case file gets created by something else before then.
        if ~isempty(whereFile(fileName))
            error([fileName ' already exists.'])
        end

%elseif numberFile = true then numbers file to not overwrite    
end


%Tell PsychBench this object will use PortAudio for sound input.
%Opens PortAudio input master stream if not already opened by another object.
%User can specify PortAudio options in pb_prefs() or with a microphone object in their experiment script.
%microphone object with properties containing info available in later type scripts in devices.microphone.
%Replaces PTB InitializePsychSound, PsychPortAudio('Open'), ('Close') for the master stream.
this = element_openMicrophone(this);


%Sound input start/end will not be locked to frame start/end
this = element_floatStart(this);
this = element_floatEnd(this);


%Initialize some record properties for first iteration of runFrame
this.t_prev = [];
this.data = [];