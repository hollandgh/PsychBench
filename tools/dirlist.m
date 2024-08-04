function [pathfileNames, fileNames] = dirlist(p, expr)

% 
% [pathfileNames, fileNames] = DIRLIST([path], [expr])
%     [input] = for default you can input [], or omit if you don't use any inputs after it.
% 
% Returns a list of files/folders in a specified folder, possibly according to a
% wildcard expression. DIRLIST does not return hidden items or ., .. .
% 
% 
% INPUTS
% ----------
% 
% [path]
%     A string (" or i') that is path to look in. This can be a full path or
%     relative to the MATLAB current folder. Optionally you can include a
%     wildcard expression here according to the conventions of your operating
%     system (e.g. "C:\folder\*.m").
%
%     DEFAULT: MATLAB current folder
% 
% [expr]
%     You can instead input a wildcard expression here if you prefer (e.g. "*.m"). 
%     Optionally you can input "-files" for all files only, or "-folders" for
%     all folders only.
%
%     DEFAULT: all files and folders
% 
% 
% OUTPUTS
% ----------
% 
% [pathfileNames]
%     An array of strings (["] or {'}, matching data type of "path" above) that
%     are full path + file/folder names found.
% 
% [fileNames]
%     Same but just file/folder names, no paths.
% 
% 
% See also dir, what.


% Giles Holland 2022


if nargin < 1 || isempty(p)
    p = cd;
end
if nargin < 2 || isempty(expr)
    expr = '';
end


p_in = p;
p = var2char(p);
    if ~isRowChar(p)
        error('Input 1 must be a string.')
    end
    
expr = var2char(expr);
    if ~isRowChar(expr)
        error('Expression must be a string.')
    end

    
    if isempty(expr)
        if ~exist(p, 'dir')
            [sp, ~, ~] = fileparts(p);
            if ~isempty(sp) && ~exist(sp, 'dir')            
                error(['Folder "' sp '" does not exist.'])
            end
        end
    else
            if ~exist(p, 'dir')
                error(['Folder "' p '" does not exist.'])
            end
    end
    

listFiles = strcmpi(expr, '-files');
listFolders = strcmpi(expr, '-folders');
if listFiles || listFolders
    expr = '';
end

    s = dirish(p, expr);
    s = s(~[s(:).ishidden]);
if      listFiles
    s = s(~[s(:).isdir]);
elseif  listFolders
    s = s([s(:).isdir]);
end
pathfileNames = {s(:).folder__name};
fileNames = {s(:).name};


if isa(p_in, 'string')
    pathfileNames = string(pathfileNames);
    fileNames = string(fileNames);
end