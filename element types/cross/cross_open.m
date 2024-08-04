%Giles Holland 2022


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.size = element_deg2px(this.size);
this.lineWidth = element_deg2px(this.lineWidth);
%---


siz = this.size;
lineWidth = this.lineWidth;
color = this.color;
n_window = this.n_window;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---    
if ~(isOneNum(siz) && siz >= 0)
    error('Property .size must be a number >= 0.')
end
siz = [siz siz];
this.size = siz;

if ~(isOneNum(lineWidth) && lineWidth > 0)
    error('Property .lineWidth must be a number > 0.')
end
if ~isRgb1(color)
    error('Property .color must be a 1x3 vector with numbers between 0-1.')
end
%---


    [minLineWidth, maxLineWidth] = Screen('DrawLines', n_window);
    if ~(lineWidth >= minLineWidth && lineWidth <= maxLineWidth)
        error(['In property .lineWidth: ' num2str(lineWidth) ' px is out of range. On your system lines must be between ' num2str(minLineWidth) '-' num2str(maxLineWidth) ' px.'])
    end