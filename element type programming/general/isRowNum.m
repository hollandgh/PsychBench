function out = isRowNum(x)

% 
% ans = ISROWNUM(x)
% 
% Returns true if x is row (1xn) numeric, including 1x1 and 1x0. For convenience
% also returns true for [] (which is 0x0). Else returns false.
% 
% 
% See also isOneNum, isOneString, isRowChar, is01, is01s.


% Giles Holland 2021


    if nargin < 1
        error('Not enough inputs.')
    end
    
    
out = isa(x, 'numeric') && (isrow(x) || sum(size(x) == 0));