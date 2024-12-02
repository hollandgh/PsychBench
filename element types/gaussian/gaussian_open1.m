%Giles Holland 2023, 24


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.sigma = element_deg2px(this.sigma);
this.size = element_deg2px(this.size);
%---


sigma = this.sigma;
siz = this.size;
color = this.color;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if numel(sigma) == 1
    sigma = [sigma sigma];
end
if ~(isRowNum(sigma) && numel(sigma) == 2 && all(sigma > 0))
    error('Property .sigma must be a number or 1x2 vector of numbers > 0.')
end
this.sigma = sigma;

if numel(siz) == 1
    %Square
    siz = [siz siz];
end
if ~(isRowNum(siz) && numel(siz) == 2 && all(siz > 0) || isempty(siz))
    error('Property .size must be a number or 1x2 vector of numbers > 0, or [].')
end
this.size = siz;

if ~isRgb1(color)
    error('Property .color must be a 1x3 vector with numbers between 0-1.')
end
%---