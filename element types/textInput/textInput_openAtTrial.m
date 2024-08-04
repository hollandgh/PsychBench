fontName = this.fontName;
fontSize = this.fontSize;
color = this.color;
boxSize = this.boxSize;
boxColor = this.boxColor;


%Make object display on a texture.
%In openAtTrial instead of open cause textures Psychtoolbox holds can use
%significant memory, so only hold for each object during its trial instead of
%for all objects at same time at experiment startup.

%Open texture for drawing text box, sized to fit box, with background = box color.
%Open texture for drawing whole display, sized to fit box, background doesn't matter cause box will fill it.
n_boxTexture = element_openTexture(boxSize, boxColor);
n_texture = element_openTexture(boxSize);

%Set text format for texture using PTB TextFont, TextSize, TextColor
try
    Screen(n_boxTexture, 'TextFont', fontName);
catch X
        YMsg = ['Font "' fontName '" unknown?' 10 ...
            '->' 10 ...
            10 ...
            X.message];
        error(YMsg)
end
Screen('TextSize', n_boxTexture, fontSize);
Screen('TextColor', n_boxTexture, color);

%We have first image ready here (blank box with blinking cursor off) so can
%predraw to minimize latency at first draw during frames
this = element_predraw(this, n_boxTexture);


this.n_boxTexture = n_boxTexture;
this.n_texture = n_texture;