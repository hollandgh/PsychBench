function pb_install

%PB_INSTALL
%
%PsychBench Installer (2021.12.15)
%
%PsychBench is a third-party MATLAB toolbox (www.psychbench.org). PB_INSTALL
%downloads and unzips PsychBench, adds it to the MATLAB search path, and saves
%some settings in the PsychBench folders. PB_INSTALL does not modify anything
%outside the PsychBench folders and MATLAB search path.
%
% 
%SYSTEM REQUIREMENTS
%
%- Windows, macOS, or Linux
%- MATLAB R2017a or later (not GNU Octave)
%- Psychtoolbox (http://psychtoolbox.org)
%
%More specific or additional requirements depend on Psychtoolbox and what you
%want to do. See for example http://psychtoolbox.org/requirements and
%http://psychtoolbox.org/docs/GStreamer.
%
%
%USAGE
% 
%1. Put pb_install.m in the location where you want the PsychBench folder to be.
% 
%2. Set the MATLAB current folder to this location (use the toolbar or the CD command).
% 
%3. Type "pb_install" at the MATLAB command line.


%Use only basic MATLAB until installed.
%When installed added at top of search path so know will beat out any conflicts.


    if exist('OCTAVE_VERSION', 'builtin')
        error('PsychBench needs MATLAB R2017a or later. PsychBench does not run in GNU Octave.')
    end
    %Check as of this installer.
    %Check as of version downloaded below.
    if verLessThan('matlab', '9.2')
        error('PsychBench needs MATLAB R2017a or later.')
    end
    
    
%Undocumented: 
%pb_install doesn't need to be in current folder, just typically is so that MATLAB sees it.
%Its location determines location of install.
pf = which('pb_install');
[parentPath, ~, ~] = fileparts(pf);
corePath = fullfile(parentPath, 'PsychBench');

%System requirements, Confirm install
r = inputish([10 ...
    10 ...
    'PSYCHBENCH SYSTEM REQUIREMENTS' 10 ...
    10 ...
    '- Windows, macOS, or Linux' 10 ...
    '- MATLAB R2017a or later (not GNU Octave)' 10 ...
    '- Psychtoolbox (http://psychtoolbox.org)' 10 ...
    10 ...
    'More specific or additional requirements depend on Psychtoolbox and what you ' 10 ...
    'want to do. See for example http://psychtoolbox.org/requirements and ' 10 ...
    'http://psychtoolbox.org/docs/GStreamer.' 10 ...
    10 ...
    10 ...
    'PB_INSTALL will install PsychBench in' 10 ...
    corePath 10 ...
    10 ...
    'Continue? (y/n) '], {'y' 'n'}, '-i');
if strcmp(r, 'n')
    return
end
    %Note exist handles case-insensitive
    if exist(corePath, 'dir')
        error('Folder already exists. Remove the folder before installing. If this is an existing copy of PsychBench and you want to update it, use PB_UPDATE instead.')
    end

%Download pbv
disp([10 ...
    'Contacting web server and downloading...' 10 ...
    'This might take a minute--please wait. You can press Ctrl+C to cancel.' ...
    ])
try
    pbv = webread('https://drive.google.com/uc?export=download&id=17_z5Xx6dVxvoKO6rSxNoKBajRgf0YUzE');
catch
try
    pbv = webread('https://drive.google.com/uc?export=download&id=122AW4Vd1zBQkMlYSXqQCXQwEJOOjeeLC');
%     catch
%     try
%         pbv = webread('https://commonlaw.uottawa.ca/health-law/sites/commonlaw.uottawa.ca.health-law/files/pbv3.txt');
catch X
        error(['Cannot get PsychBench from the internet. Please check your internet connection. Sometimes it works to just try again.' 10 ...
            '->' 10 ...
            10 ...
            X.message])
end
end
%     end
pbv = strtrim(pbv);
ii = find(pbv == ' ');
%     n_version = str2double(pbv(1:ii(1)-1));
% downloadId = pbv(ii(1)+1:ii(2)-1);
downloadLink = pbv(ii(1)+1:ii(2)-1);
n_matlabVersion_s = pbv(ii(3)+1:ii(4)-1);
matlabRelease = pbv(ii(4)+1:end);

if verLessThan('matlab', n_matlabVersion_s)
    error(['PsychBench needs MATLAB ' matlabRelease ' or later.'])
end

%Download and unzip PsychBench.
%If this link breaks I can just update all the pbvs, and can't download zip files from other services, so don't need a backup link.
try
%     unzip(['https://drive.google.com/uc?export=download&id=' downloadId], parentPath)
    unzip(downloadLink, parentPath)
catch X
        error(['Cannot get PsychBench from the internet or cannot unzip. Please check your internet connection and that you have write permission. Sometimes it works to just try again.' 10 ...
            '->' 10 ...
            10 ...
            X.message])
end

%Show license
n_file = fopen(fullfile(corePath, 'docs', 'PsychBench End User License Agreement.txt'), 'rt');
license = transpose(fread(n_file, inf, '*char'));
fclose(n_file);    
license(license == 13) = [];
license = strtrim(license);
disp([10 ...
    10 ...
    10 ...
    '================================================================================' 10 ...
    license ...
    ])
r = inputish(['================================================================================' 10 ...
    10 ...
    10 ...
    10 ...
    'Do you accept the license agreement? (y/n) '], {'y' 'n'}, '-i');
if strcmp(r, 'n')
    rmdir(corePath, 's');
    disp([10 ...
        'PsychBench not installed.' ...
        ])
    return
end

%Add to search path
addpath(genpath(corePath));
savepath


%Set up local element classes library.
%Separate so error here doesn't affect main install--can re-do this after install.
%---
disp([10 ...
    10 ...
    'PsychBench will now ask you to choose a location to make your local element ' 10 ...
    'classes folder in. If you add code for custom stimuli or functionality, it ' 10 ...
    'will go in this folder. It must be outside the PsychBench folder. (You can ' 10 ...
    'move it anytime later--PsychBench will just ask for its new location.)' 10 ...
    'Press any key to continue...' ...
    ])
pause

%Choose location
    p = uigetdir(parentPath, 'Make local element classes folder in...');
while   isa(p, 'numeric') && p == 0 || ...
        isa(p, 'char') && (strcmp(p, corePath) || length(p) >= length([corePath filesep]) && strcmp(p(1:length([corePath filesep])), [corePath filesep]))

    if  isa(p, 'char') && (strcmp(p, corePath) || length(p) >= length([corePath filesep]) && strcmp(p(1:length([corePath filesep])), [corePath filesep]))

        disp([10 ...
            'Local element classes folder must be outside the PsychBench folder. Please choose again.' 10 ...
            'Press any key to continue...' ...
            ])
        pause
    end

    p = uigetdir(parentPath, 'Make local element classes folder in...');
end
    [~, b, ~] = fileparts(p);
    if strcmp(b, 'PsychBench local element classes')
        localElementClassesPath = p;
    else
        localElementClassesPath = fullfile(p, 'PsychBench local element classes');
    end

%Make folder.
%Note exist handles case-insensitive.
if ~exist(localElementClassesPath, 'dir')
    try
        [tf, XMsg] = mkdir(localElementClassesPath); if ~tf, error(XMsg), end
    catch X
            error(['Cannot make folder ' localElementClassesPath '.' 10 ...
                'Check that you have write permission.' 10 ...
                '->' 10 ...
                10 ...
                X.message])
    end                
end
if ~exist(fullfile(localElementClassesPath, 'common'), 'dir')
    try
        [tf, XMsg] = mkdir(fullfile(localElementClassesPath, 'common')); if ~tf, error(XMsg), end
    catch X
            error(['Cannot make folder ' fullfile(localElementClassesPath, 'common') '.' 10 ...
                'Check that you have write permission.' 10 ...
                '->' 10 ...
                10 ...
                X.message])
    end                
end

%Save path in text file
f = fopen(fullfile(corePath, 'core', 'pb', 'localElementClassesPath.txt'), 'wt');
fwrite(f, localElementClassesPath);
fclose(f);

disp([10 ...
    'Using local element classes folder:' 10 ...
    localElementClassesPath ...
    ])

%Add to search path.
%Add all to keep together and in right order.
addpath(genpath(localElementClassesPath));
addpath(genpath(corePath));
savepath
%---


%Set framework
%Allow installing framework after cause don't want to give impression can't
%install one after if other one is installed before.
%---
try 
    AssertOpenGL
    hasPtb = true;
catch
    hasPtb = false;
end
try 
    hasMgl = mglSystemCheck(1) && mglSystemCheck(2);
catch
    hasMgl = false;
end

        WITHPTB = false;
        WITHMGL = false; %#ok<NASGU> 
        withPtb = false;
        withMgl = false;
if hasPtb
        %Leave at default withPtb.
        %Default exists in case manual install.
    if hasMgl
        disp([10 ...
            10 ...
            'Both Psychtoolbox and MGL frameworks found. PsychBench will default to using ' 10 ...
            'Psychtoolbox. You can change to MGL by typing "pb_framework("mgl")", and ' 10 ...
            'change between frameworks anytime using this function.' ...
            ])
    end

        WITHPTB = true;
        withPtb = true;
else
    if hasMgl        
        disp([10 ...
            10 ...
            'MGL framework found. If you install Psychtoolbox later, you can change between ' 10 ...
            'frameworks anytime using PB_FRAMEWORK.' ...
            ])

        WITHMGL = true; %#ok<NASGU> 
        withMgl = true;        
    else
        disp([10 ...
            10 ...
            'Neither Psychtoolbox nor MGL framework found on MATLAB search path. You must ' 10 ...
            'install at least one framework before running PsychBench. PsychBench will ' 10 ...
            'default to looking for Psychtoolbox. You can change to MGL by typing "pb_framework("mgl")",' 10 ...
            'and change between frameworks anytime using this function.' ...
            ])

        WITHPTB = true;
        withPtb = true;        
    end
end
        save(fullfile(corePath, 'core', 'pb', 'pbFramework.mat'), 'withPtb', 'withMgl')
%---


%When you run your first experiment, PsychBench will ask you to specify screen
%height and distance from subject to screen (cm) if you have not already done
%so. This allows PsychBench to interpret visual angle degree units. PsychBench
%saves these measurements specific to screen, so you only need to do this once
%for a given screen. If distance changes or you change external screens, you can
%use the tool SETDEG to save new measurements anytime. Do you want to specify
%measurements for your primary screen now? (y/n)


%---
r = inputish([10 ...
    10 ...
    'When you run your first experiment, PsychBench will ask you to specify screen' 10 ...
    'height and distance from subject to screen (cm) if you have not already done' 10 ...
    'so. This allows it to interpret visual angle degree units. It saves these' 10 ...
    'measurements specific to screen, so you only need to do this once for a given' 10 ...
    'screen. If distance changes or you change external screens, you can type' 10 ...
    'SETDEG to save new measurements anytime.' 10 ...
    10 ...
    'Do you want to set measurements for your primary screen now? (y/n) '], {'y' 'n'}, '-i');
if strcmp(r, 'y')
            h = [];
            disp('Screen height, not including bezel (cm): ' ...
                )
    if WITHPTB
        try
            [~, hd] = Screen('DisplaySize', 0);
                if ~(isOneNum(hd) && hd > 0)
                    error('X')
                end
            hd = round(hd/10, 3, 'significant');
            disp(['Psychtoolbox reports ' num2str(hd) ' cm but please check this is accurate.' 10 ...
                '(Return = ' num2str(hd) ')' ...
                ])
        catch
            hd = [];
        end
    else
        try
            s = mglDescribeDisplays;
            hd = s(1).screenSizeMM(2);
                if ~(isOneNum(hd) && hd > 0)
                    error('X')
                end
            hd = round(hd/10, 3, 'significant');
            disp(['MGL reports ' num2str(hd) ' cm but please check this is accurate.' 10 ...
                '(Return = ' num2str(hd) ')' ...
                ])
        catch
            hd = [];
        end
    end
    while ~(isOneNum(h) && h > 0)
            h = inputish('', [], '-n');
        if isempty(h)
            h = hd;
        end
    end

            d = [];
            dd = round(2.8*hd, 2, 'significant');
            disp([10 ...
                'Distance from subject to screen (cm): ' 10 ...
                '(Return = ' num2str(dd) ', based on screen height)' ...
                ])
    while ~(isOneNum(d) && d > 0)
            d = inputish('', [], '-n');
        if isempty(d)
            d = dd;
        end
    end
    
    degParameters = [
        struct('n_screen', {0}, 'type', {''}, 'framework', {'ptb'}, 'height_cm', {h}, 'distance_cm', {d}) ...
        struct('n_screen', {1}, 'type', {''}, 'framework', {'mgl'}, 'height_cm', {h}, 'distance_cm', {d}) ...
        ];
    save(fullfile(corePath, 'core', 'screen', 'degParameters.mat'), 'degParameters')

    disp('Measurements saved.' ...
        )
end
%---


disp([10 ...
    10 ...
    10 ...
    '---' 10 ...
    10 ...
    pb_version 10 ...
    10 ...
    '---' 10 ...
    10 ...
    10 ...
    10 ...
    'PsychBench installed.' ...
    ])

r = inputish([10 ...
    'Delete pb_install.m? (You don''t need it anymore.) (y/n) '], {'y' 'n'}, '-i');
if strcmp(r, 'y')
    x = recycle('on');
        try
            %Delete needs full path
            delete(which('pb_install.m'))
        catch X
                error(['Cannot delete pb_install.m. Check it is not open in any apps and you have write permission.' 10 ...
                    '->' 10 ...
                    10 ...
                    X.message])
        end
    recycle(x);
    disp([10 ...
        'pb_install.m deleted.' ...
        ])
end

disp([10 ...
    10 ...
    'To get started, see video tutorials at www.psychbench.org as well as ' 10 ...
    '"PsychBench Getting Started.pdf" in <PsychBench folder>/docs.' 10 ...
    10 ...
    'To access all documentation: type "pb"' 10 ...
    'To check for updates:        type "pb_update"' 10 ...
    'To uninstall:                type "pb_uninstall"' 10 ...
    10 ...
    'Please send feature requests and bug reports to contact@psychbench.org.' 10 ...
    'Thank-you!' 10 ...
    ...
    ])

s = path;
ii = strfind(s, [filesep 'PsychBench' pathsep]);
if numel(ii) > 2
    warning([10 ...
        'There may be other installations of PsychBench already on the MATLAB search path (type "path" to see). They shouldn''t interfere with the new one but you may want to uninstall them or at least remove them from the search path.'])
end


%Rehash so can use pb files in remainder of this function
rehash
%-----------------------------------------CAN USE PSYCHBENCH FUNCTIONS PAST HERE

%Full check and fix text file eols
s = dirishr(corePath, '*.txt');
pathAndFileNames = {s(~[s(:).ishidden]).folder__name};
for pathAndFileName = pathAndFileNames, pathAndFileName = pathAndFileName{1};
    try
        fixEols(pathAndFileName);
    catch X
            if ~strcmp(X.identifier, 'fixEols:noWrite')
                rethrow(X)
            end
    end        
end


end %pb_install




function response = inputish(prompt, responsesAllowed, varargin)


flags = varargin;


if any(strcmpi(flags, '-i'))
    %Actually change them since the point of this is want the input to returned as standard lower case
    responsesAllowed = lower(responsesAllowed);
end

fprintf(1, '%s', prompt);
        tf = false;
while ~tf
        %INPUT in non-string mode accepts names of variables -> only way to avoid that is to use string mode for all.
        %Most common anyway.
        %Accepting numbers gets tricky (accepting [], accepting vectors, ...) -> TODOfprintf(1, '%s', prompt); response = input('', 's');
        response = input('', 's');
    if any(strcmpi(flags, '-i'))
        %Actually change them since the point of this is want the input to returned as standard lower case
        response = lower(response);
        tf = isempty(responsesAllowed) || any(strcmp(response, responsesAllowed));
    elseif any(strcmpi(flags, '-n'))
        response = str2num(response);
        tf = isempty(responsesAllowed) || any(response == responsesAllowed);
    else
        tf = isempty(responsesAllowed) || any(strcmp(response, responsesAllowed));
    end
end


end %inputish