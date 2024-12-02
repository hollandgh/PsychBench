reportTimeout = this.reportTimeout;
report = this.report;
n_stream = this.n_stream;


if this.ran
    %Object has run...
    
    %Check that sound ended--don't continue to next trial until it has.
    %Mostly in case sound ended at end of trial and using a system with low sound timing precision.
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
            
    %Correct recorded object start time using actual sound start time returned by PsychPortAudio.
    %Note PsychPortAudio GetStatus has 0 if time measurement not available yet.
            startTime = s.StartTime;
    if startTime == 0 && reportTimeout > 0
        while startTime == 0
            if GetSecs >= tx && any(strcmpi(report, 'startTime'))
                warning('Psychtoolbox PortAudio did not report sound start time, so recorded sound object start time is only approximate. If this doesn''t matter for your experiment you can set property .reportTimeout = 0 to disable this warning.')
                break
            end
            %Wait 1 frame (at 60 Hz) and try again
            WaitSecs(1/60);
            s = PsychPortAudio('GetStatus', n_stream);
            startTime = s.StartTime;
        end
    end
    if startTime > 0
        this = element_correctStartTime(this, startTime);
    end

    %Correct recorded object end time using actual sound start time returned by PortAudio
            endTime = s.EstimatedStopTime;
    if endTime == 0 && reportTimeout > 0
        while endTime == 0
            if GetSecs >= tx && (any(strcmpi(report, 'endTime')) || any(strcmpi(report, 'duration')))
                warning('Psychtoolbox PortAudio did not report sound end time, so recorded sound object end time is only approximate. If this doesn''t matter for your experiment you can set property .reportTimeout = 0 to disable this warning.')
                break
            end
            WaitSecs(1/60);
            s = PsychPortAudio('GetStatus', n_stream);
            endTime = s.EstimatedStopTime;
        end
    end
    if endTime > 0
        this = element_correctEndTime(this, endTime);
    end
end


%Close sound stream using PTB PsychPortAudio('Close')
PsychPortAudio('Close', n_stream)