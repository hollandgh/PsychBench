function out = isRowChar(x)

% 
% ans = ISROWCHAR(x)
% 
% Returns true if x is a row (1xn) character array, e.g. 'hello'. For
% convenience also returns true for '' (which is 0x0). Else returns false.
% 
% 
% See also isOneNum, isRowNum, isOneString, is01, is01s.


% Giles Holland 2021


    if nargin < 1
        error('Not enough inputs.')
    end

    
out = isa(x, 'char') && (isrow(x) || sum(size(x) == 0));