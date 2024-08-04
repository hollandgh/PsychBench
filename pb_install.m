function pb_install

% 
% PB_INSTALL
% 
% PsychBench Installer (2024.05.22)
% 
% PsychBench is a third-party MATLAB toolbox. PB_INSTALL downloads and unzips
% PsychBench, adds it to the MATLAB search path, does some setup internal to 
% PsychBench, and adds a line to your MATLAB startup.m file. Other than startup.m,
% PB_INSTALL doesn't modify anything on your system.
% 
% 
% USAGE
% 
% 1. Put pb_install.m in the location where you want the PsychBench folder to be.
% 2. Set the MATLAB current folder to there (use the toolbar or the <a href="matlab:disp([10 10 10 '------------']), help cd">cd</a> command).
% 3. Type PB_INSTALL at the MATLAB command line.
% 
% 
% SYSTEM REQUIREMENTS
% 
% - Windows (10 version 22H2 recommended) / macOS (Ventura recommended) / 
%   Linux (most recent Ubuntu LTS recommended)
%
% - <a href="matlab:web(''https://www.mathworks.com/products/matlab.html'', ''-browser'')">MATLAB</a> R2017a or later (R2019a+ for visual method of making experiments, R2021a+ recommended)
%   PsychBench does not run in GNU Octave.
%
% - <a href="matlab:web(''http://psychtoolbox.org'', ''-browser'')">Psychtoolbox</a> most recent version (free)
%
% - Psychtoolbox requires GStreamer (free):
%   Windows: <a href="matlab:web(''https://gstreamer.freedesktop.org/data/pkg/windows/1.22.5/msvc/gstreamer-1.0-msvc-x86_64-1.22.5.msi'', ''-browser'')">GStreamer 64-bit MSVC runtime 1.22.5</a>
%   Mac:     <a href="matlab:web(''https://gstreamer.freedesktop.org/data/pkg/osx/1.22.1/gstreamer-1.0-1.22.1-universal.pkg'', ''-browser'')">GStreamer runtime 1.22.1</a>
%   Linux:   generally already installed
%   Note Homebrew installations of GStreamer will not work.
%
% See <a href="matlab:web(''https://www.psychbench.org/sysreqs'', ''-browser'')">system requirements</a> for details.
% 
% 
% (COMPATIBILITY SETTINGS)
%
% After installing, if you see problems like failing to open or close the
% experiment window (especially on Mac, sometimes on Windows), you may want to
% use <a href="matlab:disp([10 10 10 '------------']), help pb_prefs">pb_prefs</a> -> screen -> disable Psychtoolbox sync tests and/or enable system compositor 
% (or on MATLAB versions < R2021a: add lines "screen.doSyncTests = -1; screen.useCompositor = true;" 
% to the script pb_prefs() opens). Note this generally reduces timing precision,
% but Psychtoolbox recommends not running precise timing experiments on such
% systems anyway. You can still develop and test precise timing experiments
% and/or run experiments that don't need precise timing. For more information
% from Psychtoolbox, see <a href="matlab:web(''http://psychtoolbox.org/docs/SyncTrouble'', ''-browser'')">SyncTrouble</a>.


%Use only basic MATLAB until installed.
%When installed added at top of search path so know will beat out any conflicts.


    if exist('OCTAVE_VERSION', 'builtin')
        error('PsychBench does not run in GNU Octave.')
    end
    %Check as of this installer.
    %Check as of version downloaded below.
    if verLessThan('matlab', '9.2')
        error('PsychBench requires MATLAB R2017a or later (R2019a+ for visual method of making experiments, R2021a+ recommended).')
    end
    
if verLessThan('matlab', '9.6')
    disp(' ')
    warning('PsychBench requires MATLAB R2019a or later for the visual method of making experiments (R2021a or later recommended). However, the coding method still works in R2017a or later.')
    r = inputish('Continue? (y/n) ', {'y' 'n'});
    if strcmp(r, 'n')
        return
    end
end
    
    
origCurrentPath = cd;


%Undocumented:
%pb_install doesn't need to be in current folder, just typically is so that MATLAB sees it.
%Its location determines location of install.
pf = which('pb_install');
[parentPath, ~, ~] = fileparts(pf);
corePath = fullfile(parentPath, 'PsychBench');


%Confirm install
    x = [10 ...
        10 ...
        'PsychBench Installer' 10 ...
        'Type "help pb_install" for information, including system requirements.' 10 ...
        10 ...
        10 ...
        'pb_install() will install PsychBench in' 10 ...
        corePath 10 ...
        10 ...
        ];
