if this.isStarting
    %OBJECT FRAME 0
    %Object starting at frame end (frame 1 start)
    %===
    

    portName = this.portName;
    options = this.options;


    %Open port.
    %element_openSerialPort uses PTB IOPort('OpenSerialPort').
    [this, n_port] = element_openSerialPort(this, portName, options);
    % %TEST
    % n_port = 1;


    this.n_port = n_port;
    
    
else
    %OBJECT FRAME 1
    %Object runs for one frame, then ends on its own
    %===


    n_port = this.n_port;
    data = this.data;


    %Send data from port, wait til send complete, get number of bytes sent, system time sent, error message if any
    [n, t, XMSg] = IOPort('Write', n_port, data, 1);
        if ~(n == numel(data) && isempty(XMsg))
            error(['Error sending data.' 10 ...
                '->' 10 ...
                10 ...
                XMSg])
        end
    % %TEST
    % t = GetSecs;

    %Register trigger so user can start/end elements and sync experiment from precise send time, 
    %not just this element end time
    %Trigger value is data sent.
    %Trigger time is time send complete.
    this = element_registerTrigger(this, data, t);

    %END OBJECT ON ITS OWN
    this = element_end(this);
end


%PsychBench automatically closes serial port when object ends