function out = isLower(x)

% 
% ans = ISLOWER(x)
% 
% Returns a logical array same size as x containing true where character array x
% is a lower case letter.
% 
% 
% See also isUpper.


% Giles Holland 2021


    if nargin < 1
        error('Not enough inputs.')
    end
    if ~isa(x, 'char')
        error('Input must be a character array (''x'').')
    end
    

out = x ~= upper(x);