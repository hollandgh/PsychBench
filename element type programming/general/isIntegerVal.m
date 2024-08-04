function out = isIntegerVal(x)

% 
% ans = ISINTEGERVAL(x)
% 
% Returns a logical array the same size as numeric array x containing true where
% x is an integer value. x can be any numeric data type, not necessarily an
% integer type.


% Giles Holland 2021


    if nargin < 1
        error('Not enough inputs.')
    end
    if ~isa(x, 'numeric')
        error('Input must be numeric.')
    end
    

out = x == round(x);