maxNumLoops = this.maxNumLoops;
n_stream = this.n_stream;
startTime = this.startTime;
endTime = this.endTime;
isStarting = this.isStarting;
isEnding = this.isEnding;


if      isStarting
    %OBJECT FRAME 0
    %Object starting at next frame start (frame 1 start)
    %===
    
    %Start sound output using PTB PsychPortAudio('Start').
    %startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
    PsychPortAudio('Start', n_stream, maxNumLoops, startTime);
        
    
elseif 	~isEnding
    %OBJECT RUNNING EXCEPT LAST FRAME
    %===
    
    s = PsychPortAudio('GetStatus', n_stream);
        %Check samples played too in case hasn't started yet due to latency
    if ~s.Active && s.ElapsedOutSamples > 0
        %Sound output ended -> END OBJECT ON ITS OWN
        this = element_end(this);
    end
    
    
else
    %LAST OBJECT FRAME
    %Object running but ending at frame end (this.endTime) at cue set by user
    %===

    %[startTime endPositionSecs xruns estStopTime] = PsychPortAudio('Stop', pahandle [,waitForEndOfPlayback=0] [, blockUntilStopped=1] [, repetitions] [, stopTime]);
    PsychPortAudio('Stop', n_stream, 3, 0, [], endTime);
    
    
end