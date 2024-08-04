function out = isOneNum(x)

% 
% ans = ISONENUM(x)
% 
% Returns true if x is numeric with numel = 1. Else returns false.
% 
% 
% See also isRowNum, isOneString, isRowChar, is01, is01s.


% Giles Holland 2021


    if nargin < 1
        error('Not enough inputs.')
    end

    
out = isa(x, 'numeric') && numel(x) == 1;