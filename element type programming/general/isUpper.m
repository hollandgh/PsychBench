function out = isUpper(x)

% 
% ans = ISUPPER(x)
% 
% Returns a logical array same size as x containing true where character array x
% is an upper case letter.
% 
% 
% See also isLower.


% Giles Holland 2021


    if nargin < 1
        error('Not enough inputs.')
    end
    if ~isa(x, 'char')
        error('Input must be a character array (''x'').')
    end
    

out = x ~= lower(x);