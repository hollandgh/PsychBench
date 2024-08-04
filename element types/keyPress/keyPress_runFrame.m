if this.useQueue
    %KEYBOARD QUEUE METHOD
    %---------------------------------------------------------------------------

    
    n_device = this.n_device;
    nn_listenKeys = this.nn_listenKeys;
    nn_listenKeyNames = this.nn_listenKeyNames;
    isStarting = this.isStarting;


    if isStarting
        %OBJECT FRAME 0
        %Object starting at next frame start (frame 1 start)
        %===

        %Start keyboard queue using PTB KbQueueStart.
        %Clear any key events in queue since last object used it in case last object didn't stop it.
        KbQueueStart(n_device)
        KbEventFlush(n_device);


    else
        %OBJECT RUNNING
        %===

        %Get key presses since previous check using PTB KbEventGet.
        %In principle better than KbQueueCheck cause KbQueueCheck can miss > 2 presses of the same key since last check.
            [ee, numKeyEventsRemainingInBuffer] = KbEventGet(n_device);
        for n = 1:numKeyEventsRemainingInBuffer
            e = KbEventGet(n_device);
            ee = [ee e];
        end
        if ~isempty(ee)
            ee = ee([ee(:).Pressed] == 1);
            [tff, jj] = ismember([ee(:).Keycode], nn_listenKeys);
            ee = ee(tff);
            %Listened key numbers pressed
            nn_listenedKeysPressed = jj(tff);
            for i = 1:numel(ee)
                %Listened key pressed -> register response.
                %Also ends object at end of this frame if maximum number responses registered.
                %If max num responses reached and call element_registerResponse again in this loop, just does nothing.
                %Alternatively registers trigger if user set .registerTrigger = true.

                %Response value = index to listenKeyNames for this key
                n_listenKeyName = nn_listenKeyNames(nn_listenedKeysPressed(i));
                pressTime = ee(i).Time;
                this = element_registerResponse(this, n_listenKeyName, pressTime);
            end
        end
        
        if this.isEnding    
            %LAST OBJECT FRAME
            %Object will end at frame end at cue set by user or max num responses
            %===

            %Stop keyboard queue using PTB KbQueueStop
            KbQueueStop(n_device)
        end
    end


else
    %KEYBOARD CHECK METHOD
    %---------------------------------------------------------------------------
    
    
    n_device = this.n_device;
    nn_listenKeys = this.nn_listenKeys;
    nn_listenKeyNames = this.nn_listenKeyNames;
    tf_listenedKeysDown_prev = this.tf_listenedKeysDown_prev;
    pollTime_prev = this.pollTime_prev;
    isStarting = this.isStarting;
    
    
    %Get keys down
    [~, pollTime, tf_keysDown] = KbCheck(n_device);
    %Compensate for PTB bug that tf_keysDown is numeric, not logical
    tf_keysDown = logical(tf_keysDown);
    %Listened key numbers down.
    tf_listenedKeysDown = tf_keysDown(nn_listenKeys);

    if ~isStarting
        %Key PRESS: if keys down are different from prev frame. 
        %Omit check in object frame 0 cause don't have keys down or poll time from prev frame.
        %Also if a key is already down from before object starts we don't want to
        %register it. So first frame object can register a key press is object frame 1.

        %Listened key numbers pressed
        nn_listenedKeysPressed = find(tf_listenedKeysDown & ~tf_listenedKeysDown_prev);
        for n_listenedKeyPressed = nn_listenedKeysPressed
            %Listened key pressed -> register response
            
            %Response value = index to listenKeyNames for this key
            n_listenKeyName = nn_listenKeyNames(n_listenedKeyPressed);
            this = element_registerResponse(this, n_listenKeyName, pollTime_prev, pollTime);
        end
    end


    this.tf_listenedKeysDown_prev = tf_listenedKeysDown;        
    this.pollTime_prev = pollTime;
    
    
end