if ispc && ~isempty(strfind(corePath, [filesep 'OneDrive'])) || ismac && ~isempty(strfind(corePath, [filesep 'com~apple~CloudDocs']))
    x = [x 'Note this may be a cloud location. It is not recommended to install PsychBench ' 10 ...
        'in a cloud location.' 10 ...
        ];
end
    x = [x 10 ...
        'Continue? (y/n) '];
r = inputish(x, {'y' 'n'});
if strcmp(r, 'n')
    return
end
    %Note exist handles case-insensitive
    if exist(corePath, 'dir')
        error('Folder already exists. Remove the folder before installing. If this is an existing copy of PsychBench and you want to update it, use pb_update() instead.')
    end
    if exist(fullfile(parentPath, 'PsychBench.zip'), 'file')
        error([fullfile(parentPath, 'PsychBench.zip') 10 ...
            'exists. Please delete it to run pb_install().'])
    end

    
%Download pbv
disp([10 ...
    'Contacting web server and downloading...' 10 ...
    'This is usually fast but in some cases can take minutes--please wait.' 10 ...
    'You can press Ctrl+C to cancel.' ...
    ])
    o = weboptions('ContentType', 'text');
try
    pbv = webread('https://storage.googleapis.com/psychbench/pbv1.txt', o);
catch
try
    pbv = webread('https://storage.googleapis.com/psychbench/pbv2.txt', o);
catch X
        error(['Cannot download PsychBench. Please check your internet connection. Sometimes it works to just try again.' 10 ...
            '->' 10 ...
            10 ...
            X.message])
end
end
pbv = strip(pbv);
ii = find(pbv == ' ');
%     n_version = str2double(pbv(1:ii(1)-1));
% downloadId = pbv(ii(1)+1:ii(2)-1);
downloadLink = pbv(ii(1)+1:ii(2)-1);
n_matlabVersion_s = pbv(ii(3)+1:ii(4)-1);
matlabRelease = pbv(ii(4)+1:end);

%In case downloading version later than this installer so check above out of date
if verLessThan('matlab', n_matlabVersion_s)
    error(['PsychBench requires MATLAB ' matlabRelease ' or later.'])
end


%Download and unzip PsychBench.
%If this link breaks I can just update all the pbvs, and can't download zip files from other services, so don't need a backup link.
try
    websave(fullfile(parentPath, 'PsychBench.zip'), downloadLink);
    pause(1)
catch X
        error(['Cannot download PsychBench. Please check your internet connection and that you have write permission. Sometimes it works to just try again.' 10 ...
            '->' 10 ...
            10 ...
            X.message])
end
    unzip(fullfile(parentPath, 'PsychBench.zip'), parentPath)
    pause(1)


%Show license
f = fopen(fullfile(corePath, 'docs', 'PsychBench End User License Agreement.txt'), 'rt');
license = transpose(fread(f, inf, '*char'));
fclose(f);    
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
    'Do you accept the license agreement? (y/n) '], {'y' 'n'});
if strcmp(r, 'n')
    try %#ok<TRYNC>
        rmdir(corePath, 's');
    end
    try %#ok<TRYNC>
        delete(fullfile(parentPath, 'PsychBench.zip'))
    end
    disp([10 ...
        'PsychBench not installed.' ...
        ])
    return
end


%Set up local element classes library.
%Separate so error here doesn't affect main install--can re-do this after install.
%---
disp([10 ...
    10 ...
    'PsychBench will now ask you to choose a location to make your local element ' 10 ...
    'types folder in. If you add code for custom stimuli or functionality, it ' 10 ...
    'will go in this folder. It must be outside the PsychBench folder. You can ' 10 ...
    'move it anytime later--PsychBench will just ask for its new location.' 10 ...
    'Press any key to continue...' ...
    ])
pause

    done = false;
