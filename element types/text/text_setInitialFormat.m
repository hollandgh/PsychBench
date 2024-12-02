function text_setInitialFormat(n_texture, fontName, fontSize, style, color, boxColor)

%Set initial text format for texture using PTB TextFont, TextSize, TextStyle, TextColor, TextBackgroundColor.


try
    Screen(n_texture, 'TextFont', fontName);
catch X
        YMsg = ['Font "' fontName '" unknown?' 10 ...
            '->' 10 ...
            10 ...
            X.message];
        error(YMsg)
end

Screen('TextSize', n_texture, fontSize);

if      strcmpi(style, "r")
    Screen('TextStyle', n_texture, 0);
elseif  strcmpi(style, "b")
    Screen('TextStyle', n_texture, 1);
elseif  strcmpi(style, "i")
    Screen('TextStyle', n_texture, 2);
elseif  strcmpi(style, "u")
    Screen('TextStyle', n_texture, 4);
end

Screen('TextColor', n_texture, color);

% Screen('TextBackgroundColor', n_texture, boxColor);