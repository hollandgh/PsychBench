function lines = text_getLines(text, wrapWidth)

%Breaks input text into cell array of strings that are lines, removes all line break strings


%Standardize existing line breaks to ASCII char notation 10
%---
if isa(text, 'cell')
    %Text already in cell array of strings -> merge cells into one string using 10
    x = '';
    for i = 1:numel(text)-1
        x = [x text{i} 10]; %#ok<*AGROW>
    end
    x = [x text{end}];
    text = x;
end

%<n> -> 10 in text
text = strrep(text, '<n>', char(10)); %#ok<*CHARTEN>
%---


%Wrap lines.
%Insert line breaks between wrapWidth number of characters between existing line breaks.
%---
ii_spaces = find(isspace(text) & ~text ~= char(10));
ii_lineBreaks = find(text == char(10));
i_1 = 1;
i_max = wrapWidth;
while i_max < length(text)
    i = min(ii_lineBreaks(ii_lineBreaks >= i_1 & ii_lineBreaks <= i_max+1));
    if ~isempty(i)
        %Pre-existing line break in line -> leave it, go to next line after it
        i_1 = i+1;        
    else
        %Find last space
        i = max(ii_spaces(ii_spaces >= i_1 & ii_spaces <= i_max+1 & ii_spaces < length(text)));

        if ~isempty(i)
            %Replace with line break
            text = [text(1:i-1) 10 text(i+1:end)];
        else
            %No space in line -> take max length
            i = i_max+1;

            %Insert line break
            text = [text(1:i-1) 10 text(i:end)];            
            ii_spaces = ii_spaces+1;
            ii_lineBreaks = ii_lineBreaks+1;
        end

        %Skip over new line break
        i_1 = i+1;
    end

    i_max = i_1-1+wrapWidth;
end
%---


%Break text string into lines in cells
text = [text 10];
lines = {};
ii_lineBreaks = find(text == char(10));
    i_prev = 0;
for i = ii_lineBreaks
    lines = [lines {text(i_prev+1:i-1)}];
        
    i_prev = i;    
end


%Empty lines -> space later cause need to extract format strings first