n_device = this.n_device;
deltas = this.deltas;
nn_listenKeys = this.nn_listenKeys;
isStarting = this.isStarting;
frameInterval = experiment.frameInterval;

%Values from prev frame
tf_listenedKeysDown_prev = this.tf_listenedKeysDown_prev;
n_listenedKeyCombinationDown_prev = this.n_listenedKeyCombinationDown_prev;
pollTime_prev = this.pollTime_prev;

%Values for repeat adjustment
repeatDelay = this.repeatDelay;
repeatRate = this.repeatRate;
repeatDelta = this.repeatDelta;
repeatTime = this.repeatTime;


%GET KEYS DOWN
[~, pollTime, tf_keysDown] = KbCheck(n_device);
%Compensate for PTB bug that tf_keysDown is numeric, not logical
tf_keysDown = logical(tf_keysDown);
%Listened key numbers down
tf_listenedKeysDown = tf_keysDown(nn_listenKeys);


                n_listenedKeyCombinationDown = n_listenedKeyCombinationDown_prev;
                    
if ~isStarting
    %GET CHANGE IN KEY COMBINATION DOWN, IF ANY
    %Listened keys PRESS or RELEASE: if keys down are different from prev frame.
    %Omit check in object frame 0 cause don't have keys down or poll time from prev frame.
    %Also if a key is already down from before object starts we don't want to
    %register it. So first frame object can register a key press is object frame 1.
    if any(tf_listenedKeysDown ~= tf_listenedKeysDown_prev)
        nn_keysDown = nn_listenKeys(tf_listenedKeysDown);

                n_listenedKeyCombinationDown = [];
        for i = 1:size(deltas, 1)
            %Look for exact match--e.g. Cmd+C down should not match C in list
            if isempty(setxor(deltas{i,1}, nn_keysDown))
                n_listenedKeyCombinationDown = i;
                %See only first key combination down
                break
            end
        end
    end


    %GET ADJUSTMENT/RESPONSE (NEW OR REPEAT), IF ANY
    if ~isempty(n_listenedKeyCombinationDown)
            %isequaln in case prev = []
        if ~isequaln(n_listenedKeyCombinationDown, n_listenedKeyCombinationDown_prev)
            %New key combination pressed.
            %OR new key combination down after release of another combination, so stop repeat (care about down, not press, cause of repeat functionality).

                delta = deltas{n_listenedKeyCombinationDown,2};

            if isa(delta, 'numeric')                
                %Adjustment -> setup repeat in case will hold down
                repeatDelta = delta;
                repeatTime = pollTime+repeatDelay;
            else
                %Code 'r' -> response -> no repeat
                repeatDelta = [];
                repeatTime = [];
            end
        else
            %Same key combination down as prev frame

            if ~isempty(repeatDelta) && pollTime > repeatTime
                %Adjustment and time for repeat

                delta = repeatDelta;

                %Update time for next repeat.
                %Allow for possible dropped frames since prev repeat.
                repeatTime = repeatTime+ceil((pollTime-repeatTime)*repeatRate)/repeatRate;
            else
                %Response -> no repeat
                delta = [];
            end
        end
    else
                delta = [];
    end


    %SEND ADJUSTMENT/RECORD RESPONSE, IF ANY
    if ~isempty(delta)
        if isa(delta, 'numeric')
            %Send adjustment to any target elements running
            this = element_adjustElements(this, delta);
        else
            %Register response (done adjusting).
            %Also ends object at end of this frame if maximum number responses registered.
            this = element_registerResponse(this, [], pollTime_prev, pollTime);
        end
    end
end


%Record values for next frame
this.tf_listenedKeysDown_prev = tf_listenedKeysDown;
this.n_listenedKeyCombinationDown_prev = n_listenedKeyCombinationDown;
this.pollTime_prev = pollTime;

%Record values for repeat adjustment
this.repeatDelta = repeatDelta;
this.repeatTime = repeatTime;