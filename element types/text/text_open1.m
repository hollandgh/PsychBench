%Giles Holland 2022


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
[this.fontSize, fontSizeUnit] = element_deg2px(this.fontSize);
this.boxSize = element_deg2px(this.boxSize);
this.margin = element_deg2px(this.margin);

%Standardize strings from "x"/'x' to 'x'
this.text = var2char(this.text);
this.fileName = var2char(this.fileName);
this.fontName = var2char(this.fontName);
this.style = var2char(this.style);
this.alignment = var2char(this.alignment);
this.boxSize = var2char(this.boxSize);
this.vertAlignment = var2char(this.vertAlignment);
%---


text = this.text;
fileName = this.fileName;
wrapWidth = this.wrapWidth;
fontName = this.fontName;
fontSize = this.fontSize;
style = this.style;
color = this.color;
alignment = this.alignment;
vertAlignment = this.vertAlignment;
lineSpacing = this.lineSpacing;
boxSize = this.boxSize;
margin = this.margin;
boxColor = this.boxColor;
px2fontSize = devices.screen.px2fontSize;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if isRowNum(text)
    %Accept number or row vector -> convert to string
    text = num2str(text);
else
    if ~(isRowChar(text) || isa(text, 'cell') && isvector(text) && all(cellfun(@(x) isRowChar(x),    text)) || isempty(text))
        error('Property .text must be a string, row/column array of strings, number or row vector, or [].')
    end
end
this.text = text;

if ~(isRowChar(fileName) || isempty(fileName))
    error('Property .fileName must be a string or [].')
end

if ~(isOneNum(wrapWidth) && isIntegerVal(wrapWidth) && wrapWidth > 0)
    error('Property .wrapWidth must be an integer > 0.')
end
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


if ~(isa(style, 'char') && any(strcmpi(style, {'r' 'b' 'i' 'u'})))
    error('Property .style must be a string "r", "b", "i", or "u".')
end
if ~isRgb1(color)
    error('Property .color must be a 1x3 vector with numbers between 0-1.')
end
if ~(isa(alignment, 'char') && any(strcmpi(alignment, {'l' 'c'})))
    error('Property .alignment must be a string "l" or "c".')
end
if ~(isOneNum(lineSpacing) && lineSpacing >= 1)
    error('Property .lineSpacing must be a number >= 1.')
end


if isOneNum(boxSize)
    %Square
    boxSize = [boxSize boxSize];
end
if ~(isRowNum(boxSize) && numel(boxSize) == 2 && all(boxSize >= 0) || isa(boxSize, 'char') && strcmpi(boxSize, 'f'))
    error('Property .boxSize must be a number or 1x2 vector of numbers >= 0, or a string "f".')
end
if isa(boxSize, 'numeric') && any(boxSize == 0)
    boxSize = [0 0];
end
this.boxSize = boxSize;

if ~(isa(boxSize, 'numeric') && boxSize(1) == 0)
    if ~(isOneNum(margin) && margin >= 0)
        error('Property .margin must be a number >= 0.')
    end
    if ~isRgb1(boxColor)
        error('Property .boxColor must be a 1x3 vector with numbers between 0-1.')
    end
    if ~(isa(vertAlignment, 'char') && any(strcmpi(vertAlignment, {'t' 'c'})))
        error('Property .vertAlignment must be a string "t" or "c".')
    end
else
    %Transparent background if no box.
    %Transparent version of line color prevents artifacts if adjacent pixels are blended, e.g. if rotation.
    boxColor = [color 0];
    this.boxColor = boxColor;
end
%---


%Load, process text...
%Encapsulate in functions and do shared so only computes once for all objects of
%this type with the same function input values.

text = element_doShared(@loadText, text, fileName);

%Cannot include in do shared cause depends on whole objects, which cannot input to do shared
text = text_doEvals(text, this, trial, experiment);

[lines, formatChanges, linePositions, boxSize, siz] = element_doShared(@processText, text, wrapWidth, fontName, fontSize, style, alignment, vertAlignment, lineSpacing, boxSize, margin, fontSizeUnit, px2fontSize);


this.text = text;
this.boxSize = boxSize;
this.lines = lines;
this.formatChanges = formatChanges;
this.linePositions = linePositions;
this.size = siz;


%end script




function text = loadText(text, fileName) %local function


if ~isempty(fileName)
    %Load text from file
    
    n_file = fopen(fileName, 'rt');
        if n_file == -1
            error(['Cannot load ' fileName '.'])
        end
    text = row(fread(n_file, inf, '*char'));
    fclose(n_file);
else
    %Text set directly in .text, maybe empty

    if      isempty(text)
        text = '';
    elseif  isa(text, 'cell')
        %Standardize lines -> one string using 10 for now
        x = '';
        for i = 1:numel(text)-1
            x = [x text{i} 10]; %#ok<*AGROW>
        end
        x = [x text{end}];
        text = x;
    end
