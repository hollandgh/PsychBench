function out = isOneString(x)

% 
% ans = ISONESTRING(x)
% 
% Returns true if x is string (not a character array) with numel = 1, e.g. "hello". 
% Else returns false.
% 
% 
% See also isOneNum, isRowNum, isRowChar, is01, is01s.


% Giles Holland 2021


    if nargin < 1
        error('Not enough inputs.')
    end

    
out = isa(x, 'string') && numel(x) == 1;