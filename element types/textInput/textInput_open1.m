%Giles Holland 2023, 24


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.fontSize = element_deg2px(this.fontSize);
this.boxSize = element_deg2px(this.boxSize);
this.margin = element_deg2px(this.margin);

%Standardize strings from "x"/'x' to 'x'
this.fontName = var2char(this.fontName);
this.fileName = var2char(this.fileName);
%---


fontName = this.fontName;
fontSize = this.fontSize;
color = this.color;
lineSpacing = this.lineSpacing;
boxSize = this.boxSize;
margin = this.margin;
boxColor = this.boxColor;
enterResponds = this.enterResponds;
recordNumeric = this.recordNumeric;
fileName = this.fileName;
numberFile = this.numberFile;
minNumDigitsInFileName = this.minNumDigitsInFileName;
n_device = this.n_device;
px2fontSize = devices.screen.px2fontSize;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isRowChar(fontName) && ~isempty(fontName))
    error('Property .fontName must be a string.')
end

if ~isOneNum(fontSize)
    error('Property .fontSize must be a number > 0.')
end
%Font size set using PTB TextSize can be inconsistent across systems, at least if not using high quality text renderer.
%px2fontSize is a calibrated scale factor to fix this.
%PTB functions need integer font size.
fontSize = round(px2fontSize*fontSize);
if ~(fontSize > 0)
    error('Property .fontSize must be a number > 0.')
end
this.fontSize = fontSize;

if ~isRgb1(color)
    error('Property .color must be a 1x3 vector with numbers between 0-1.')
end
if ~(isOneNum(lineSpacing) && lineSpacing > 0)
    error('Property .lineSpacing must be a number > 0.')
end

if isOneNum(boxSize)
    %Square
    boxSize = [boxSize boxSize];
end
if ~(isRowNum(boxSize) && numel(boxSize) == 2 && all(boxSize > 0))
    error('Property .boxSize must be a number or 1x2 vector of numbers > 0.')
end
this.boxSize = boxSize;

if ~(isOneNum(margin) && margin >= 0)
    error('Property .margin must be a number >= 0.')
end
if ~isRgb1(boxColor)
    error('Property .boxColor must be a 1x3 vector with numbers between 0-1.')
end
if ~is01(enterResponds)
    error('Property .enterResponds must be true/false.')
end
if ~is01(recordNumeric)
    error('Property .recordNumeric must be true/false.')
end

if ~(isRowChar(fileName) || isempty(fileName))
    error('Property .fileName must be a string or [].')
end
if ~isempty(fileName)
    [~, ~, e] = fileparts(fileName);
    if isempty(e)
        fileName = [fileName '.txt'];
    end
    this.fileName = fileName;
end

if ~is01(numberFile)
    error('Property .numberFile must be true/false.')
end
if numberFile
    if ~(isOneNum(minNumDigitsInFileName) && isIntegerVal(minNumDigitsInFileName) && minNumDigitsInFileName > 0)
        error('Property .minNumDigitsInFileName must be an integer > 0.')
    end
end

if ~(isOneNum(n_device) && isIntegerVal(n_device) && n_device ~= 0 || isempty(n_device))
    error('If property .n_device must be an integer ~= 0, or [].')
end
%---


%Tell PsychBench this object will use a keyboard queue for the specified device.
%Opens keyboard queue if not already opened by another object.
%Replaces PTB KbQueueCreate, KbQueueRelease.
%Returns device number for use with PTB commands, e.g. KbQueueStart, KbEventGet.
[this, n_device] = element_openKeyboardQueue(this, n_device);


%Make folder for text file if doesn't exist
[path, ~, ~] = fileparts(fileName);
[~, p] = whereFile(path);
if isempty(p)
    try
        [tf, XMsg] = mkdir(path); if ~tf, error(XMsg), end
    catch X
            error(['Cannot make folder ' path '.' 10 ...
                '->' 10 ...
                10 ...
                X.message])
    end
end


%Blinking cursor width, line height, text wrap stops
cursorWidth = ceil(fontSize/100);
lineHeight = lineSpacing*fontSize;
stops = boxSize-[margin margin];

%Initial values for types text, cursor position, blinking cursor coordinates
text = {[]};
cursorPosition = [margin margin+fontSize];
cursorPoints = [cursorPosition cursorPosition]+[0.1*fontSize -0.9*fontSize 0.1*fontSize 0.1*fontSize];


this.n_device = n_device;
this.cursorWidth = cursorWidth;
this.lineHeight = lineHeight;
this.stops = stops;
this.text = text;
this.cursorPosition = cursorPosition;
this.cursorPoints = cursorPoints;

%Initialize some record properties for first iteration of runFrame
this.n_characterDown = [];
this.repeatTime = [];