if this.isStarting
    %OBJECT FRAME 0
    %Object starting at next frame start (frame 1 start)
    %===
    

    %[TEST OUT]
    %Clear any data in queue since last object used this port using PTB IOPort('Purge')
    IOPort('Purge', this.n_port)
    
    
else
    %OBJECT RUNNING
    %===


    n_port = this.n_port;
    numBytes = this.numBytes;
    listenData = this.listenData;
    data = this.data;
    dataTimes = this.dataTimes;


    %Check for data in port's input buffer and system time received using PTB IOPort('Read').
    %d is numeric byte values.
    %[TEST OUT]
    [d, t] = IOPort('Read', n_port);
%     %[TEST]
%     d = [80 79];
%     t = GetSecs;

    if ~isempty(d)
        %Data available -> add to record    
        data =     [data     d];
        dataTimes = [dataTimes repmat(t, 1, numel(d))];

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
                        dataTimes = dataTimes(jj);

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
                        dataTimes = dataTimes(1:numBytes);

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
    this.dataTimes = dataTimes;
end