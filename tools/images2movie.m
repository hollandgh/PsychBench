function images2movie(movieFileName, frameRate, movieWidth, movieWidthSnap, movieOptions)

% 
% IMAGES2MOVIE(fileName, [frameRate], [movieWidth], [movieWidthSnap], [movieOptions])
%     [input] = for default you can input [], or omit if you don't use any inputs after it.
% 
% Makes a movie file from a set of image files using Psychtoolbox functions. All
% image files must have the same size (px).
% 
% 
% INPUTS
% ----------
% 
% movieFileName
%     A string (" or ') that is name of movie file to write. Include path to
%     write in a specific folder, or omit path to write in the MATLAB current
%     folder. Codec used is automatic based on file extension (but see input 
%     "movieOptions" below if you need more control).
%
%     This also determines the image files to use: IMAGES2MOVIE will find and
%     use all image files in the same folder with names starting with this name,
%     rendering in alphanumeric order. e.g. "walker.avi" would write that movie
%     file from (e.g.) walker001.jpg, walker002.jpg, ... . (Note if using
%     numbered files, this sorting requires the same number of digits in all
%     numbers, with leading 0's where needed. Otherwise e.g. walker10.jpg sorts
%     before walker2.jpg.)
% 
% [frameRate]
%     Frame rate of movie to write (frames/sec).
% 
%     DEFAULT: 30
% 
% [movieWidth]
%     Width of movie to write (px). Height scales proportionally.
% 
%     DEFAULT: same as image width
% 
% [movieWidthSnap]
%     Some movie codecs require movie width to be a multiple of 4 or 16 px. You
%     can input a number (px), e.g. 4 or 16, to scale movie size to the nearest
%     multiple of that. Ignored if you input movie width above--in that case
%     just set that to the width you want.
% 
%     DEFAULT: 1 (don't snap)
% 
% [movieOptions]
%     A string (" or ') that goes to input "movieOptions" of Psychtoolbox 
%     <a href="matlab:web('http://psychtoolbox.org/docs/Screen-CreateMovie', '-browser')">Screen('CreateMovie')</a> setting advanced options. See help text there and 
%     <a href="matlab:web('http://psychtoolbox.org/docs/VideoRecording', '-browser')">help VideoRecording</a> for usage.
% 
%     DEFAULT: none


%Giles Holland 2024


if nargin < 2 || isempty(frameRate)
    frameRate = 30;
end
if nargin < 3 || isempty(movieWidth)
    movieWidth = [];
end
if nargin < 4 || isempty(movieWidthSnap)
    movieWidthSnap = 1;
end
if nargin < 5 || isempty(movieOptions)
    movieOptions = [];
end


    if nargin < 1
        error('Not enough inputs.')
    end
    
movieFileName = var2char(movieFileName);
    if ~(isRowChar(movieFileName) && any(movieFileName(1:end-1) == '.'))
        error('Movie file name must be a string including file extension.')
    end
    if ~(isOneNum(frameRate) && isIntegerVal(frameRate) && frameRate > 0)
        error('Frame rate must be an integer > 0.')
    end
    if ~(isOneNum(movieWidth) && isIntegerVal(movieWidth) && movieWidth > 0 || isempty(movieWidth))
        error('Movie width must be an integer > 0, or [].')
    end
    if ~(isOneNum(movieWidthSnap) && isIntegerVal(movieWidthSnap) && movieWidthSnap > 0)
        error('Movie snap width must be an integer > 0.')
    end
    
movieOptions = var2char(movieOptions);
    if ~(isRowChar(movieOptions) || isempty(movieOptions))
        error('Movie options must be a string or [].')
    end


%Checked PTB CreateMovie can handle relative paths, so don't need to fix that
[path, fileNameBase, movieFileExtension] = fileparts(movieFileName);
movieFileExtension = lower(movieFileExtension);
    if ~ismember(movieFileExtension, {'.asf' '.avi' '.3gp' '.mp4' '.mov' '.flv' '.mpg' '.mpeg' '.m2p' '.ps' '.mkv' '.webm' '.mxf' '.ogg'})
        error(['"' movieFileExtension '" is not supported by Psychtoolbox/GStreamer.'])
    end
    if any(isspace(fileNameBase))
        error('Currently Psychtoolbox requires movie file names to not contain spaces.')
    end
    
    if ~isempty(whereFile(movieFileName))
        error([movieFileName ' already exists.'])
    end

    
%Find all matching image files in same folder
    imageFileNames = {};
for imageFileExtension = {'.bmp' '.gif' '.hdf' '.jpg' '.jpeg' '.jp2' '.jpx' '.pbm' '.pcx' '.pgm' '.png' '.pnm' '.ppm' '.ras' '.tif' '.tiff' '.xwd'}, imageFileExtension = imageFileExtension{1};
    imageFileNames = [imageFileNames dirlist(fullfile(path, [fileNameBase '*' imageFileExtension]))]; %#ok<AGROW>
end
    if isempty(imageFileNames)
        if isempty(path)
            error(['No image files matching "' fileNameBase '" found in MATLAB current folder.'])
        else
            error(['No image files matching "' fileNameBase '" found in ' path '.'])
        end
    end
%Render in alpha/numeric order
    imageFileNames = sort(imageFileNames);
    

%Get image size from first image
try
    image = imreadish(imageFileNames{1});
catch X
        error(['Cannot load ' imageFileNames{1} '.' 10 ...
            '->' 10 ...
            10 ...
            X.message])
end
siz_image = size(image, [2 1]);

if isempty(movieWidth)
    %Movie size = Image size (px)
            siz_movie = siz_image;
    if movieWidthSnap > 1
        %Snap movie size to integer multiple of movieWidthSnap
        r = mod(siz_movie(1), movieWidthSnap);
        if r > 0
                s = round((siz_movie(1)-r)/siz_movie(1)*siz_movie);
            if r > movieWidthSnap/2 || any(s <= 0)
                s = round((siz_movie(1)+movieWidthSnap-r)/siz_movie(1)*siz_movie);
            end
            siz_movie = s;
        end
    end
else
    %Specified movie size (px)
            siz_movie = max(round(movieWidth/siz_image(1)*siz_image), 1);
end
            rect_movie = [0 0 siz_movie];


%--------------------------------------------------------------------------
n_movie = [];
ptbVals0 = structish({'VisualDebugLevel' 'SkipSyncTests' 'ConserveVRAM'});
try

[n_window, windowSize, ptbVals0] = openWindow(ptbVals0);

%Shrink clips to 80% of window if needed, and center
r = min([windowSize*0.8./siz_image 1]);
siz_window = r*siz_image;
rect_window = [0 0 siz_window]+repmat(-(siz_window+1)/2+(windowSize+1)/2, 1, 2);

if siz_movie(1) == siz_image(1)
    n_midTexture = [];
else
    n_midTexture = Screen('OpenOffscreenWindow', n_window, [], rect_movie);
end

    
%Setup movie file
n_movie = Screen('CreateMovie', n_window, movieFileName, siz_movie(1), siz_movie(2), frameRate, movieOptions);

    t_prev = -inf;
for fileName = imageFileNames, fileName = fileName{1};
    %Load this image
    try
        image = imreadish(fileName);
    catch X
            error(['Cannot load ' fileName '.' 10 ...
                '->' 10 ...
                10 ...
                X.message])
    end
        if ~all(size(image, [2 1]) == siz_image)
            error(['Image ' fileName ' has different size from other images. All images must have the same size.'])
        end

    %Convert to texture
    n_texture = Screen('MakeTexture', n_window, image);
    
    %Show new clip on screen every 2 sec
        t = GetSecs;
    if t > t_prev+2
        Screen('DrawTexture', n_window, n_texture, [], rect_window)
        Screen('Flip', n_window);
        t_prev = t;
    end

    if isempty(n_midTexture)
        Screen('AddFrameToMovie', n_texture, [], [], n_movie)
    else
        %Movie size ~= Image size ->
        %AddFrameToMove always adds rect = size of movie regardless of rect argument, so use intermediate texture to resize.
        Screen('DrawTexture', n_midTexture, n_texture, [], rect_movie)
        Screen('AddFrameToMovie', n_midTexture, [], [], n_movie)
    end
    
    %Close this texture
    Screen('Close', n_texture)
end

%Finalize movie
Screen('FinalizeMovie', n_movie);


%Close on-screen window and any remaining textures
sca

%Reset Psychtoolbox preferences to what user had when called
if ~isempty(ptbVals0.VisualDebugLevel)
    Screen('Preference', 'VisualDebugLevel', ptbVals0.VisualDebugLevel);
end
if ~isempty(ptbVals0.SkipSyncTests)
    Screen('Preference', 'SkipSyncTests', ptbVals0.SkipSyncTests);
end
if ~isempty(ptbVals0.ConserveVRAM)
    Screen('Preference', 'ConserveVRAM', ptbVals0.ConserveVRAM);
end


%--------------------------------------------------------------------------
catch X


    if ~isempty(n_movie)
        %Finalize and delete incomplete movie file.
        %try cause movie will already be closed if error occurred at AddFrameToMovie.

        try %#ok<TRYNC>
            Screen('FinalizeMovie', n_movie);
        end
        delete(movieFileName)
    end

    sca
    
    if ~isempty(ptbVals0.VisualDebugLevel)
        Screen('Preference', 'VisualDebugLevel', ptbVals0.VisualDebugLevel);
    end
    if ~isempty(ptbVals0.SkipSyncTests)
        Screen('Preference', 'SkipSyncTests', ptbVals0.SkipSyncTests);
    end
    if ~isempty(ptbVals0.ConserveVRAM)
        Screen('Preference', 'ConserveVRAM', ptbVals0.ConserveVRAM);
    end
    
    rethrow(X)


end


end




function [n_window, windowSize, ptbVals0] = openWindow(ptbVals0)


disp(['===========================================================================' 10 ...
    'MESSAGES FROM PSYCHTOOLBOX...' 10 ...
    10 ...
    10 ...
    ...
    ])

%Always disable PTB title screen and exclamation mark.
%Undocumented.
ptbVals0.VisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 0);

%Disable sync tests, use system compositor for compatibility, cause screen timing doesn't matter
ptbVals0.SkipSyncTests = Screen('Preference', 'SkipSyncTests', 2);
x = Screen('Preference', 'ConserveVRAM');
x = bitset(x, 15);
ptbVals0.ConserveVRAM = Screen('Preference', 'ConserveVRAM', x);

%Open window
n_screen = max(Screen('Screens'));
try
    [n_window, windowRect] = Screen('OpenWindow', n_screen, [0 0 0]);
catch
try
    [n_window, windowRect] = Screen('OpenWindow', n_screen, [0 0 0]);
catch X
        error(['Error from Psychtoolbox opening window.' 10 ...
            '->' 10 ...
            10 ...
            X.message 10 ...
            10 ...
            'More information may be in black text from Psychtoolbox above.'])
end
end
    windowSize = windowRect([3 4]);

%Set pixel range 0-1
Screen('ColorRange', n_window, 1.0, 0, 1);


end