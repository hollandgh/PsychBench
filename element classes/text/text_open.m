%TODO: TRANSPARENT TEXT AND TEXT BACKGROUND.




%PREPROCESS INPUT PROPERTIES FOR DATA TYPE, UNITS
%---
%Standardize strings from "x"/'x' to 'x'.
this.text = var2Char(this.text);
this.fileName = var2Char(this.fileName);
this.fontName = var2Char(this.fontName);
this.style = var2Char(this.style);
this.alignment = var2Char(this.alignment);
this.boxSize = var2Char(this.boxSize);
this.vertAlignment = var2Char(this.vertAlignment);

%Convert deg units to px
this.fontSize = element_deg2px(this.fontSize);
this.boxSize = element_deg2px(this.boxSize);
this.margin = element_deg2px(this.margin);
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
n_window = this.n_window;
px2fontSize = resources.screen.px2fontSize;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isRowChar(fileName) || isempty(fileName))
    error('Property .fileName must be a string or [].')
end
if isempty(fileName)
    if ~(isRowChar(text) || isa(text, 'cell') && isvector(text) && all(cellfun(@(x) isRowChar(x),    text)) || isempty(text))
        error('Property .text must be a string, row/column array of strings, or [].')
    end
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
%Font size set using PTB TextSize can be inconsistent across systems, at least
%if not using high quality text renderer. px2fontSize is a calibrated scale
%factor to fix this.
%PTB functions need integer font size.
fontSize = round(px2fontSize*fontSize);
if ~(fontSize > 0)
    error('Property .fontSize must be a number > 0.')
end

if ~(isa(style, 'char') && any(strcmpi(style, {'r' 'b' 'i' 'u'})))
    error('Property .style must be a string "r", "b", "i", or "u".')
end
if ~(isRowNum(color) && numel(color) == 3 && all(color >= 0 & color <= 1))
    error('Property .color must be a 1x3 vector with numbers between 0-1.')
end
if ~(isa(alignment, 'char') && any(strcmpi(alignment, {'l' 'c'})))
    error('Property .alignment must be a string "l" or "c".')
end
if ~(isOneNum(lineSpacing) && lineSpacing >= 1)
    error('Property .lineSpacing must be a number >= 1.')
end

if ~(isRowNum(boxSize) && (numel(boxSize) == 2 && all(boxSize >= 0) || numel(boxSize) == 1 && boxSize == 0) || isa(boxSize, 'char') && strcmpi(boxSize, 'f'))
    error('Property .boxSize must be a 1x2 vector with numbers >= 0, a string "f", or 0.')
end
if isa(boxSize, 'numeric') && any(boxSize == 0)
    boxSize = [0 0];
end
%Vertical alignment used if text box and not fit to text
if isa(boxSize, 'numeric') && boxSize(1) > 0
    if ~(isa(vertAlignment, 'char') && any(strcmpi(vertAlignment, {'t' 'c'})))
        error('Property .vertAlignment must be a string "t" or "c".')
    end
end
%Margin used if text box and text aligned left or top or box is fit to text
if isa(boxSize, 'numeric') && boxSize(1) > 0 && (strcmpi(alignment, 'l') || strcmpi(vertAlignment, 't')) || isa(boxSize, 'char') && strcmpi(boxSize, 'f')
    if ~(isOneNum(margin) && margin >= 0)
        error('Property .margin must be a number >= 0.')
    end
end

if ~(isRowNum(boxColor) && numel(boxColor) == 3 && all(boxColor >= 0 & boxColor <= 1))
    error('Property .boxColor must be a 1x3 vector with numbers between 0-1.')
end


this.fontSize = fontSize;
%---


%Load, process text.
%Maybe slow, so encapsulate in a function and share so only computes once for
%all objects of the class with the same function input values.
%---
[text, lines, formatChanges, linePositions, boxSize, siz] = element_doShared(@load__processText, text, fileName, wrapWidth, fontName, fontSize, style, color, alignment, vertAlignment, lineSpacing, boxSize, margin, n_window, px2fontSize);
%---


this.text = text;
this.fontSize = fontSize;
this.boxSize = boxSize;
this.lines = lines;
this.formatChanges = formatChanges;
this.linePositions = linePositions;
this.size = siz;


%end script




function [text, lines, formatChanges, linePositions, boxSize, siz] = load__processText(text, fileName, wrapWidth, fontName, fontSize, style, color, alignment, vertAlignment, lineSpacing, boxSize, margin, n_window, px2fontSize) %local function


%Open text
%---
if ~isempty(fileName)
    %Read text from file
    n_file = fopen(fileName, 'rt');
        if n_file == -1
            error(['Cannot load ' fileName '.'])
        end
    text = row(fread(n_file, inf, '*char'));
    fclose(n_file);
%else use text in %text
end

if ~isempty(text)
    %Break text block into lines
    lines = text_getLines(text, wrapWidth);
    numLines = numel(lines);

    %Extract in-line format changes
        formatChanges = structish({'ii' 'types' 'vals'}, numLines+1);
    for n_line = 1:numLines
        [lines{n_line}, formatChanges(n_line), formatChanges(n_line+1)] = text_extractFormatChanges(lines{n_line}, formatChanges(n_line), px2fontSize);
    end
        %Discard format changes at end of last line
        formatChanges(numLines+1) = [];
end
%---


%Display dimensions
%---
if ~isempty(text)
    %Measure text

    %Make scrap texture to draw text to for measuring.
    %Open texture with default size = window size using PTB OpenOffscreenWindow.
    %Tested and okay for measuring if texture too small for text.
    n_scrapTexture = Screen('OpenOffscreenWindow', n_window, [0 0 0]);

    text_setInitialFormat(n_scrapTexture, fontName, fontSize, style, color)

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
    %No box -> display size = text block size

    siz = textSize;
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
                %Horz align all lines at left of text block or box
                lineLeft = 0;
            if boxSize(1) > 0
                %Box -> align at margin
                lineLeft = lineLeft+margin;
            end
        end
        if boxSize(1) > 0 && strcmpi(vertAlignment, 't')
                %Vert align text block at top of box, at margin
                textTop = 0+margin;
        else
                %Vert center text block in display/box
                textTop = siz(2)/2-textSize(2)/2;
        end
        
        linePositions = zeros(0, 2);
    for n_line = 1:numLines
        if strcmpi(alignment, 'c')
                %Horz center all lines in display/box
                lineLeft = siz(1)/2-lineWidths(n_line)/2;
        end

        %Line position.
        %Last line space was added to top so +lastLineSpace to get to top of first line.
        %Will be drawing line at baseline so +lineCapHeight for y.
        linePositions(n_line,:) = [lineLeft-lineLeftKernings(n_line) textTop+sum(lineHeights(1:n_line-1))+lineCapHeights(n_line)]; %#ok<*SAGROW>
    end
end
%---


end %load__processText