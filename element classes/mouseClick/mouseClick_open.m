%PREPROCESS INPUT PROPERTIES FOR DATA TYPE, UNITS
%---
%Standardize strings from "x"/'x' to 'x'.
this.cursorShape = var2Char(this.cursorShape);

%Convert deg units to px
this.rects = element_deg2px(this.rects);
%---


rects = this.rects;
cursorShape = this.cursorShape;
position = this.position;
windowSize = resources.screen.windowSize;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isa(rects, 'numeric') && ismatrix(rects) && size(rects, 2) == 4 || isempty(rects))
    error('Property .rects must be a 4-column matrix or [].')
end
if ~isempty(rects)
    if ~allish(rects(:,[1 2]) < rects(:,[3 4]))
        error('In each row in property .rects (1) must be < (3) and (2) < (4).')
    end
end

if ~(isRowChar(cursorShape) || (isOneNum(cursorShape) && isIntegerVal(cursorShape) && cursorShape >= 0) || isempty(cursorShape))
    error([XMsgPre 'Property .cursorShape must be a string, number, or [].'])
end
%---


if ~isempty(rects)
    %User sets click areas relative to object position (default position is screen center).
    %PsychBench translated object position to relative to screen top left for class scripts.
    %Translate click areas to relative to screen top left.
    rects = rects+repmat(position, size(rects, 1), 2);
    %inf = screen edge
    rects(rects(:,1) == -inf,1) = 0;
    rects(rects(:,2) == -inf,2) = 0;
    rects(rects(:,3) == inf,3) = windowSize(1);
    rects(rects(:,4) == inf,4) = windowSize(2);
end


this.rects = rects;

%Initialize some record properties for runFrame
this.tf_buttonsDown_prev = [];
this.pollTime_prev = [];