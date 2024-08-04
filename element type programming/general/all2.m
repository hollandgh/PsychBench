function tf = all2(x, dim)

% 
% ans = ALL2(x, [dim])
%     [input] = omit or input [] for default.
% 
% Like MATLAB <a href="matlab:disp([10 10 10 '------------']), help all">all</a> except if x is 2+ -dimensional then by default returns one
% true/false value working across all elements in the array instead of working
% across one dimension. To work across one dimension you can input dimension
% (number).
% 
% e.g. if
% 
% x = [ 1  2  3
%       4  5 -6]
% 
% then
% 
% all(x > 0)  -> [true true false]
% ALL2(x > 0) -> false
% 
% 
% See also all, any2.


% Giles Holland 2022


    if nargin < 2 || isempty(dim)
        dim = [];
    end


    if nargin < 1
        error('Not enough inputs.')
    end
    if ~(isa(x, 'logical') || isa(x, 'numeric'))
        error('Input must be a logical or numeric array.')
    end
    if ~(isOneNum(dim) && isIntegerVal(dim) && dim > 0 || isempty(dim))
        error('Dimension must be an integer > 0, or [].')
    end


if isempty(dim)
    tf = all(x(:));
else
    tf = all(x, dim);
end