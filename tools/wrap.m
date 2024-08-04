function x = wrap(x, n)

% 
% x = WRAP(x, n)
% 
% x is a number, n is a positive number. WRAP returns a number between 0 ... n
% that is x wrapped within that range. (This = mod(x, n).)
% 
% e.g.
% 
% WRAP(0, 360)   -> 0
% WRAP(180, 360) -> 180
% WRAP(360, 360) -> 0
% WRAP(540, 360) -> 180
% 
% 
% See also wrapInteger.


% Giles Holland 2022


    if nargin < 2
        error('Not enough inputs.')
    end

    if ~isa(x, 'numeric')
        error('First input must be numeric.')
    end
    if ~(isOneNum(n) && n > 0)
        error('Second input must be a number > 0.')
    end

    
x = mod(x, n);