%==========================================================================
if WITHPTB

    
    
    
repeat = this.repeat;
n_stream = this.n_stream;
startTime = this.startTime;
endTime = this.endTime;
isStarting = this.isStarting;
isEnding = this.isEnding;


if      isStarting
    %OBJECT FRAME 0
    %Object starting at frame end / frame 1 start (this.startTime)
    %===
    
    if repeat
        %startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
        PsychPortAudio('Start', n_stream, 0, startTime);
    else
        PsychPortAudio('Start', n_stream, 1, startTime);
    end
        
    
elseif 	isEnding
    %LAST OBJECT FRAME
    %Object running but ending at frame end (this.endTime) based on cue set by user
    %===

    %[startTime endPositionSecs xruns estStopTime] = PsychPortAudio('Stop', pahandle [,waitForEndOfPlayback=0] [, blockUntilStopped=1] [, repetitions] [, stopTime]);
    PsychPortAudio('Stop', n_stream, 3, 0, [], endTime);
    
    
else
    %OBJECT FRAMES 1+ EXCEPT LAST FRAME ABOVE
    %Object running
    %===
    
    s = PsychPortAudio('GetStatus', n_stream);
        %Check samples played too in case hasn't started yet due to latency
    if ~s.Active && s.ElapsedOutSamples > 0
        %Sound output ended -> END OBJECT ON ITS OWN
        this = element_end(this);
    end
    
    
end




%==========================================================================
else %WITHMGL



    
n_stream = this.n_stream;
soundDuration = this.soundDuration;
startTime = this.startTime;
isStarting = this.isStarting;
nextFrameTime = trial.nextFrameTime;


if isStarting
    %OBJECT FRAME 0
    %Object starting at frame end / frame 1 start
    %===
    
    mglPlaySound(n_stream)
        
    
else
    %OBJECT FRAMES 1+
    %Object running
    %===
    
    %In MGL can't end sound output or check whether sound output has ended, so
    %just end object when sound approximately expected to end based on duration
    %from sound file.
    %Assume sound started at object start time (frame 0 end / frame 1 start).
    if nextFrameTime > startTime+soundDuration
        %END OBJECT ON ITS OWN
        this = element_end(this);
    end
    
    
end




%==========================================================================
end