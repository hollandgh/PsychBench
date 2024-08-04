%Giles Holland 2022, 23


        %(Handle deprecated)
        %---
        if ~isempty(this.n_device) && isOneNum(this.n_device) && this.n_device < 0
            this.n_device = [];
        end
            
        if isfield(this, 'nn_listenKeys') && ~isempty(this.nn_listenKeys) || isfield(this, 'nn_ignoreKeys') && ~isempty(this.nn_ignoreKeys)
            error('Properties .nn_listenKeys and .nn_ignoreKeys are deprecated and response values have changed. Please use .listenKeyNames and .ignoreKeyNames instead and check any use of response values.')
        end
        %--


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Standardize strings from "x"/'x' to 'x'
this.listenKeyNames = var2char(this.listenKeyNames, '-c');
this.ignoreKeyNames = var2char(this.ignoreKeyNames, '-c');
%---


listenKeyNames = this.listenKeyNames;
ignoreKeyNames = this.ignoreKeyNames;
n_device = this.n_device;
useQueue = this.useQueue;
registerTrigger = this.registerTrigger;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
listenKeyNames = row(listenKeyNames);
if ~(iscellstr(listenKeyNames) || isa(listenKeyNames, 'numeric'))
    error('Property .listenKeyNames must be an array of strings or numbers, or [].')
end
if ~(isa(listenKeyNames, 'cell') && all(isUnique_stri(listenKeyNames)) || isa(listenKeyNames, 'numeric') && all(isUnique(listenKeyNames)))
    error('Duplicate key names or numbers in property .listenKeyNames.')
end
this.listenKeyNames = listenKeyNames;
%Let keyName2Num below error check actual key names/numbers

ignoreKeyNames = row(ignoreKeyNames);
if ~(iscellstr(ignoreKeyNames) || isa(ignoreKeyNames, 'numeric'))
    error('Property .ignoreKeyNames must be an array of strings or numbers, or [].')
end
%Don't need to check unique for ignoreKeyNames cause doesn't matter for how it's used below
this.ignoreKeyNames = ignoreKeyNames;
%Let keyName2Num below error check actual key names/numbers

if ~(isOneNum(n_device) && isIntegerVal(n_device) && n_device > 0 || isempty(n_device))
    error('Property .n_device must be an integer > 0, or [].')
end

if ~(is01(useQueue) || isempty(useQueue))
    error('Property .useQueue must be true/false or [].')
end
if isempty(useQueue)
    %Default use keyboard queue if registering trigger, else use simple KbCheck
    useQueue = registerTrigger;
    this.useQueue = useQueue;
end
if useQueue && isempty(n_device)
    warningOnce('keyPress:defaultKeyboard', 'If keyPress property .registerTrigger or .useQueue = true, .n_device = default [] means use only the default keyboard according to Psychtoolbox. If that device is not what you want, set a device number in .n_device.')
end
%---


if useQueue
    %Tell PsychBench this object will use a keyboard queue for the specified device.
    %Opens keyboard queue if not already opened by another object.
    %Replaces PTB KbQueueCreate, KbQueueRelease.
    %Any n_device < 0 -> single default device according to PTB.
    %Returns actual device number opened for use with PTB commands, e.g. KbQueueStart, KbEventGet.
    [this, n_device] = element_openKeyboardQueue(this, n_device);
else
    if isempty(n_device)
        %Format for PTB KbCheck: [] = all keyboards -> -1
        n_device = -1;
    end
end


if isempty(listenKeyNames)
    %[] -> listen to all keys
    nn_listenKeys = 1:256;
    nn_listenKeyNames = 1:256;
else
    %Convert key names to numbers, or leave if already numbers.
    %size(nn_listenKeys) can be > size(listenKeyNames) cause some names -> multiple numbers.
    %nn_listenKeyNames = indexes: listenKeyNames(nn_listenKeyNames) -> nn_listenKeys--used to get response values in runFrame.
    try
        [nn_listenKeys, nn_listenKeyNames] = keyName2Num(listenKeyNames);
    catch X
            if strstarts(X.identifier, 'keyName2Num:')
                %Error for user like key doesn't exist
                error([X.message ' Use showKey() at the MATLAB command line to get key names.'])
            else
                %Bug
                rethrow(X)
            end
    end
end

if ~isempty(ignoreKeyNames)
    %Remove key numbers to ignore
    try
        nn_ignoreKeys = keyName2Num(ignoreKeyNames);
    catch X
            if strstarts(X.identifier, 'keyName2Num:')
                error([X.message ' Use showKey() at the MATLAB command line to get key names.'])
            else
                rethrow(X)
            end
    end
    tff = ismember(nn_listenKeys, nn_ignoreKeys);
    nn_listenKeys(tff) = [];
    nn_listenKeyNames(tff) = [];
end


this.n_device = n_device;
this.nn_listenKeys = nn_listenKeys;
this.nn_listenKeyNames = nn_listenKeyNames;

%Initialize some record properties for first iteration of runFrame
this.tf_listenedKeysDown_prev = [];
this.pollTime_prev = [];