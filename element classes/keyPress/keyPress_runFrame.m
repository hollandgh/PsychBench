n_device = this.n_device;
nn_listenKeys = this.nn_listenKeys;
tf_listenedKeysDown_prev = this.tf_listenedKeysDown_prev;
pollTime_prev = this.pollTime_prev;
isStarting = this.isStarting;


%Get keys down
if WITHPTB
    [~, pollTime, tf_keysDown] = KbCheck(n_device);
    %PTB bug that tf_keysDown is class double, not logical
    tf_keysDown = logical(tf_keysDown);
    %Listened key #s down.
    tf_listenedKeysDown = tf_keysDown(nn_listenKeys);
    
    
else %WITHMGL
    tf_listenedKeysDown = mglGetKeys(nn_listenKeys);
    pollTime = mglGetSecs;
    
    
end
    

if ~isStarting
    %Code below looks for key PRESS: if keys are down and different from prev frame. 
    %Omit check in object frame 0 cause don't have keys down or poll time from prev frame.
    %Also if a key is already down from before object starts we don't want to
    %register it. So first frame object can register a key press is object frame 1.
    
    tf_listenedKeysPressed = tf_listenedKeysDown & ~tf_listenedKeysDown_prev;
    if any(tf_listenedKeysPressed)
        %Listened key pressed -> register response

        %Recover overall key #
        n_keyPressed = nn_listenKeys(tf_listenedKeysPressed);
        %Get only first listened key pressed
        n_keyPressed = n_keyPressed(1);

        [this, maxNumResponsesRegistered] = element_registerResponse(this, n_keyPressed, pollTime_prev, pollTime);
        if maxNumResponsesRegistered
            this = element_end(this);
        end
    end
end


this.tf_listenedKeysDown_prev = tf_listenedKeysDown;        
this.pollTime_prev = pollTime;