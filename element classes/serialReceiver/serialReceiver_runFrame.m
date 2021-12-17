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
    %OBJECT FRAMES 1+
    %Object running
    %===


    n_port = this.n_port;
    numBytes = this.numBytes;
    listenData = this.listenData;
    data = this.data;
    dataTime = this.dataTime;


    %Check for data in port's input buffer and system time received.
    %d is numeric byte values.
    [d, t] = IOPort('Read', n_port);
    % %TEST
    % d = [35 36];
    % t = GetSecs;

    if ~isempty(d)
        %Data available -> add to record    
        data =     [data     d];
        dataTime = [dataTime repmat(t, 1, numel(d))];

                        done = false;
        if ~isempty(listenData)
            for l = listenData, l = l{1};
                if any(d == l(end))
                    data_c = char(data);
                    l_c = char(l);
                    ii = strfind(data_c, l_c);
                    if ~isempty(ii)
                        %Data to wait for received

                        %Cut to data to wait for
                        jj = ii(1):length(l)+ii(1)-1;
                        data = data(jj);
                        dataTime = dataTime(jj);

                        done = true;
                        break
                    end
                end
            end
        else
                    if numel(data) >= numBytes
                        %Number of bytes to wait for received

                        %Cut to number of bytes to wait for
                        data = data(1:numBytes);
                        dataTime = dataTime(1:numBytes);

                        done = true;
                    end
        end
        if done
            %Register trigger so user can start/end elements and sync experiment from precise receive time, 
            %not just this element end time.
            %Trigger value is data received.
            %Trigger time is time receive complete = last time if accumulated over multiple frames.
            this = element_registerTrigger(this, data, t);

            %END OBJECT ON ITS OWN
            this = element_end(this);
        end
    end


    this.data = data;
    this.dataTime = dataTime;


    %PsychBench automatically closes serial port when object ends (both on cue set by user in input property .end or on its own)

    
end