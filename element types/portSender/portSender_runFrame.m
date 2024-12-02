if ~this.isStarting
    %OBJECT FRAME 1
    %Object runs for one frame, then ends on its own
    %===


    n_port = this.n_port;
    data = this.data;


    %Send data from port, wait til send complete with priority blocking, get number of bytes sent, system time sent, error message if any
    %using PTB IOPort('Write')
    %[TEST OUT]
    [n, t, XMSg] = IOPort('Write', n_port, data, 2);
        if ~(n == numel(data) && isempty(XMsg))
            error(['Error sending data.' 10 ...
                '->' 10 ...
                10 ...
                XMSg])
        end
%     %[TEST]
%     t = GetSecs;

    %Register trigger so user can start/end elements and sync experiment from precise send time, 
    %not just this element end time
    %Trigger value is data sent.
    %Trigger time is time send complete.
    this = element_registerTrigger(this, data, t);

    %END OBJECT ON ITS OWN
    this = element_end(this);
end