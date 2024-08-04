function tf = any2(x, dim)

% 
% ans = ANY2(x, [dim])
%     [input] = omit or input [] for default.
% 
% Like MATLAB <a href="matlab:disp([10 10 10 '------------']), help any">any</a> except if x is 2+ -dimensional then by default returns one 
% true/false value working across all elements in the array instead of working
% across one dimension. To work across one dimension you can input dimension
% (number).
% 
% e.g. if
% 
% x = [ 1 -2  3
%       4 -5 -6]
% 
% then
% 
% any(x > 0)  -> [true false true]
% ANY2(x > 0) -> true
% 
% 
% See also any, all2.


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
    tf = any(x(:));
else
    tf = any(x, dim);
end