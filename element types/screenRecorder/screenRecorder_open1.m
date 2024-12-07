%Giles Holland 2022-24


        %(Handle deprecated)
        %---
        if isfield(this, 'snapWidth')
            if ~isempty(this.snapWidth)
                this.outputWidthSnap = this.snapWidth;
            %else default value in outputWidthSnap
            end
        end
        %---


%Initialize record properties that catch script uses in case error
this.saveImage = false;
this.saveImages = false;
this.saveMovie = false;
this.n_movie = [];


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.size = element_deg2px(this.size);

%Standardize strings from "x"/'x' to 'x'
this.fileName = var2char(this.fileName);
this.elementExpr = var2char(this.elementExpr);
this.movieOptions = var2char(this.movieOptions);
%---


fileName = this.fileName;
numberFile = this.numberFile;
minNumDigitsInFileName = this.minNumDigitsInFileName;
elementExpr = this.elementExpr;
siz = this.size;
outputWidth = this.outputWidth;
outputWidthSnap = this.outputWidthSnap;
frameRate = this.frameRate;
movieOptions = this.movieOptions;
n_window = this.n_window;
position = this.position;
windowSize = devices.screen.windowSize;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isRowChar(fileName) && any(fileName(1:end-1) == '.'))
    error('Property .fileName must be a string including file extension.')
end
if ~is01(numberFile)
    error('Property .numberFile must be true/false.')
end

if ~(isRowNum(minNumDigitsInFileName) && ismember(numel(minNumDigitsInFileName), [1 2]) && all(isIntegerVal(minNumDigitsInFileName)))
    error('Property .minNumDigitsInFileName must be an integer or 1x2 vector of integers.')
end
minNumDigitsInFileName = max(minNumDigitsInFileName, 1);
this.minNumDigitsInFileName = minNumDigitsInFileName;

if ~(isRowChar(elementExpr) || isempty(elementExpr))
    error('Property .elementExpr must be a string or [].')
end
if ~(isRowNum(siz) && (numel(siz) == 1 && siz == inf || numel(siz) == 2 && all(siz > 0)))
    error('Property .size must be a 1x2 vector of numbers > 0, or [].')
end

if ~(isOneNum(outputWidth) && isIntegerVal(outputWidth) && outputWidth > 0 || isempty(outputWidth))
    error('Property .outputWidth must be an integer > 0, or [].')
end
if ~(isOneNum(outputWidthSnap) && isIntegerVal(outputWidthSnap) && outputWidthSnap > 0)
    error('Property .outputWidthSnap must be an integer > 0.')
end
if ~(isOneNum(frameRate) && isIntegerVal(frameRate) && frameRate > 0)
    error('Property .frameRate must be an integer > 0.')
end
if ~(isRowChar(movieOptions) || isempty(movieOptions))
    error('Property .movieOptions must be a string or [].')
end
%---


%Get file type to make from file extension
    saveImage = false;
    saveImages = false;
    saveMovie = false;
%Don't use fileparts yet cause it can't handle ...
if      numel(fileName) >= 6 && strcmp(fileName(end-2:end), '...')
    %e.g. picture.jpeg... = save multiple jpegs
    
    saveImages = true;
    
    fileName(end-2:end) = [];
end
[path, fileNameBase, fileExtension] = fileparts(fileName);
fileExtension = lower(fileExtension);
if      ismember(fileExtension, {'.bmp' '.gif' '.hdf' '.jpg' '.jpeg' '.jp2' '.jpx' '.pbm' '.pcx' '.pgm' '.png' '.pnm' '.ppm' '.ras' '.tif' '.tiff' '.xwd'})
    %Image format supported by MATLAB imwrite().
    %Save one image unless multiple images set by user.
    
    saveImage = ~saveImages;
elseif  ismember(fileExtension, {'.asf' '.avi' '.3gp' '.mp4' '.mov' '.flv' '.mpg' '.mpeg' '.m2p' '.ps' '.mkv' '.webm' '.mxf' '.ogg'})
    %Movie format supported by GStreamer/Psychtoolbox
    
    saveMovie = true;
    saveImages = false;
else
        error(['In property .fileName: "' fileExtension '" is not a supported image or movie type.'])
end

    if saveMovie && any(isspace(fileName))
        error('In property .fileName: Currently Psychtoolbox cannot handle movie file names that contain spaces. Please use a different name. (Note this includes any path you specify. If the spaces are in a path, you could change the MATLAB current folder to that location so you don''t need to specify the path.)')
    end

