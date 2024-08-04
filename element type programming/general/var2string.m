function x = var2string(x)

% 
% x = VAR2STRING(x)
% 
% Converts a value that could be old string type 'x' (char / cell array of char)
% or new string type "x" to new string type "x". Leaves any other data type
% unchanged (doesn't throw an error). Value can be any size. Typically use at
% the input stage of code to standardize a value to new string type "x" for use
% in the code.
% 
% Specifically:
% 
% 
%  'x'          ->  "x"
% {'x' 'x' ...} -> ["x" "x" ...]
%  ''           ->  ""
% {}            -> empty "x" string array
% 
% 
% If the value is a cell array that is not a cell array of 'x' strings and not
% empty, VAR2STRING applies to the content of each cell. e.g.  {2 'x'} -> {2 "x"}.
% If a cell contains a further cell array, VAR2STRING applies recursively.
% 
% 
% See also var2char.


% Giles Holland 2021, 23


    if nargin < 1
        error('Not enough inputs.')
    end

    
if      isa(x, 'char') || iscellstr(x)
    x = string(x);
    
elseif  isa(x, 'cell')
    for i = 1:numel(x)
        if isa(x{i}, 'char') || iscellstr(x{i})
            x{i} = string(x{i});
        elseif isa(x{i}, 'cell')
            %Recursive
            x{i} = var2string(x{i});
        end
    end
    
%else leave unchanged
end