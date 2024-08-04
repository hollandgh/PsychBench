function tf = strends(str, substr)

%
% tf = STRENDS(str, substr)
%
% The family of functions:
%
% strcontains
% strcontainsi
% strstarts
% strstartsi
% STRENDS
% strendsi
%
% are alternatives to MATLAB strncmp(i), strfind, contains, startsWith, endsWith. 
% They merge the functionality of these functions.
%
% Both inputs "str" and "substr" can be single strings. Alternatively one (not
% both) can be an array of multiple (or zero) strings:
%
% -  If str and substr are single: STRENDS checks whether the string ends with the substring.
% -  If str is single:             STRENDS searches for substrings that end the string.
% -  If substr is single:          STRENDS searches for strings that end with the substring.
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
%     If both str and substr are single strings, this = true/false: string ends
%     with substring. Else it is a logical array with size = size of str or
%     substr, whichever is an array. Note strends('', x) or strends(x, '') 
%     always returns false.
%
%
% See also strendsi, strcontains, strcontainsi, strstarts, strstartsi, strcmp,
% strcmpi, strrep, strcat, num2str.


% Giles Holland 2022, 2023


try
    

%Standardize to char.
%Also needed for length() below.
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

        tf = false(size(str));
    for a = 1:numel(str)
        tf(a) = any(ii{a} == length(str{a})-length(substr)+1);
    end
elseif isa(substr, 'cell')
        ii = cell(size(substr));
    for a = 1:numel(substr)
        ii{a} = strfind(str, substr{a});
    end

        tf = false(size(substr));
    for a = 1:numel(substr)
        tf(a) = any(ii{a} == length(str)-length(substr{a})+1);
    end
else
    ii = strfind(str, substr);

    tf = any(ii == length(str)-length(substr)+1);
end
    
    
catch X
        if nargin < 2
            error('Not enough inputs.')
        else
            %e.g. if both inputs arrays; if an input is a multi-row char array (leave as error for clarity and cause strcmp would accept it)
            error('Each of string and substring must be a char row vector ''x'' or cell array of char row vectors {''x''}, or string "x" or array of strings ["x"]. One must be a single string. The other can be a string array. Non-char/string values are ignored.')
        end
end