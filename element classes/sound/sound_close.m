%==========================================================================
if WITHPTB

    
    
    
reportTimeout = this.reportTimeout;
n_stream = this.n_stream;


if this.ran
    %Object ran...
    
    %Check that sound has ended--don't continue to next trial until it has.
    %Mostly in case sound ended at end of trial and using a system with low sound timing precision.
        s = PsychPortAudio('GetStatus', n_stream);
    t = GetSecs+10;
    while ~(~s.Active && s.ElapsedOutSamples > 0)
            if GetSecs > t
                error('PortAudio did not report sound start or end -> halting to prevent hang.')
            end
        WaitSecs(1/60);
        s = PsychPortAudio('GetStatus', n_stream);
    end  

    %Correct recorded object start time using actual sound start time returned by PsychPortAudio.
    %Note PsychPortAudio GetStatus has 0 if time measurement not available yet.
            s = PsychPortAudio('GetStatus', n_stream);
            startTime = s.StartTime;
    if startTime == 0 && reportTimeout > 0
        while startTime == 0
            if GetSecs-trial.endTime > reportTimeout
                warning('PortAudio did not report sound start time, so recorded start time is approximate. If this doesn''t matter for your experiment you can set property .reportTimeout = 0 to disable this warning.')
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
            s = PsychPortAudio('GetStatus', n_stream);
            endTime = s.EstimatedStopTime;
    if endTime == 0 && reportTimeout > 0
        while endTime == 0
            if GetSecs-trial.endTime > reportTimeout
                warning('PortAudio did not report sound end time, so recorded end time is approximate. If this doesn''t matter for your experiment you can set property .reportTimeout = 0 to disable this warning.')
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


%Close sound stream
PsychPortAudio('Close', n_stream)




%==========================================================================
else %WITHMGL




%Close sound stream
mglDeleteSound(this.n_stream)




%==========================================================================
end