fileName = this.fileName;
numberFile = this.numberFile;
minNumDigitsInFileName = this.minNumDigitsInFileName;
bitDepth = this.bitDepth;
bitRate = this.bitRate;
reportTimeout = this.reportTimeout;
report = this.report;
n_stream = this.n_stream;
data = this.data;
sampleRate = devices.microphone.sampleRate_r;


if this.ran
    %Object ran...
    
    
    %Check sound input has ended--don't continue to next trial until it has.
    %Mostly in case input ended at end of trial and using a system with low sound timing precision.
        s = PsychPortAudio('GetStatus', n_stream);
            tx = trial.endTime+10;
    while s.Active
            if GetSecs >= tx
                error('Psychtoolbox PortAudio is not responding.')
            end
        WaitSecs(1/60);
        s = PsychPortAudio('GetStatus', n_stream);
    end  

            tx = trial.endTime+reportTimeout;
            
    %Correct recorded object start time using actual sound input start time returned by PsychPortAudio.
    %Note PsychPortAudio GetStatus has 0 if time measurement not available yet.
            startTime = s.CaptureStartTime;
    if startTime == 0 && reportTimeout > 0
        while startTime == 0
            if GetSecs >= tx && any(strcmpi(report, 'startTime'))
                warning('Psychtoolbox PortAudio did not report sound input start time, so recorded soundRecorder object start time is only approximate. If this doesn''t matter for your experiment you can set property .reportTimeout = 0 to disable this warning.')
                break
            end
            %Wait 1 frame (at 60 Hz) and try again
            WaitSecs(1/60);
            s = PsychPortAudio('GetStatus', n_stream);
            startTime = s.CaptureStartTime;
        end
    end
    if startTime > 0
        this = element_correctStartTime(this, startTime);
    end

    
    if numberFile
        %Auto number file name starting at 1, incrementing to not overwrite existing files.
        %Apply minNumDigitsInFileName.
        [p, fileNameBase, e] = fileparts(fileName);
            n_file = 1;
            pf = fullfile(p, [fileNameBase sprintf(['%0' num2str(minNumDigitsInFileName) '.0f'], n_file) e]);
        while ~isempty(whereFile(pf))
            n_file = n_file+1;
            pf = fullfile(p, [fileNameBase sprintf(['%0' num2str(minNumDigitsInFileName) '.0f'], n_file) e]);
        end
        fileName = pf;
    else
            n_file = [];
                if ~isempty(whereFile(fileName))
                    error([fileName ' already exists.'])
                end
    end
    
    %Recorded file name = file name without path
    [~, f, e] = fileparts(fileName);
    fileName_r = [f e];
    fileName_r = string(fileName_r);
    
    
    %Write data to file
    %---
    %Tranpose to MATLAB sound data format (channels in cols)
    data = transpose(data);
    
    try
        if      strcmpi(fileName(end-3:end), '.wav') || strcmpi(fileName(end-4:end), '.flac')
            audiowrite(fileName, data, sampleRate, 'BitsPerSample', bitDepth)
        elseif  any(strcmpi(fileName(end-3:end), {'.m4a' '.mp4'}))
            audiowrite(fileName, data, sampleRate, 'BitRate', bitRate)
        else
            audiowrite(fileName, data, sampleRate)
        end
    catch X
            error(['Error from MATLAB writing sound file.' 10 ...
                '->' 10 ...
                10 ...
                X.message])
    end
    %---
else
    fileName_r = [];
    n_file = [];    
end


%Close sound stream using PTB PsychPortAudio('Close')
PsychPortAudio('Close', n_stream)


this.fileName_r = fileName_r;
this.n_file = n_file;