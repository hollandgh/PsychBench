nn_listenButtons = this.nn_listenButtons;
n_pad = this.n_pad;
t0 = this.t0;
isStarting = this.isStarting;


if isStarting
    %OBJECT FRAME 0
    %Object starting at next frame start (frame 1 start)
    %===
    
    %[TEST OUT]
    %Clear any button presses in queue since last object used this pad using PTB CedrusResponseBox('FlushEvents').
    %From PTB source code: ClearQueues is slow (0.5 s) and waits for signals that are coming but not queued yet / FlushEvents is fast and just clears.
    CedrusResponseBox('FlushEvents', n_pad);


else
    %OBJECT RUNNING
    %===
    
    %Check for one or more button presses since last iteration of _runFrame using PTB CedrusResponseBox('GetButtons')
            ss = [];
    while true
            %[TEST OUT]
            s = CedrusResponseBox('GetButtons', n_pad);
%             %[TEST]
%             s.port = 0;
%             s.action = 1;
%             s.button = 5;
%             s.rawtime = GetSecs-t0;
        if isempty(s)
            break
        else
            ss = [ss s];
%             %[TEST]
%             break
        end
    end
    if ~isempty(ss)
        ss = ss([ss(:).port] == 0 & [ss(:).action] == 1 & ismember([ss(:).button], nn_listenButtons));
        for s = ss
            %Listened button pressed -> register response.
            %Also ends object at end of this frame if maximum number responses registered.
            %If max num responses reached and call element_registerResponse again in this loop, just does nothing.
            %Alternatively registers trigger if user set .registerTrigger = true.

            n_buttonPressed = s.button;
            
            %press time rel pad base time + pad base time rel GetSecs = press time rel GetSecs
            t = s.rawtime+t0;

            this = element_registerResponse(this, n_buttonPressed, t);
        end
    end
end