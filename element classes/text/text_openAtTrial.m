fontName = this.fontName;
fontSize = this.fontSize;
style = this.style;
color = this.color;
boxColor = this.boxColor;
lines = this.lines;
formatChanges = this.formatChanges;
linePositions = this.linePositions;
siz = this.size;
n_window = this.n_window;


%Make object display on a texture.
%In openAtTrial instead of open cause textures Psychtoolbox holds can use
%significant memory, so only hold for each object during its trial instead of
%for all objects at same time at experiment startup.

%Open texture sized to fit display with background = box color using PTB OpenOffscreenWindow.
%Even if no box still use box color as background cause currently no text background transparency.
n_texture = Screen('OpenOffscreenWindow', n_window, boxColor, [0 0 siz]);

%Draw text centered on texture
if ~isempty(lines)
    text_setInitialFormat(n_texture, fontName, fontSize, style, color)

    %Draw text
    for n_line = 1:numel(lines)
        text_drawLineToTexture(lines{n_line}, formatChanges(n_line), n_texture, linePositions(n_line,:));
    end
end


this.n_texture = n_texture;