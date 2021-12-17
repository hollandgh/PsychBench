%PREPROCESS INPUT PROPERTIES FOR DATA TYPE, UNITS
%---
%Standardize strings from "x"/'x' to 'x'.
this.deltas = var2Char(this.deltas);
%---


n_device = this.n_device;
deltas = this.deltas;
repeatDelay = this.repeatDelay;
repeatRate = this.repeatRate;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isOneNum(n_device) && isIntegerVal(n_device) && n_device > 0 || isempty(n_device))
    error('Property .n_device must be an integer > 0, or [].')
end


if WITHPTB
    XMsg = [
        'Property .deltas must be a 2-column cell array with each row containing:' 10 ...
        10 ...
        '{column 1} an integer or row vector of integers between 1-256' 10 ...
        '{column 2} a numeric value or the string "r"' 10 ...
        ];
    if  ~( ...
        ~isempty(deltas) && isa(deltas, 'cell') && ndims(deltas) == 2 && size(deltas, 2) == 2 && ...
        all(cellfun(@(y) isRowNum(y) && all(isIntegerVal(y) & y >= 1 & y <= 256) && ~isempty(y),    deltas(:,1))) && ...
        all(cellfun(@(y) isa(y, 'numeric') || isa(y, 'char') && strcmpi(y, 'r'),    deltas(:,2))) ...
        )

        error(XMsg)
    end
    for i = 1:size(deltas, 1)
        for j = 1:i-1
            if isempty(setxor(deltas{i,1}, deltas{j,1}))
                error('In property .deltas column 1: Duplicate keys or key combinations.')
            end
        end
    end
    
    
else %WITHMGL
    XMsg = [
        'Property .deltas must be a 2-column cell array with each row containing:' 10 ...
        10 ...
        '{column 1} an integer or row vector of integers between 1-128' 10 ...
        '{column 2} a numeric value or the string "r"' 10 ...
        ];
    if  ~( ...
        ~isempty(deltas) && isa(deltas, 'cell') && ndims(deltas) == 2 && size(deltas, 2) == 2 && ...
        all(cellfun(@(y) isRowNum(y) && all(isIntegerVal(y) & y >= 1 & y <= 128) && ~isempty(y),    deltas(:,1))) && ...
        all(cellfun(@(y) isa(y, 'numeric') || isa(y, 'char') && strcmpi(y, 'r'),    deltas(:,2))) ...
        )

        error(XMsg)
    end
    for i = 1:size(deltas, 1)
        for j = 1:i-1
            if isempty(setxor(deltas{i,1}, deltas{j,1}))
                error('In property .deltas column 1: Duplicate keys or key combinations.')
            end
        end
    end
    
    
end


if ~(isOneNum(repeatDelay) && repeatDelay >= 0)
    error('Property .repeatDelay must be a number >= 0.')
end
if ~(isOneNum(repeatRate) && repeatRate >= 0)
    error('Property .repeatRate must be a number >= 0.')
end
%---


%Get keys to listen to = all keys in combinations listed in table (used in runFrame script)
nn_listenKeys = unique([deltas{:,1}]);


this.nn_listenKeys = nn_listenKeys;

%Initialize some record properties for runFrame
this.tf_listenedKeysDown_prev = [];
this.n_listenedKeyCombDown_prev = [];
this.pollTime_prev = [];
this.repeatDelta = [];
this.repeatTime = [];