fontName = this.fontName;
fontSize = this.fontSize;
style = this.style;
color = this.color;
boxColor = this.boxColor;
lines = this.lines;
formatChanges = this.formatChanges;
linePositions = this.linePositions;
siz = this.size;


%Make object display on a texture

%Request object background color = box color (maybe transparent)
this = element_setBackColor(this, boxColor);

%Open texture for drawing, sized to fit display, background = object background color
n_texture = element_openTexture(siz);

%Draw text centered on texture
if ~isempty(lines)
    text_setInitialFormat(n_texture, fontName, fontSize, style, color, boxColor)

    %Draw text
    for n_line = 1:numel(lines)
        text_drawLineToTexture(lines{n_line}, formatChanges(n_line), n_texture, linePositions(n_line,:));
    end
end

%Static display with image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, n_texture);


this.n_texture = n_texture;