while ~done
    %Choose location
        p = uigetdir(parentPath, 'Make local element types folder in...');
    while   isa(p, 'numeric') && p == 0 || ...
            isa(p, 'char') && (strcmp(p, corePath) || length(p) >= length([corePath filesep]) && strcmp(p(1:length([corePath filesep])), [corePath filesep]))

        if  isa(p, 'char') && (strcmp(p, corePath) || length(p) >= length([corePath filesep]) && strcmp(p(1:length([corePath filesep])), [corePath filesep]))

            disp([10 ...
                'Local element types folder must be outside the PsychBench folder. Please choose again.' 10 ...
                'Press any key to continue...' ...
                ])
            pause
        end

        p = uigetdir(parentPath, 'Make local element types folder in...');
    end
        [~, b, ~] = fileparts(p);
        if strcmp(b, 'PsychBench local element types')
            localElementClassesPath = p;
        else
            localElementClassesPath = fullfile(p, 'PsychBench local element types');
        end

    %Make folder.
    %Note exist handles case-insensitive.
    if ~exist(localElementClassesPath, 'dir')
        try
            [tf, XMsg] = mkdir(localElementClassesPath); if ~tf, error(XMsg), end
        catch X
                warning(['Cannot make folder ' localElementClassesPath '.' 10 ...
                    '->' 10 ...
                    10 ...
                    X.message])
                disp([10 ...
                    'Please choose again.' 10 ...
                    'Press any key to continue...' ...
                    ])
                pause                
                continue
        end                
    end
    if ~exist(fullfile(localElementClassesPath, 'common'), 'dir')
        try
            [tf, XMsg] = mkdir(fullfile(localElementClassesPath, 'common')); if ~tf, error(XMsg), end
        catch X
                warning(['Cannot make folder ' fullfile(localElementClassesPath, 'common') '.' 10 ...
                    '->' 10 ...
                    10 ...
                    X.message])
                disp([10 ...
                    'Please choose again.' 10 ...
                    'Press any key to continue...' ...
                    ])
                pause                
                continue
        end                
    end
    
    done = true;
end

disp([10 ...
    'Using local element types folder:' 10 ...
    localElementClassesPath ...
    ])

%Save path in text file
f = fopen(fullfile(corePath, 'core', 'pb', 'localElementClassesPath.txt'), 'wt');
fwrite(f, localElementClassesPath);
fclose(f);
%---


%Add to top of search path.
%Full rehash cause partial can fail (e.g. file renamed) and this function not used generally.
addpath(genpath(localElementClassesPath));
addpath(genpath(corePath));
savepath
%cd = pb so no conflicts with files in cd
cd(corePath);
rehash path
%-----------------------------------------CAN USE PSYCHBENCH FUNCTIONS PAST HERE


try


%Delete zip
try
    deleteFile(fullfile(parentPath, 'PsychBench.zip'))
catch X
    warning(['Failed to delete ' fullfile(parentPath, 'PsychBench.zip') '.' 10 ...
        'Please delete this temp file manually.' 10 ...
        '->' 10 ...
        10 ...
        X.message])
end

%Delete post-update if any
if exist(fullfile(corePath, 'moreUpdate.m'), 'file')
    try
        deleteFile(fullfile(corePath, 'moreUpdate.m'))
    catch X
        warning(['Failed to delete ' fullfile(corePath, 'moreUpdate.m') '.' 10 ...
            'Please delete this temp file manually.' 10 ...
            '->' 10 ...
            10 ...
            X.message])
    end
end


%Make element constructors, including for any local classes present from any previous installation
%---
elementClassNames = {};

%Built-in
classNames = {};
s = dirish(fullfile(corePath, 'element types'));
classNames = [classNames {s([s(:).isdir] & ~[s(:).ishidden] & ~strisin({s(:).name}, {'contributed' 'common'})).name}];
s = dirish(fullfile(corePath, 'element types', 'contributed'));
classNames = [classNames {s([s(:).isdir] & ~[s(:).ishidden]).name}];
elementClassNames = [elementClassNames classNames];

%Local
s = dirish(localElementClassesPath);
classNames = {s([s(:).isdir] & ~[s(:).ishidden] & ~strcmp({s(:).name}, 'common')).name};
    tf_x = false(size(classNames));
for i = 1:numel(classNames)
    className = classNames{i};

    tf_x(i) = ~(isvarname(className) && length(className) >= 3 && isLower(className(1)));
end
classNames(tf_x) = [];
elementClassNames = [elementClassNames classNames];


for className = elementClassNames, className = className{1};
    makeElementConstructor(className, fullfile(corePath, 'core', 'element', 'constructors'))
end
%---


%Check and fix text file eols in core.
%Below constructors cause less important, though don't expect error cause writing to core which we just made.
%---
s = dirishr(corePath, '*.txt');
pathfileNames = {s(~[s(:).ishidden]).folder__name};

for pathfileName = pathfileNames, pathfileName = pathfileName{1};
    fixEols(pathfileName);
end
%---


%Try update MATLAB startup.m.
%Least important.
%---
pb_updateStartup
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


%cd here so finds correct pb_install
cd(origCurrentPath);


r = inputish([10 ...
    'Delete pb_install.m? (You don''t need it anymore.) (y/n) '], {'y' 'n'});
