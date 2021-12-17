function [width, leftKerning, capHeight, maxFontSize] = text_measureLine(line, formatChanges, n_scrapTexture, px2fontSize)

%Get metrics of a line using PTB TextBounds, DrawText.
%Tested and okay for measuring if texture too small for text (TextBounds and DrawText keep position outside texture).

%width =            bounding width of line
%left kerning =     left kerning of first character in line
%height =           standard em box height at largest font in line, just = largest font size in line
%                   generally a bit larger than cap height + descender height
%                   but then scaled by line spacing
%                   calculated outside
%cap height =       bounding height of "E" at largest font size in line
%space =            height - cap height
%                   calculated outside
%max font size =    largest font size in line
%(all in px)


        %Left kerning
        [~, r] = Screen('TextBounds', n_scrapTexture, 'a', 0, 0);
        leftKerning = r(1);

        %Measure height, advance pen for each change part
        x = 0;
        capHeight = 0;
        %Apply px2fontSize correction
        maxFontSize = Screen('TextSize', n_scrapTexture)/px2fontSize;
        i_prev = 1;
for a = 1:numel(formatChanges.ii)
        i = formatChanges.ii(a);
    
    %Measure text BEFORE this format change, if any.
    %Could be none if change at start of line (i = 1) or change 2+ of multiple changes at same char.
    if i > i_prev
        %Draw to advance pen for x
        x = Screen('DrawText', n_scrapTexture, line(i_prev:i-1), x);
        
        %Standard "E" cap height.
        %Use method of difefrence between drawing at top and drawing at baseline cause bounding rect of "E" not reliable depending on text renderer (can return whole em box).
        [~, r] = Screen('TextBounds', n_scrapTexture, 'E', 0, 0);
        [~, r_b] = Screen('TextBounds', n_scrapTexture, 'E', 0, 0, 1);
        capHeight = max(capHeight, r(2)-r_b(2));
    end

    %Apply change for next text part
    if strcmp(formatChanges.types{a}, '')
        Screen('TextStyle', n_scrapTexture, 0);
    elseif strcmp(formatChanges.types{a}, 'b')
        Screen('TextStyle', n_scrapTexture, 1);
    elseif strcmp(formatChanges.types{a}, 'i')
        Screen('TextStyle', n_scrapTexture, 2);
    elseif strcmp(formatChanges.types{a}, 'u')
        Screen('TextStyle', n_scrapTexture, 4);
    elseif strcmp(formatChanges.types{a}, 'font')
        try
            Screen(n_scrapTexture, 'TextFont', formatChanges.vals{a});
        catch X
                YMsg = ['Font "' formatChanges.vals{a} '" unknown?' 10 ...
                    '->' 10 ...
                    10 ...
                    X.message];
                error(YMsg)
        end
    elseif strcmp(formatChanges.types{a}, 'fontSize')
        Screen('TextSize', n_scrapTexture, formatChanges.vals{a});
        maxFontSize = max(maxFontSize, formatChanges.vals{a});
    elseif strcmp(formatChanges.types{a}, 'color')
        Screen('TextColor', n_scrapTexture, formatChanges.vals{a});
    end
    
        i_prev = i;
end
        %Get width of whole line after advancing pen across all changes
        [~, r] = Screen('TextBounds', n_scrapTexture, line(i_prev:end), x, 0);
        width = r(3)-leftKerning;
        
        %Measure text after last change, incl whole line if no changes.
        %Remember any dangling changes moved to first char of next line.
        [~, r] = Screen('TextBounds', n_scrapTexture, 'E', 0, 0);
        [~, r_b] = Screen('TextBounds', n_scrapTexture, 'E', 0, 0, 1);
        capHeight = max(capHeight, r(2)-r_b(2));