end


end %loadText




function [lines, formatChanges, linePositions, boxSize, siz] = processText(text, wrapWidth, fontName, fontSize, style, alignment, vertAlignment, lineSpacing, boxSize, margin, fontSizeUnit, px2fontSize) %local function


%Open text
%---
if ~isempty(text)
    %Extract in-line format changes
    [text, formatChanges] = text_getFormatChanges(text, fontSizeUnit, px2fontSize);
    
    %Break text into lines, incl wrapping.
    %After extract changes cause extract changes removes formatting characters.
    [lines, formatChanges] = text_getLines(text, formatChanges, wrapWidth);
    numLines = numel(lines);
    
    %Work around PTB bug that in some cases unicode characters cause errors if not input to DrawText as double.
    %After all MATLAB char processing done, e.g. strrep() in text_getFormatChanges.
    for n_line = 1:numLines
        lines{n_line} = double(lines{n_line});
    end
else
    lines = [];
    formatChanges = [];
end
%---


%Display dimensions
%---
if ~isempty(text)
    %Measure text

    %Make scrap texture to draw text to for measuring.
    %Open texture with default size = window size.
    %Tested and okay for measuring if texture too small for text.
    n_scrapTexture = element_openTexture;

    %White text on black background just for measuring
    text_setInitialFormat(n_scrapTexture, fontName, fontSize, style, [1 1 1], [0 0 0])

    for n_line = 1:numLines
        [lineWidths(n_line), lineLeftKernings(n_line), lineCapHeights(n_line), maxFontSizes(n_line)] = text_measureLine(lines{n_line}, formatChanges(n_line), n_scrapTexture, px2fontSize); %#ok<*AGROW>
    end
        %Apply line spacing
        lineHeights = maxFontSizes*lineSpacing;
        %Vertically center text block between top of 1st line cap and bottom of last line cap...
    if isa(boxSize, 'numeric') && boxSize(1) == 0
        %If no box then add last line space to first line (not subtract from last line cause would cut off last line descenders since texture will be fit to text)
        lastLineSpace = lineHeights(numLines)-lineCapHeights(numLines);
        lineHeights(1) = lineHeights(1)+lastLineSpace;
        lineCapHeights(1) = lineCapHeights(1)+lastLineSpace;
    else
        %If box then subtract last line space from last line (not add to first line in case vertically aligned or box fit).
        %If box fit then last line descenders go in the margin.
        lineHeights(numLines) = lineCapHeights(numLines);
    end

    %Text block size
    textSize = [max(lineWidths) sum(lineHeights)];

    %Done using scrap texture -> close using PTB Close
    Screen('Close', n_scrapTexture)
else
    %Could still have box, incl box fit to text

    textSize = [0 0];
end

if isa(boxSize, 'char') && strcmpi(boxSize, 'f')
    %Fit box to text -> box size = text block size+margin on each side

    boxSize = textSize+margin*2;
end
if boxSize(1) == 0
    %No box -> display size = text block size.
    %Add buffer of font size on all sides in case PTB detecting text bounding box is not precise.

    siz = textSize+2*fontSize;
else
    %Display size = box size.
    %If user sets text size > box size text will run outside box and maybe outside display.

    siz = boxSize;    
end
    if ~all(siz > 0)
        error('Either text or a text box must be set.')
    end
%---


%Get line positions with top left corner of display at [0 0] cause display stored in a texture fit to display below
%---
if ~isempty(text)
        if strcmpi(alignment, 'l')
            if boxSize(1) == 0
                %Horz align all lines at left of display area + buffer
                lineLeft = 0.1*fontSize;
            else
                %Horz align all lines at left of box + margin
                lineLeft = margin;
            end
        end
        if strcmpi(vertAlignment, 't')
            if boxSize(1) == 0
                %Vert align text block at top of display area + buffer
                textTop = 0.1*fontSize;
            else
                %Vert align text block at top of box + margin
                textTop = margin;
            end
        else
                %Vert center text block in display area / box
                textTop = siz(2)/2-textSize(2)/2;
        end
        
        linePositions = zeros(0, 2);
    for n_line = 1:numLines
        if strcmpi(alignment, 'c')
                %Horz center all lines in display area / box
                lineLeft = siz(1)/2-lineWidths(n_line)/2;
        end

        %Line position.
        %Last line space was added to top so +lastLineSpace to get to top of first line.
        %Will be drawing line at baseline so +lineCapHeight for y.
        linePositions(n_line,:) = [lineLeft-lineLeftKernings(n_line) textTop+sum(lineHeights(1:n_line-1))+lineCapHeights(n_line)]; %#ok<*SAGROW>
    end
else
        linePositions = [];
end
%---


end %processText