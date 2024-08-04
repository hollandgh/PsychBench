n_stream = this.n_stream;
t_prev = this.t_prev;
isStarting = this.isStarting;
isEnding = this.isEnding;


if      isStarting
    %OBJECT FRAME 0
    %Object starting at next frame start (frame 1 start)
    %===
    
    %Start sound input (immediate--can't set a start time for input)
    PsychPortAudio('Start', n_stream);
    t_prev = GetSecs;
        
    
else
    %OBJECT RUNNING
    %===
    
    if 	isEnding
        %LAST OBJECT FRAME
        %Object running but ending at frame end at cue set by user
        %===

        %Get any remaining sound data from buffer
        %[audiodata absrecposition overflow cstarttime] = PsychPortAudio('GetAudioData', pahandle [, amountToAllocateSecs][, minimumAmountToReturnSecs][, maximumAmountToReturnSecs][, singleType=0]);
        d = PsychPortAudio('GetAudioData', n_stream);
        this.data = [this.data d];

        %End sound input (immediate--can't set an end time for input)
        %[startTime endPositionSecs xruns estStopTime] = PsychPortAudio('Stop', pahandle [,waitForEndOfPlayback=0] [, blockUntilStopped=1] [, repetitions] [, stopTime]);
        PsychPortAudio('Stop', n_stream, [], 0);
        
        
    else
        %Get to clear input buffer every 8 sec (80% of 10 sec buffer)
        t = GetSecs;
        if t-t_prev > 8
            d = PsychPortAudio('GetAudioData', n_stream);
            this.data = [this.data d];
            t_prev = t;
        end
        
        
    end
end


this.t_prev = t_prev;