%Giles Holland 2022


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Standardize strings from "x"/'x' to 'x'
this.fileName = var2char(this.fileName);
%---


fileName = this.fileName;
    

%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~isRowChar(fileName)
    error('Property .fileName must be a string.')
end
[~, ~, e] = fileparts(fileName);
if isempty(e)
    fileName = [fileName '.mat'];
elseif ~strcmpi(e, '.mat')
    error('In property .fileName: Must be a .mat file.')
end
this.fileName = fileName;
%---


%Overwrite file if already exists when first profiler element saving that file opens in the experiment.
%Each profiler element in the experiment will then append to it (_close script).
element_doShared(@newFile, fileName);


%end script




function newFile(fileName) %local function


if exist(fileName, 'file')
    delete(fileName)
end


end %newFile