function tf = isUnique(x)

% 
% ans = ISUNIQUE(x)
% 
% Returns a logical array same size as x containing true where the value is
% unique in x. x must be numeric, char (works at the character level), or 
% string. For cell array of char use <a href="matlab:disp([10 10 10 '------------']), help isUnique_str">isUnique_str</a>.
% 
% 
% See also isUnique_str, isUnique_stri.


% Giles Holland 2021


    if nargin < 1
        error('Not enough inputs.')
    end
    if ~(isa(x, 'numeric') || isa(x, 'char') || isa(x, 'string'))
        error('Input must be numeric, char, or string. For cell array of char use ISUNIQUE_STR.')
    end
    
    
tf = false(size(x));
[x_sorted, ii] = sort(x(:));
blarg = [true; x_sorted(1:end-1) ~= x_sorted(2:end)];
tf(ii) = blarg & blarg([2:end 1]);