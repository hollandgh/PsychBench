function [pathfileName, pathfolderName] = whereFile(x)

% 
% [pathfileName, pathfolderName] = WHEREFILE(x)
% 
% Input a string containing a file or folder name, possibly including a full or
% relative path (relative to the MATLAB current folder). WHEREFILE returns full
% path + file name in output 1 if MATLAB can find a matching file, and/or full
% path + folder name in output 2 if MATLAB can find a matching folder. Else
% returns [] in one or both outputs.
% 
% If you don't include path, it means different things when searching for
% files/folders:
% 
% Files:   No path = anywhere on the MATLAB search path, and returns first match
%                   if multiple matches found.
% 
% Folders: No path = MATLAB current folder.
% 
% 
% Note:
% - WHEREFILE is case-sensitive.
% - Use full file names including extension (including for .m/p files).
% - Don't use MATLAB partial paths, only relative paths.


% Giles Holland 2021, 22


    if nargin < 1
        error('Not enough inputs.')
    end

outputString = isa(x, 'string');
x = var2char(x);
    if ~isRowChar(x)
        error('Input must be a string.')
    end


    [tf, s] = fileattrib(x);
    
            pathfileName = '';
            pathfolderName = '';
if any(x == filesep)
    %Full or relative path -> check for exist and type
    
        %fileattrib works with relative paths, but not with no path or partial path on MATLAB search path
    if tf
        if s.directory
            pathfolderName = s.Name;
        else
            pathfileName = s.Name;
        end
    end
else
    %Check for folder in cd
    if tf && s.directory
        pathfolderName = fullfile(cd, x);
    end

    %Check for first file anywhere on MATLAB search path (incl cd).
    %Handle case where person input a file name with no extension and whichFile returns an m/p file.
            pathfileName = whichFile(x);
    if ~isempty(pathfileName)
        [~, ~, c1] = fileparts(x);
        [~, ~, c2] = fileparts(pathfileName);
        if ~strcmp(c1, c2)
            pathfileName = '';
        end
    end
end


if outputString
    if isempty(pathfileName)
        pathfileName = strings(0);
    else
        pathfileName = string(pathfileName);
    end
    if isempty(pathfolderName)
        pathfolderName = strings(0);
    else
        pathfolderName = string(pathfolderName);
    end
end