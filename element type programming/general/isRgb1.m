function out = isRgb1(x)

% 
% ans = ISRGB1(x)
% 
% Returns true if x is a 1x3 vector of numbers between 0-1, else returns false.
% 
% 
% See also ISRGBA1.


% Giles Holland 2022


    if nargin < 1
        error('Not enough inputs.')
    end


out = isa(x, 'numeric') && isrow(x) && numel(x) == 3 && all(x >= 0 & x <= 1);