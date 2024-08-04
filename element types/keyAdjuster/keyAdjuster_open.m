%Giles Holland 2022, 23


        %(Handle deprecated)
        %---
            if ~isempty(this.n_device) && isOneNum(this.n_device) && this.n_device < 0
                this.n_device = [];
            end
            
        if isa(this.deltas, 'cell') && ismatrix(this.deltas) && size(this.deltas, 2) == 2
            this.deltas(:,2) = var2char(this.deltas(:,2));
            i = find(strcmpi(this.deltas(:,2), 'r'), 1);
            if ~isempty(i)
                this.responseKeyName = this.deltas{i,1};
                this.deltas(i,:) = [];
            end
        end
        %--


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Standardize strings from "x"/'x' to 'x'
this.responseKeyName = var2char(this.responseKeyName);
%this.deltas done in basic check/format below
%---


deltas = this.deltas;
responseKeyName = this.responseKeyName;
repeatDelay = this.repeatDelay;
repeatRate = this.repeatRate;
n_device = this.n_device;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
XMsg = [
    'Property .deltas must be a 2-column cell array with each row containing:' 10 ...
    10 ...
    '{column 1} a string or array of strings, or a number or vector of numbers' 10 ...
    '{column 2} a numeric value' 10 ...
    ];
if  ~(isa(deltas, 'cell') && ismatrix(deltas) && size(deltas, 2) == 2 && ~isempty(deltas))
    error(XMsg)
end
for i = 1:size(deltas, 1)
    deltas{i,1} = var2char(deltas{i,1}, '-c');
    deltas{i,1} = row(deltas{i,1});
end
if  ~( ...
    all(cellfun(@(y) (iscellstr(y) || isa(y, 'numeric')) && ~isempty(y),    deltas(:,1))) && ...
    all(cellfun(@(y) isa(y, 'numeric') && ~isempty(y),    deltas(:,2))) ...
    )

    error(XMsg)
end
this.deltas = deltas;
%Let keyName2Num below error check actual key names/numbers


if ~(isa(responseKeyName, 'char') || isOneNum(responseKeyName))
    error('Property .responseKeyName must be a string or number.')
end
%Let keyName2Num below error check actual key name/number

if ~(isOneNum(repeatDelay) && repeatDelay >= 0)
    error('Property .repeatDelay must be a number >= 0.')
end
if ~(isOneNum(repeatRate) && repeatRate >= 0)
    error('Property .repeatRate must be a number >= 0.')
end
if ~(repeatDelay >= 1/repeatRate)
    error('Property .repeatDelay must be >= 1/.repeatRate.')
end

if ~(isOneNum(n_device) && isIntegerVal(n_device) && n_device > 0 || isempty(n_device))
    error('Property .n_device must be an integer > 0, or [].')
end
%---


if isempty(n_device)
    %Format for PTB KbCheck: [] = all keyboards -> -1
    n_device = -1;
end

%Convert key names in deltas table to numbers, or leave if already numbers.
%Store in single vector of all key numbers to listen to for use in runFrame.
    nn_listenKeys = zeros(1, 0);
for i = 1:size(deltas, 1)
    try
        deltas{i,1} = keyName2Num(deltas{i,1}, 1);
    catch X
            if strstarts(X.identifier, 'keyName2Num:')
                %Error for user like key doesn't exist
                error([X.message ' Use showKey() at the MATLAB command line to get key names.'])
            else
                %Bug
                rethrow(X)
            end
    end
    nn_listenKeys = [nn_listenKeys deltas{i,1}]; %#ok<*AGROW>
end

%Convert to response key number.
%Add as last row in deltas table with code 'r' (response) for use in runFrame.
%Add to vector of all key numbers to listen to.
try
    n_responseKey = keyName2Num(responseKeyName, 1);
catch X
        if strstarts(X.identifier, 'keyName2Num:')
            error([X.message ' Use showKey() at the MATLAB command line to get key names.'])
        else
            rethrow(X)
        end
end
deltas = [deltas; {n_responseKey 'r'}];
nn_listenKeys = [nn_listenKeys n_responseKey];
    
nn_listenKeys = unique(nn_listenKeys);


this.deltas = deltas;
this.n_device = n_device;
this.nn_listenKeys = nn_listenKeys;

%Initialize some record properties for first iteration of runFrame
this.tf_listenedKeysDown_prev = [];
this.n_listenedKeyCombinationDown_prev = [];
this.pollTime_prev = [];
this.repeatDelta = [];
this.repeatTime = [];