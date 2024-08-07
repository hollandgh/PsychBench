function [line, formatChanges, formatChangesForNextLine] = text_getFormatChanges(line, formatChangesFromPrevLine, fontSizeUnit, px2fontSize)

%Extract in-line format changes from line:
%<n>            - new line
%<r>            - regular, i.e. turn off bold/italic/underline
%<b>            - bold 
%<i>            - italic 
%<u>            - underline (only on some systems and text renderers)
%<font = name>  - font name, e.g. <font = Arial>
%<size = n>     - font size (deg), e.g. <size = 0.8>
%<color = RGB>  - RGB = a 1x3 RGB vector with numbers between 0-1, e.g. <color = [1 0 0]>


%Get format changes.
%---
%i = character # after format string = character # where change applies.
%Multiple changes can apply at same character.

formatChanges = struct('ii', {[]}, 'types', {{}}, 'vals', {{}});

formatChanges.ii = [formatChanges.ii strfind(line, '<r>')];
formatChanges.types = [formatChanges.types repmat({'r'}, [1 numel(strfind(line, '<r>'))])];
formatChanges.vals = [formatChanges.vals cell(1, numel(strfind(line, '<r>')))];

        %Deprecated
        formatChanges.ii = [formatChanges.ii strfind(line, '<>')];
        formatChanges.types = [formatChanges.types repmat({'r'}, [1 numel(strfind(line, '<>'))])];
        formatChanges.vals = [formatChanges.vals cell(1, numel(strfind(line, '<>')))];

formatChanges.ii = [formatChanges.ii strfind(line, '<b>')];
formatChanges.types = [formatChanges.types repmat({'b'}, [1 numel(strfind(line, '<b>'))])];
formatChanges.vals = [formatChanges.vals cell(1, numel(strfind(line, '<b>')))];

formatChanges.ii = [formatChanges.ii strfind(line, '<i>')];
formatChanges.types = [formatChanges.types repmat({'i'}, [1 numel(strfind(line, '<i>'))])];
formatChanges.vals = [formatChanges.vals cell(1, numel(strfind(line, '<i>')))];

formatChanges.ii = [formatChanges.ii strfind(line, '<u>')];
formatChanges.types = [formatChanges.types repmat({'u'}, [1 numel(strfind(line, '<u>'))])];
formatChanges.vals = [formatChanges.vals cell(1, numel(strfind(line, '<u>')))];

ii = strfind(line, '<font');
for i = ii
    j = i+find(line(i+1:end) == '>', 1);
    if ~isempty(j)
        k = i+4+find(~isspace(line(i+5:j-1)), 1);
        if ~isempty(k) && line(k) == '='
            formatChanges.ii = [formatChanges.ii i];
            formatChanges.types = [formatChanges.types {'font'}];
            formatChanges.vals = [formatChanges.vals {strip(line(k+1:j-1))}];
        end
    end
end

ii = strfind(line, '<size');
for i = ii
    j = i+find(line(i+1:end) == '>', 1);
    if ~isempty(j)
        k = i+4+find(~isspace(line(i+5:j-1)), 1);
        if ~isempty(k) && line(k) == '='
            fontSize = str2num(line(k+1:j-1));
            if isOneNum(fontSize)
                %Convert from deg to px, apply px2fontSize correction, round to integer
                fontSize = round(px2fontSize*element_deg2px({fontSize fontSizeUnit}));
                if fontSize > 0
                    formatChanges.ii = [formatChanges.ii i];
                    formatChanges.types = [formatChanges.types {'size'}];
                    formatChanges.vals = [formatChanges.vals {fontSize}];
                end
            end
        end
    end
end

ii = strfind(line, '<color');
for i = ii
    j = i+find(line(i+1:end) == '>', 1);
    if ~isempty(j)
        k = i+5+find(~isspace(line(i+6:j-1)), 1);
        if ~isempty(k) && line(k) == '='
            color = str2num(line(k+1:j-1));
            if isRowNum(color) && numel(color) == 3 && all(color >= 0 & color <= 1)
                formatChanges.ii = [formatChanges.ii i];
                formatChanges.types = [formatChanges.types {'color'}];
                formatChanges.vals = [formatChanges.vals {color}];
            end
        end
    end
end

        %Deprecated
        ii = strfind(line, '<col');
        for i = ii
            j = i+find(line(i+1:end) == '>', 1);
            if ~isempty(j)
                k = i+3+find(~isspace(line(i+4:j-1)), 1);
                if ~isempty(k) && line(k) == '='
                    color = str2num(line(k+1:j-1));
                    if isRowNum(color) && numel(color) == 3 && all(color >= 0 & color <= 1)
                        formatChanges.ii = [formatChanges.ii i];
                        formatChanges.types = [formatChanges.types {'color'}];
                        formatChanges.vals = [formatChanges.vals {color}];
                    end
                end
            end
        end

%Sort in order of appearance
[formatChanges.ii, aa] = sort(formatChanges.ii);
formatChanges.types = formatChanges.types(aa);
formatChanges.vals = formatChanges.vals(aa);
%---


%Remove format strings from line
for a = 1:numel(formatChanges.ii)
    i = formatChanges.ii(a);
    j = i+find(line(i+1:end) == '>', 1);
    line(i:j) = [];
    formatChanges.ii(a+1:end) = formatChanges.ii(a+1:end)-(j-i+1);
    
%     if i_prev < i && line(i-1) == ' '
%         %Each part separated by changes will be measured/drawn as a single string.
%         %Compensate for PTB bug (?) that if string ends with spaces then measures/draws one less space.
%         %But don't do this if it's the first character in the line or for multiple changes at a character.
%         line = [line(1:i-1) ' ' line(i:end)];
%         formatChanges.ii(a:end) = formatChanges.ii(a:end)+1;
%     end
%     
%     i_prev = i;
end
    

%     if line(end) == ' '
%         %Compensate for PTB bug (?) that if string ends with spaces then measures/draws one less space
%         line = [line ' '];
%     end


%Prepend dangling format changes from prev line to apply to first char of this line
formatChanges.ii = [formatChangesFromPrevLine.ii formatChanges.ii];
formatChanges.types = [formatChangesFromPrevLine.types formatChanges.types];
formatChanges.vals = [formatChangesFromPrevLine.vals formatChanges.vals];

%Remove dangling format changes to apply to first char of next line (including any prepended if this line empty)
tf = formatChanges.ii > length(line);
formatChangesForNextLine.ii = formatChanges.ii(tf);
formatChangesForNextLine.types = formatChanges.types(tf);
formatChangesForNextLine.vals = formatChanges.vals(tf);
formatChangesForNextLine.ii(:) = 1;
formatChanges.ii(tf) = [];
formatChanges.types(tf) = [];
formatChanges.vals(tf) = [];


if isempty(line)
    %Empty line after removing all format strings -> space for simplicity
    line = ' ';
end