function out = is01s(x)

% 
% ans = IS01S(x)
% 
% Returns true if x is an array of true/false (logical) or 1/0 (numeric) or [],
% else returns false. Both these types work equivalently in <a href="matlab:disp([10 10 10 '------------']), help if">if</a> statements and 
% functions like <a href="matlab:disp([10 10 10 '------------']), help any">any</a> and <a href="matlab:disp([10 10 10 '------------']), help all">all</a> (though not if used as array indexes).
% 
% 
% See also is01, isOneNum, isRowNum, isOneString, isRowChar.


% Giles Holland 2022


    if nargin < 1
        error('Not enough inputs.')
    end


out = isa(x, 'logical') || isa(x, 'numeric') && all2(x == 1 | x == 0);