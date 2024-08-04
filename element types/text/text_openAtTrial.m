fontName = this.fontName;
fontSize = this.fontSize;
style = this.style;
color = this.color;
boxColor = this.boxColor;
lines = this.lines;
formatChanges = this.formatChanges;
linePositions = this.linePositions;
siz = this.size;


%Make object display on a texture.
%In openAtTrial instead of open cause textures Psychtoolbox holds can use
%significant memory, so only hold for each object during its trial instead of
%for all objects at same time at experiment startup.

%Open texture for drawing, sized to fit display.
%Background color = box color if box set, else boxColor = [] -> object background color (users can set in .backColor, default = transparent).
n_texture = element_openTexture(siz, boxColor);

%Draw text centered on texture
if ~isempty(lines)
    text_setInitialFormat(n_texture, fontName, fontSize, style, color, boxColor)

    %Draw text
    for n_line = 1:numel(lines)
        text_drawLineToTexture(lines{n_line}, formatChanges(n_line), n_texture, linePositions(n_line,:));
    end
end

%We have first image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, n_texture);


this.n_texture = n_texture;