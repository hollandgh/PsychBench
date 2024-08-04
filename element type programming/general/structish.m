function x = structish(fieldNames, varargin)

% 
% x = STRUCTISH([fieldNames], [size...])
%   [input] = for default you can input [], or omit if you don't use any inputs after it.
% 
% Makes a struct array of specified size with specified fields (possibly none),
% all fields empty (containing []). Field names are an array of strings (["x"] or {'x'}).
% Use MATLAB <a href="matlab:disp([10 10 10 '------------']), help struct">struct</a> instead if you want to make a struct array with non-empty 
% fields.
% 
% 
% STRUCTISH
%     -> 1x1 struct with no fields
% 
% STRUCTISH(["a" "b" "c"])
%     -> 1x1 struct with fields a, b, c = []
% 
% STRUCTISH({'a' 'b' 'c'}, 0)
%     -> 0x0 struct with fields a, b, c = []
% 
% STRUCTISH({'a' 'b' 'c'}, 3)
%     -> 1x3 struct with fields a, b, c = []
% 
% STRUCTISH({'a' 'b' 'c'}, 2, 3, 4)
%     -> 2x3x4 struct with fields a, b, c = []
% 
% STRUCTISH({'a' 'b' 'c'}, [2 3 4])
%     -> 2x3x4 struct with fields a, b, c = []
% 
% STRUCTISH([], [2 3 4])
%     -> 2x3x4 struct with no fields
% 
% 
% See also struct.


% Giles Holland 2021


if nargin < 1 || isempty(fieldNames)
    fieldNames = {};
end
if isempty(varargin)
    varargin = {[1 1]};
end
siz = varargin;


fieldNames = var2char(fieldNames, '-c');
    if ~iscellstr(fieldNames)
        error('Field names must be an array of strings')
    end
    
    if  ~( ...
        numel(siz) == 1 && isRowNum(siz{1}) || ...
        all(cellfun(@(x) isOneNum(x),    siz)) ...
        )
    
        error('Size must be one input that is a row array of integers >= 0, or multiple inputs that are integers >= 0.')
    end
siz = [siz{:}];
    if ~all(isIntegerVal(siz) & siz >= 0)
        error('Size must be one input that is a row array of integers >= 0, or multiple inputs that are integers >= 0.')
    end


if numel(siz) == 1
    if siz == 0 %#ok<BDSCI>
        siz = [0 0];
    else
        siz = [1 siz];
    end
end
if isempty(fieldNames)
    x = repmat(struct, siz);
else
    args = [row(fieldNames(:)); repmat({cell(siz)}, 1, numel(fieldNames))];
    x = struct(args{:});
end