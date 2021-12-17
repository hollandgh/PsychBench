%PREPROCESS INPUT PROPERTIES FOR DATA TYPE, UNITS
%---
%Convert deg units to px
this.size = element_deg2px(this.size);
this.borderWidth = element_deg2px(this.borderWidth);
%---


siz = this.size;
showFill = this.showFill;
color = this.color;
showBorder = this.showBorder;
borderWidth = this.borderWidth;
borderColor = this.borderColor;
windowSize = resources.screen.windowSize;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if numel(siz) == 1
    siz = [siz siz];
end
if ~(isRowNum(siz) && numel(siz) == 2 && all(siz > 0))
    error('Property .size must be a number or 1x2 vector of numbers > 0.')
end
this.size = siz;

if ~isTrueOrFalse(showFill)
    error('Property .showFill must be true/false.')
end
if ~isTrueOrFalse(showBorder)
    error('Property .showBorder must be true/false.')
end
if ~(showFill || showBorder)
    error('One of properties .showFill and .showBorder must = true.')
end

if showFill
    if ~(isRowNum(color) && numel(color) == 3 && all(color >= 0 & color <= 1))
        error('Property .color must be a 1x3 vector with numbers between 0-1.')
    end
end
if showBorder
    if ~WITHPTB
        error('Property .showBorder = true needs the Psychtoolbox framework.')
    end
    if ~(isOneNum(borderWidth) && borderWidth > 0)
        error('Property .borderWidth must be a number > 0.')
    end
    if ~(isRowNum(borderColor) && numel(borderColor) == 3 && all(borderColor >= 0 & borderColor <= 1))
        error('Property .borderColor must be a 1x3 vector with numbers between 0-1.')
    end
end
%---


%inf = full window
if any(siz == inf)
    siz = windowSize;
end


this.size = siz;