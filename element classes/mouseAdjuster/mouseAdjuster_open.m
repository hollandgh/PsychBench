%PREPROCESS INPUT PROPERTIES FOR DATA TYPE, UNITS
%---
%Standardize strings from "x"/'x' to 'x'.
this.cursorShape = var2Char(this.cursorShape);

%Convert deg units to px
this.deltaRate = element_deg2px(this.deltaRate, -1);
this.clickAreaSize = element_deg2px(this.clickAreaSize);
%---


drag_x = this.drag_x;
drag_y = this.drag_y;
drag_xy = this.drag_xy;
deltaRate = this.deltaRate;
deltaIncrement = this.deltaIncrement;
clickAreaSize = this.clickAreaSize;
move = this.move;
n_dragButton = this.n_dragButton;
cursorShape = this.cursorShape;
position = this.position;
windowSize = resources.screen.windowSize;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~isTrueOrFalse(drag_x)
    error('Property .drag_x must be true/false.')
end
if ~isTrueOrFalse(drag_y)
    error('Property .drag_y must be true/false.')
end
if ~isTrueOrFalse(drag_xy)
    error('Property .drag_xy must be true/false.')
end
if numel(find([drag_x drag_y drag_xy])) ~= 1
    error('One and only one of .drag_x, .drag_y, or .drag_xy must be true.')
end

if ~isTrueOrFalse(move)
    error('Property .move must be true/false.')
end
if ~move
    if drag_xy
        if ~(isRowNum(deltaRate) && any(numel(deltaRate) == [1 2]))
            error('Property .deltaRate must be a number or 1x2 vector.')
        end
        if ~(isRowNum(deltaIncrement) && any(numel(deltaIncrement) == [1 2]) && all(deltaIncrement >= 0))
            error('Property .deltaIncrement must be a number or 1x2 vector of numbers >= 0.')
        end
    else
        if ~isOneNum(deltaRate)
            error('Property .deltaRate must be a number.')
        end
        if ~(isOneNum(deltaIncrement) && deltaIncrement >= 0)
            error('Property .deltaIncrement must be a number >= 0.')
        end
    end

    if numel(clickAreaSize) == 1
        clickAreaSize = [clickAreaSize clickAreaSize];
    end
    if ~(isRowNum(clickAreaSize) && numel(clickAreaSize) == 2 && all(clickAreaSize > 0))
        error('Property .clickAreaSize must be a number or 1x2 vector of numbers > 0.')
    end
    this.clickAreaSize = clickAreaSize;
end

if ~(isRowNum(n_dragButton) && all(isIntegerVal(n_dragButton) & n_dragButton > 0) && ~isempty(n_dragButton))
    error('Property .n_dragButton must be an integer or row vector of integers > 0.')
end
if ~(isRowChar(cursorShape) || (isOneNum(cursorShape) && isIntegerVal(cursorShape) && cursorShape >= 0) || isempty(cursorShape))
    error([XMsgPre 'Property .cursorShape must be a string, number, or [].'])
end
%---


if move
    rect = [];
else
    %Rect of area can start click & drag centered at object position on screen, relative to screen top left.
    %PsychBench translated position to relative to screen top left for class scripts.
    rect = [0 0 clickAreaSize]-repmat((clickAreaSize+1)/2, 1, 2)+[position position];
    
    %inf = fit dimension to screen
    if clickAreaSize(1) == inf
        rect([1 3]) = [0 windowSize(1)];
    end
    if clickAreaSize(2) == inf
        rect([2 4]) = [0 windowSize(2)];
    end
end


%Initialize deltaBuffer based on adjustment size
if drag_xy || move
    deltaBuffer = [0 0];
else
    deltaBuffer = 0;
end


this.rect = rect;
this.deltaBuffer = deltaBuffer;

%Initialize some record properties for runFrame
this.tf_buttonsDown_prev = [];
this.dragCursorPosition_prev = [];
this.pollTime_prev = [];