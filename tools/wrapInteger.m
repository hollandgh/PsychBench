function x = wrapInteger(x, n)

% 
% x = WRAPINTEGER(x, n)
% 
% x is an integer (or numeric with all values integer), n is a positive integer.
% WRAPINTEGER returns an integer between 1 ... n that is x wrapped within that
% range. (This = mod(x-1, n)+1.)
% 
% e.g.
% 
% WRAPINTEGER(1, 3) -> 1
% WRAPINTEGER(3, 3) -> 3
% WRAPINTEGER(4, 3) -> 1
% WRAPINTEGER(8, 3) -> 2
% 
% 
% See also wrap, circshift.


% Giles Holland 2022


    if nargin < 2
        error('Not enough inputs.')
    end

    if ~(isa(x, 'numeric') && all(isIntegerVal(x)))
        error('First input must be numeric with all numbers integers.')
    end
    if ~(isOneNum(n) && isIntegerVal(n) && n > 0)
        error('Second input must be an integer > 0.')
    end

    
x = mod(x-1, n)+1;