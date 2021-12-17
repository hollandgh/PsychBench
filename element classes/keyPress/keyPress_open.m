n_device = this.n_device;
nn_listenKeys = this.nn_listenKeys;
nn_ignoreKeys = this.nn_ignoreKeys;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isOneNum(n_device) && isIntegerVal(n_device) && n_device > 0 || isempty(n_device))
    error('Property .n_device must be an integer > 0, or [].')
end


if WITHPTB
    if ~(isRowNum(nn_listenKeys) && all(isIntegerVal(nn_listenKeys) & nn_listenKeys >= 1 & nn_listenKeys <= 256) || isempty(nn_listenKeys))
        error('Property .nn_listenKeys must be a row vector of integers between 1-256, or [].')
    end
    if ~(isRowNum(nn_ignoreKeys) && all(isIntegerVal(nn_ignoreKeys) & nn_ignoreKeys >= 1 & nn_ignoreKeys <= 256) || isempty(nn_ignoreKeys))
        error('Property .nn_ignoreKeys must be a row vector of integers between 1-256, or [].')
    end
    
    
else %WITHMGL
    if ~(isRowNum(nn_listenKeys) && all(isIntegerVal(nn_listenKeys) & nn_listenKeys >= 1 & nn_listenKeys <= 128) || isempty(nn_listenKeys))
        error('Property .nn_listenKeys must be a row vector of integers between 1-128, or [].')
    end
    if ~(isRowNum(nn_ignoreKeys) && all(isIntegerVal(nn_ignoreKeys) & nn_ignoreKeys >= 1 & nn_ignoreKeys <= 128) || isempty(nn_ignoreKeys))
        error('Property .nn_ignoreKeys must be a row vector of integers between 1-128, or [].')
    end
        
    
end
%---


if isempty(nn_listenKeys)
    %[] -> Listen to all keys
    if WITHPTB
        nn_listenKeys = 1:256;
        
        
    else %WITHMGL
        nn_listenKeys = 1:128;
        
        
    end
end
    %Remove keys to ignore
    nn_listenKeys = setdiff(nn_listenKeys, nn_ignoreKeys);
    
    
this.nn_listenKeys = nn_listenKeys;

%Initialize some record properties for runFrame
this.tf_listenedKeysDown_prev = [];
this.pollTime_prev = [];