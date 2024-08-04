function [tf, ii] = strcontainsi(str, substr)

%
% [tf, ii] = STRCONTAINSI(str, substr)
%
% Like <a href="matlab:disp([10 10 10 '------------']), help strcontains">strcontains</a> except case-insensitive.


% Giles Holland 2022


try
    

str = lower(str);
substr = lower(substr);
[tf, ii] = strcontains(str, substr);
    
    
catch X
        if nargin < 2
            error('Not enough inputs.')
        else
            %e.g. if both inputs arrays; if an input is a multi-row char array (leave as error for clarity and cause strcmp would accept it)
            error('Each of string and substring must be a char row vector ''x'' or cell array of char row vectors {''x''}, or string "x" or array of strings ["x"]. One must be a single string. The other can be a string array. Non-char/string values are ignored.')
        end
end