n_device = this.n_device;
nn_listenKeys = this.nn_listenKeys;
numInputs = this.numInputs;
tf_listenKeys = this.tf_listenKeys;
data = this.data;
dataTime = this.dataTime;
isStarting = this.isStarting;




%--------------------------------------------------------------------------
if WITHPTB
    if isStarting
        %Open and start keyboard queue.
        %element_openKeyboardQueue uses PTB KbQueueCreate, KbQueueStart.
        this = element_openKeyboardQueue(this, n_device, tf_listenKeys);


    else
        %Get key presses since previous check using PTB KbEventGet.
        %In theory better than KbQueueCheck cause KbQueueCheck can miss > 2 presses of the same key.
        %Returns only listened keys.
            dd = [];
            numKeyEventsRemainingInBuffer = inf;
        while numKeyEventsRemainingInBuffer > 0
            [d, numKeyEventsRemainingInBuffer] = KbEventGet;
            if ~isempty(d) && d.Pressed
                dd = [dd d];
            end
        end
        
        if ~isempty(dd)
            %Key presses received -> add to record
            data = [data dd(:).Keycode];
            dataTime = [dataTime dd(:).Time];

            if numel(data) >= numInputs
                %Number of key presses to wait for received

                %Cut to number of key presses to wait for
                data = data(1:numInputs);
                dataTime = dataTime(1:numInputs);

                %Register trigger so user can start/end elements and sync experiment from precise receive time, 
                %not just this element end time
                %Trigger value is data received.
                %Trigger time is time receive complete = last time if accumulated over multiple frames.
                this = element_registerTrigger(this, data, dataTime(end));

                %END OBJECT ON ITS OWN
                this = element_end(this);
            end
        end
    end

    
    
        
%--------------------------------------------------------------------------
else %WITHMGL
    if isStarting
        %Initialize keyboard queue.
        %element_openKeyboardQueue uses mglListener('init').
        this = element_openKeyboardQueue(this);


    else
            %Get listened key presses since previous check using mglListener('getAllKeyEvents')
            dd = mglListener('getAllKeyEvents');
        if ~isempty(dd)
            tf = ismember(dd.keyCode, nn_listenKeys);
            dd.keyCode = dd.keyCode(tf);
            dd.when = dd.when(tf);
        
            if ~isempty(dd.keyCode)            
                %Key presses received -> add to record
                data = [data dd.keyCode];
                dataTime = [dataTime dd.when];

                if numel(data) >= numInputs
                    %Number of key presses to wait for received

                    %Cut to number of key presses to wait for
                    data = data(1:numInputs);
                    dataTime = dataTime(1:numInputs);

                    %Register trigger so user can start/end elements and sync experiment from precise receive time, 
                    %not just this element end time
                    %Trigger value is data received.
                    %Trigger time is time receive complete = last time if accumulated over multiple frames.
                    this = element_registerTrigger(this, data, dataTime(end));

                    %END OBJECT ON ITS OWN
                    this = element_end(this);
                end
            end
        end
    end
    
    
    
    
%--------------------------------------------------------------------------
end




this.data = data;
this.dataTime = dataTime;


%PsychBench automatically closes keyboard queue when object ends