if strcmp(r, 'y')
        x = recycle('on');
    try
        %Delete needs full path
        deleteFile(whichFile('pb_install.m'))
        disp([10 ...
            'pb_install.m deleted.' ...
            ])
    catch X
        warning(['Cannot delete pb_install.m.' 10 ...
            '->' 10 ...
            10 ...
            X.message])
    end
        recycle(x);
end


    x = [10 ...
        10 ...
        'To get started, see <a href="matlab:web(''https://www.psychbench.org/docs/gettingstarted'', ''-browser'')">Getting started / Making an experiment</a> and check out the <a href="matlab:web(''https://www.youtube.com/watch?v=PsJgvJN0H7c'', ''-browser'')">tutorial video</a>.' 10 ...
        'See also demos in <a href="matlab:sysOpen(''' fullfile(corePath, 'docs', 'demos') ''')"><PsychBench folder>' filesep 'docs' filesep 'demos</a>.' 10 ...
        10 ...
        'Access all documentation:      <a href="matlab:disp([10 10 10 ''------------'']), help pb">pb</a>' 10 ...
        'Set preferences:               <a href="matlab:disp([10 10 10 ''------------'']), help pb_prefs">pb_prefs</a>' 10 ...
        'See open source element types: <a href="matlab:sysOpen(''' fullfile(corePath, 'element types') ''')"><PsychBench folder>' filesep 'element types</a> (do not edit in place--use <a href="matlab:disp([10 10 10 ''------------'']), help newPbType">newPbType</a> to fork)' 10 ...
        'Check for updates:             <a href="matlab:disp([10 10 10 ''------------'']), help pb_update">pb_update</a>' 10 ...
        'Uninstall:                     <a href="matlab:disp([10 10 10 ''------------'']), help pb_uninstall">pb_uninstall</a>' 10 ...
        10 ...
        ];
if ispc
    x = [x '(*) PSYCHTOOLBOX SYNC TESTS' 10 ...
        'At its default settings Psychtoolbox will not open an experiment window if ' 10 ...
        'your system fails Psychtoolbox''s screen synchronization tests. If your system' 10 ...
        'often fails these tests, you can disable them in <a href="matlab:disp([10 10 10 ''------------'']), help pb_prefs">pb_prefs</a> -> screen tab ' 10 ...
        '(or on MATLAB versions < R2021a: add line "screen.doSyncTests = -1;" to the ' 10 ...
        'script pb_prefs() opens). Note this generally reduces timing precision, but ' 10 ...
        'Psychtoolbox recommends not running precise timing experiments on such systems ' 10 ...
        'anyway. You can still develop and test precise timing experiments and/or ' 10 ...
        'run experiments that don''t need precise timing. For more information from Psychtoolbox, ' 10 ...
        'see <a href="matlab:web(''http://psychtoolbox.org/docs/SyncTrouble'', ''-browser'')">SyncTrouble</a>.' 10 ...
        10 ...
        ...
        ];
elseif ismac
    x = [x '(*) MAC' 10 ...
        'At its default settings Psychtoolbox can have compatibility issues on Mac. If' 10 ...
        'you see problems like failing to open or close the experiment window, you may' 10 ...
        'want to use <a href="matlab:disp([10 10 10 ''------------'']), help pb_prefs">pb_prefs</a> -> screen -> disable Psychtoolbox sync tests and/or ' 10 ...
        'enable system compositor (or on MATLAB versions < R2021a: add lines ' 10 ...
        '"screen.doSyncTests = -1; screen.useCompositor = true;" to the script pb_prefs() ' 10 ...
        'opens). Note this generally reduces timing precision, but Psychtoolbox ' 10 ...
        'recommends not running precise timing experiments on Mac anyway. You can still ' 10 ...
        'develop and test precise timing experiments and/or run experiments that don''t ' 10 ...
        'need precise timing. For more information from Psychtoolbox, see <a href="matlab:web(''http://psychtoolbox.org/docs/SyncTrouble'', ''-browser'')">SyncTrouble</a>.' 10 ...        
        10 ...
        ...
        ];
end
    x = [x 'Thank-you!' 10 ...
    10 ...
    ];
disp(x)


catch X
        cd(origCurrentPath);
        rethrow(X)
end


end %pb_install




function response = inputish(prompt, responsesAllowed) %subfunction


responsesAllowed = lower(responsesAllowed);
fprintf(1, '%s', prompt);
    tf = false;
while ~tf
    response = input('', 's');
    response = lower(response);
    tf = ismember(response, responsesAllowed);
end


end %inputish