function out = is01(x)

% 
% ans = IS01(x)
% 
% Returns true if x is scalar true/false (logical) or 1/0 (numeric), else 
% returns false. Both these types work equivalently in <a href="matlab:disp([10 10 10 '------------']), help if">if</a> statements and
% functions like <a href="matlab:disp([10 10 10 '------------']), help any">any</a> and <a href="matlab:disp([10 10 10 '------------']), help all">all</a> (though not if used as array indexes).
% 
% 
% See also is01s, isOneNum, isRowNum, isOneString, isRowChar.


% Giles Holland 2022


    if nargin < 1
        error('Not enough inputs.')
    end


out = numel(x) == 1 && (isa(x, 'logical') || isa(x, 'numeric') && any(x == [1 0]));