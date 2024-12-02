%Giles Holland 2022-24


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.size = element_deg2px(this.size);
this.innerRadius = element_deg2px(this.innerRadius);
this.radiusIncrement = element_deg2px(this.radiusIncrement);
this.lineWidth = element_deg2px(this.lineWidth);

%Standardize strings from "x"/'x' to 'x'
this.size = var2char(this.size);
%---


siz = this.size;
innerRadius = this.innerRadius;
radiusIncrement = this.radiusIncrement;
lineWidth = this.lineWidth;
color = this.color;
position = this.position;
n_window = this.n_window;
windowSize = devices.screen.windowSize;
windowCenter = devices.screen.windowCenter;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isOneNum(siz) && siz > 0)
    error(['In' pbObject_XString(this) 'Property .size must be a number > 0.'])
end
if ~(isOneNum(innerRadius) && innerRadius > 0)
    error(['In' pbObject_XString(this) 'Property .innerRadius must be a number > 0.'])
end
if ~(isOneNum(radiusIncrement) && radiusIncrement > 0)
    error(['In' pbObject_XString(this) 'Property .radiusIncrement must be a number > 0.'])
end
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
    
    
if siz == inf
    %Fill window when drawn centered at any position and with any rotation
    siz = (2*max(windowSize)^2)^(1/2)+2*abs(position-windowCenter);
else
    siz = [siz siz];
end


this.size = siz;