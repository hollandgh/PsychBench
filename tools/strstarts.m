function tf = strstarts(str, substr)

%
% tf = STRSTARTS(str, substr)
%
% The family of functions:
%
% strcontains
% strcontainsi
% STRSTARTS
% strstartsi
% strends
% strendsi
%
% are alternatives to MATLAB strncmp(i), strfind, contains, startsWith, endsWith. 
% They merge the functionality of these functions.
%
% Both inputs "str" and "substr" can be single strings. Alternatively one (not
% both) can be an array of multiple (or zero) strings:
%
% -  If str and substr are single: STRSTARTS checks whether the string starts with the substring.
% -  If str is single:             STRSTARTS searches for substrings that start the string.
% -  If substr is single:          STRSTARTS searches for strings that start with the substring.
%
%
% INPUTS
% ----------
% 
% str
% substr
%     Each of str and substr is a char row vector 'x' or cell array of char row
%     vectors {'x'}, or string "x" or array of strings ["x"]. One must be a
%     single string. The other can be a string array. Any non-char/string values
%     are ignored (return false, don't error, consistent with MATLAB strcmp).
%
%
% OUTPUTS
% ----------
% 
% tf
%     If both str and substr are single strings, this = true/false: string
%     starts with substring. Else it is a logical array with size = size of str
%     or substr, whichever is an array. Note strstarts('', x) or strstarts(x, '')
%     always returns false.
%
%
% See also strstartsi, strcontains, strcontainsi, strends, strendsi, strcmp,
% strcmpi, strrep, strcat, num2str.


% Giles Holland 2022, 2023


try
    
    
%Standardize to char
str = var2char(str);
substr = var2char(substr);

%Ignore non-char/string values
if      isa(str, 'cell')
    if ~iscellstr(str)
        str(cellfun(@(x) ~isa(x, 'char'),    str)) = {''};
    end
elseif  ~isa(str, 'char')
        str = '';
elseif  isa(substr, 'cell')
    if ~iscellstr(substr)
        substr(cellfun(@(x) ~isa(x, 'char'),    substr)) = {''};
    end
elseif  ~isa(substr, 'char')
        substr = '';
end

if isa(str, 'cell')
    ii = strfind(str, substr);

    tf = cellfun(@(x) any(x == 1),    ii);
elseif isa(substr, 'cell')
        ii = cell(size(substr));
    for a = 1:numel(substr)
        ii{a} = strfind(str, substr{a});
    end

    tf = cellfun(@(x) any(x == 1),    ii);
else
    ii = strfind(str, substr);

    tf = any(ii == 1);
end
    
    
catch X
        if nargin < 2
            error('Not enough inputs.')
        else
            %e.g. if both inputs arrays; if an input is a multi-row char array (leave as error for clarity and cause strcmp would accept it)
            error('Each of string and substring must be a char row vector ''x'' or cell array of char row vectors {''x''}, or string "x" or array of strings ["x"]. One must be a single string. The other can be a string array. Non-char/string values are ignored.')
        end
end