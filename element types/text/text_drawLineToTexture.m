function text_drawLineToTexture(line, formatChanges, n_texture, position)

%Like measureLine cept draws for real.


        x = position(1);
        i_prev = 1;
for a = 1:numel(formatChanges.ii)
        i = formatChanges.ii(a);

    if i > i_prev
        %Draw at baseline so that characters on a line align vertically if font size changes
        x = Screen('DrawText', n_texture, line(i_prev:i-1), x, position(2), [], [], 1);
    end

    if strcmp(formatChanges.types{a}, 'r')
        Screen('TextStyle', n_texture, 0);
    elseif strcmp(formatChanges.types{a}, 'b')
        Screen('TextStyle', n_texture, 1);
    elseif strcmp(formatChanges.types{a}, 'i')
        Screen('TextStyle', n_texture, 2);
    elseif strcmp(formatChanges.types{a}, 'u')
        Screen('TextStyle', n_texture, 4);
    elseif strcmp(formatChanges.types{a}, 'font')
            %Don't need to catch font not found error cause already used in measureLine
        Screen(n_texture, 'TextFont', formatChanges.vals{a});
    elseif strcmp(formatChanges.types{a}, 'size')
        Screen('TextSize', n_texture, formatChanges.vals{a});
    elseif strcmp(formatChanges.types{a}, 'color')
        Screen('TextColor', n_texture, formatChanges.vals{a});
    end
    
        i_prev = i;
end
        Screen('DrawText', n_texture, line(i_prev:end), x, position(2), [], [], 1);