%Make folder for file if doesn't exist
[~, x] = whereFile(path);
if isempty(x)
    try
        [tf, XMsg] = mkdir(path); if ~tf, error(XMsg), end
    catch X
            if any(path == filesep)
                error(['Cannot make folder ' path '.' 10 ...
                    '->' 10 ...
                    10 ...
                    X.message])
            else
                error(['Cannot make folder "' path '".' 10 ...
                    '->' 10 ...
                    10 ...
                    X.message])
            end
    end

elseif ~numberFile
        %Check if exists at experiment start cause better to error then than part way through experiment.
        %Will re-check in runFrame/close script in case file/folder gets created by something else before then.
        if saveImages
            p = fullfile(path, fileNameBase);
            [~, x] = whereFile(p);
            if ~isempty(x)
                if any(p == filesep)
                    error(['Folder ' p ' already exists.'])
                else
                    error(['Folder "' p '" already exists.'])
                end
            end
        else
            if ~isempty(whereFile(fileName))
                error([fileName ' already exists.'])
            end
        end

%elseif numberFile = true then numbers file/folder to not overwrite
end
%Checked PTB CreateMovie can handle relative paths, so don't need to fix that

if saveImages && numel(minNumDigitsInFileName) == 1
    if numberFile
        %Numbering folder, so single minNumDigitsInFileName -> folder, default minNumDigitsInFileName for numbering files = 1
        minNumDigitsInFileName(2) = 1;
    else
        %Not numbering folder, so single minNumDigitsInFileName -> numbering files
        minNumDigitsInFileName = [1 minNumDigitsInFileName(1)];
    end
end


if ~isempty(elementExpr)
    %Get index of object to capture
    i_element = element_getElementIndex(elementExpr);
    element = element_getElement(i_element);
        if ~ismember('screen', element.with)
            error('If property .elementExpr is set, target element must be a visual element.')
        end
else
    i_element = [];
end

if isempty(i_element)
    if numel(siz) == 1 && siz == inf
        %Capture whole window
        rect = [0 0 windowSize];
        siz = windowSize;
    else
        %Calculate rect to capture on screen based on user set size and position.
        %Separate round to always maintain size ratio.
        rect = round([0 0 siz])+round(repmat(-(siz+1)/2+position, 1, 2));
            if any(rect(1:2) >= windowSize | rect(3:4) <= 0)
                error('In properties .position, .size: Whole capture area is outside the experiment window.')
            end
        %Clip to window edges
        rect = [max(rect(1:2), [0 0]) min(rect(3:4), windowSize)];

        siz = rect(3:4)-rect(1:2);
    end
    
    if isempty(outputWidth)
        %Size of output images (px) = size of input
                outputSize = siz;
        if saveMovie && outputWidthSnap > 1
            %Movie -> snap size of output images to integer multiple of outputWidthSnap
            r = mod(outputSize(1), outputWidthSnap);
            if r > 0
                    s = round((outputSize(1)-r)/outputSize(1)*outputSize);
                if r > outputWidthSnap/2 || any(s <= 0)
                    s = round((outputSize(1)+outputWidthSnap-r)/outputSize(1)*outputSize);
                end
                outputSize = s;
            end
        end
    else
        %Specified size of output images (px)
                outputSize = max(round(outputWidth/siz(1)*siz), 1);
    end
else
        %Will get based on target element (elementExpr)
        rect = [];
        outputSize = [];
end


if saveMovie    
    %Call CreateMovie (create and delete dummy movie) once when first screenRecorder
    %that will use it in the experiment opens, cause calls CreateMovie in frames, so
    %needs to be fast, but first time calling only is slow.
    %See help element_doShared on indexVals input.
    indexVals = '-all';
    element_doShared(@spinupCreateMovie, n_window, indexVals)
end


%Object needs to run after all other objects each frame cause captures from the
%draw buffer, so all other objects need to have drawn to the buffer
this = element_setFrameOrder(this, 'after');


this.fileName = fileName;
this.minNumDigitsInFileName = minNumDigitsInFileName;
this.size = siz;
this.saveImage = saveImage;
this.saveImages = saveImages;
this.saveMovie = saveMovie;
this.rect = rect;
this.outputSize = outputSize;
this.i_element = i_element;

%Initialize some record properties for first iteration of runFrame, close
this.captureStartTime = [];
this.numImagesCaptured = 0;
this.nn_textures = [];
this.n_movie = [];
this.fileName_r = [];
this.n_file = [];




function spinupCreateMovie(n_window) %local


n_movie = Screen('CreateMovie', n_window, 'hdakjdgahgqgwedascv23784qrywuakjsgd.avi', 160, 160);
Screen('FinalizeMovie', n_movie);
delete('hdakjdgahgqgwedascv23784qrywuakjsgd.avi')


end