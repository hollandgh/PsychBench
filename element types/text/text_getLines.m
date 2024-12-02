function [lines, formatChanges_lines] = text_getLines(text, formatChanges, wrapWidth)

%Breaks text into cell array of strings that are lines, applies wrapping,
%removes all line break strings


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
            %Replace with line break.
            %Doesn't change number of characters, ii's.
            text = [text(1:i-1) 10 text(i+1:end)];
        else
            %No space in line -> take max length
            i = i_max+1;

            %Insert line break
            text = [text(1:i-1) 10 text(i:end)];
            
            ii_spaces = ii_spaces+1;
            ii_lineBreaks = ii_lineBreaks+1;
            
            tff = formatChanges.ii >= i;
            formatChanges.ii(tff) = formatChanges.ii(tff)+1;
        end

        %Skip over new line break
        i_1 = i+1;
    end

    i_max = i_1-1+wrapWidth;
end
%---


%Break text string into lines in cells, also format changes
%---
text = [text 10];
ii_lineBreaks = find(text == char(10));

lines = cell(size(ii_lineBreaks));
formatChanges_lines = structish({'ii' 'types' 'vals'}, size(ii_lineBreaks));
    i_prev = 0;
for n_line = 1:numel(ii_lineBreaks)
    i = ii_lineBreaks(n_line);
    
        line = text(i_prev+1:i-1);
    if isempty(line)
        %Empty line -> ' ' and will move any formatting changes on next line break to it below
        line = ' ';
    else
        %Move any formatting changes on next line break to next char
        tff = formatChanges.ii == i;
        formatChanges.ii(tff) = formatChanges.ii(tff)+1;
    end
    lines{n_line} = line;
    
    tff = formatChanges.ii >= i_prev+1 & formatChanges.ii <= i;
    formatChanges_lines(n_line).ii = formatChanges.ii(tff);
    formatChanges_lines(n_line).types = formatChanges.types(tff);
    formatChanges_lines(n_line).vals = formatChanges.vals(tff);
    formatChanges_lines(n_line).ii = formatChanges_lines(n_line).ii-i_prev;
                
    i_prev = i;
end
%---