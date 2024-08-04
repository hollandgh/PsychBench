function out = whichFile(fileName, varargin)

% 
% out = WHICHFILE(fileName, [flag], [flag], ...)
%     [input] = omit or input [] for default.
% 
% Like MATLAB <a href="matlab:disp([10 10 10 '------------']), help which">which</a> except general for files on the MATLAB search path, not
% specific to the workspace it's called in. So:
% 
% - ignores variables in the workspace.
% - ignores private functions.
% 
% Also:
% 
% - by default case-sensitive (since MATLAB is case-sensitive for calling).
% - outputs row vector, not column, for flag -all.
% 
% 
% INPUTS
% ----------
% 
% fileName
%     String (" or ') that is file name, or MATLAB program name (without the 
%     .m/p extension).
% 
% [flag], [flag], ...
%     You can input any number of the following strings (" or '):
% 
%     "-all"
%         Search for all instances of the file on the MATLAB search path. Output
%         is then always a string array or cell array of strings, including if
%         one or no instances are found.
% 
%     "-i"
%         Case-insensitive.
%
%
% See also which.


% Giles Holland 2021, 22


flags = varargin;


    if nargin < 1
        error('Not enough inputs.')
    end

outputString = isa(fileName, 'string');
fileName = var2char(fileName);
    if ~isRowChar(fileName)
        error('File or MATLAB program name must be a string.')
    end
    if any(fileName == filesep)
        error('File name cannot contain path.')
    end
    
flags = var2char(flags);


pff = transpose(which(fileName, '-all'));

%No variables
pff = strremove(pff, 'variable');

%No privates
[aa, ~, ~] = filepartsish(pff);
pff(strends(aa, [filesep 'private'])) = [];


%Case sensitivity
%---
%For m/p files WHICH is case-sensitive if exact match exists, else not.
%e.g. if PB_RUN and pb_run exist,  which PB_RUN finds only PB_RUN              (same as what it will call).
%     and if PB_ruN doesn't exist, which pb_ruN returns both pb_run and PB_RUN (yet still won't run pb_run if call pb_ruN).
%whichFile is case-sensitive by default.
if ~any(strcmpi(flags, '-i'))
    %Case-sensitive
    
    if any(fileName == '.')
        [~, b,  c ] = filepartsish(fileName);
        [~, bb, cc] = filepartsish(pff);
        tf_x = ~(strcmp(bb, b) & strcmp(cc, c));
    else
        %No extension in searched file name -> WHICH returned .m, .p, or an exact match (no extension)
        [~, bb] = filepartsish(pff);
        tf_x = ~strcmp(bb, fileName);
    end

    pff(tf_x) = [];
end
%---


if any(strcmpi(flags, '-all'))
    %Return all
        out = pff;
else
    %Return first instance
    if isempty(pff)
        out = '';
    else
        out = pff{1};
    end
end


if outputString
    if isempty(out)
        out = strings(0);
    else
        out = string(out);
    end
end


end %whichFile




function [a, b, c] = filepartsish(x) %local

%Makes consistent and fixes cellstr input/output for fileparts().
%fileparts() only takes cellstr inputs after a certain MATLAB version.
%Even when it does it's a little broken--if a cellstr input and one output doesn't output as cellstr.


if isa(x, 'cell')
        a = cell(size(x));
        b = cell(size(x));
        c = cell(size(x));
    for i = 1:numel(x)
        [a{i}, b{i}, c{i}] = fileparts(x{i});
    end
else
        [a, b, c] = fileparts(x);
end


end %filepartsish