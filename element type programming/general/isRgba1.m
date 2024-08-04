function out = isRgba1(x)

% 
% ans = ISRGBA1(x)
% 
% Returns true if x is a 1x3 or 1x4 vector of numbers between 0-1, else returns 
% false.
% 
% 
% See also ISRGB1.


% Giles Holland 2022


    if nargin < 1
        error('Not enough inputs.')
    end


out = isa(x, 'numeric') && isrow(x) && any(numel(x) == [3 4]) && all(x >= 0 & x <= 1);