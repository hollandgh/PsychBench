function x = roundUp(x, n)

% 
% x = ROUNDUP(x, [n])
%     [input] = omit or input [] for default.
% 
% ROUNDUP(x, n) rounds a number or array of numbers x to n digits right of the
% decimal point, rounding up. n can be negative to round to digits left of the
% decimal point (this convention matches MATLAB <a href="matlab:disp([10 10 10 '------------']), help round">round</a>). Default n = 0 (round up
% to integer).
% 
% 
% See also roundDown, round, floor, ceil.


% Giles Holland 2022


if nargin < 2 || isempty(n)
    n = 0;
end


    if nargin < 1
        error('Not enough inputs.')
    end
    if ~isa(x, 'numeric')
        error('Value to round must be numeric.')
    end
    if ~(isOneNum(n) && isIntegerVal(n))
        error('Number of decimal places must be an integer.')
    end


x = ceil(x*10^n)/10^n;