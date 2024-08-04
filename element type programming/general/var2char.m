function x = var2char(x, flag)

% 
% x = VAR2CHAR(x, [flag])
%     [input] = omit or input [] for default.
% 
% Converts a value that could be old string type 'x' (char / cell array of char)
% or new string type "x" to old string type 'x'. Leaves any other data type
% unchanged (doesn't throw an error). Value can be any size. Typically use at
% the input stage of code to standardize a value to old string type 'x' for use
% in the code.
% 
% Specifically:
% 
% 
%  "x"                   ->  'x'
% ["x" "x" ...]          -> {'x' 'x' ...}
%  ""                    ->  ''
% empty "x" string array -> {}
% 
% 
% If the value is a cell array, VAR2CHAR applies to the content of each cell.
% e.g. {2 "x"} -> {2 'x'}. If a cell contains a further cell array, VAR2CHAR
% applies recursively.
% 
% If you input a flag '-c', VAR2CHAR converts "x" -> {'x'}, i.e. returns a cell
% array of 'x' for all sizes of "x" string array. Ignored if input is a cell
% array.
% 
% 
% See also var2string.


% Giles Holland 2021, 23


if nargin < 2 || isempty(flag)
    flag = '';
end


    if isa(flag, 'string')
        flag = char(flag);
    elseif ~isa(flag, 'char')
        flag = '';
    end

    
if      isa(x, 'string')
    if numel(x) == 1 && ~strcmpi(flag, '-c')
        x = char(x);
    else
        x = cellstr(x);
    end
elseif  isa(x, 'char') && any(strcmpi(flag, '-c'))
        x = {x};
        
elseif  isa(x, 'cell') && ~iscellstr(x)
    %-c flag doesn't apply in cell mode
    
    for i = 1:numel(x)
        if      isa(x{i}, 'string')
            if numel(x{i}) == 1
                x{i} = char(x{i});
            else
                x{i} = cellstr(x{i});
            end
        elseif isa(x{i}, 'cell')
            %Recursive
            x{i} = var2char(x{i});
        end
    end
    
%else leave unchanged
end