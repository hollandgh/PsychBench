n_device = this.n_device;
nn_listenKeys = this.nn_listenKeys;
numInputs = this.numInputs;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isOneNum(n_device) && isIntegerVal(n_device) || isempty(n_device))
    error('Property .n_device must be an integer or [].')
end
if ~(isRowNum(nn_listenKeys) && all(isIntegerVal(nn_listenKeys) & nn_listenKeys >= 1 & nn_listenKeys <= 256) || isempty(nn_listenKeys))
    error('Property .nn_listenKeys must be a row vector of integers between 1-256, or [].')
end
if ~(isOneNum(numInputs) && isIntegerVal(numInputs) && numInputs > 0)
    error('Property .numInputs must be an integer > 0, or inf.')
end
%---


if WITHPTB
    if isempty(nn_listenKeys)
        %[] -> Listen to all keys
        nn_listenKeys = 1:256;
    end
    
    %Format to logical for PTB KbQueueCreate.
    %Incl PTB bug (?) that KbQueueCreate needs tf_listenKeys class double, not logical.
    tf_listenKeys = zeros(1, 256);
    tf_listenKeys(nn_listenKeys) = 1;
    
    
else %WITHMGL
    if isempty(nn_listenKeys)
        nn_listenKeys = 1:128;
    end
    
    
end
    
    
this.nn_listenKeys = nn_listenKeys;
this.tf_listenKeys = tf_listenKeys;