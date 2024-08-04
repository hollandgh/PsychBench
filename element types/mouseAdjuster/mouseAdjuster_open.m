%Giles Holland 2022


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.deltaRate = element_deg2px(this.deltaRate, -1);
this.clickAreaSize = element_deg2px(this.clickAreaSize);

%Standardize strings from "x"/'x' to 'x'
this.cursorShape = var2char(this.cursorShape);
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
ii_elementsAdjusting = this.ii_elementsAdjusting;
position = this.position;
windowSize = devices.screen.windowSize;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~is01(drag_x)
    error('Property .drag_x must be true/false.')
end
if ~is01(drag_y)
    error('Property .drag_y must be true/false.')
end
if ~is01(drag_xy)
    error('Property .drag_xy must be true/false.')
end
ii = find([drag_x drag_y drag_xy]);
if numel(ii) == 0
    error('One of .drag_x, .drag_y, .drag_xy must = true.')
end
if numel(ii) > 1
    error('Only one of .drag_x, .drag_y, .drag_xy must = true.')
end

if ~is01(move)
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

    
    if isOneNum(clickAreaSize) && clickAreaSize ~= inf
        %Square
        clickAreaSize = [clickAreaSize clickAreaSize];
    end
    if ~(isRowNum(clickAreaSize) && numel(clickAreaSize) == 2 && all(clickAreaSize > 0 & clickAreaSize < inf) || isOneNum(clickAreaSize) && clickAreaSize == inf)
        error('Property .clickAreaSize must be a number or 1x2 vector of numbers > 0, or the number inf.')
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


        rect = [];
        moveUnit = [];
if move
        if numel(ii_elementsAdjusting) ~= 1
            error('If property .move = true, you can only adjust one target (.adjust.what).')
        end
    elementAdjusting = element_getElement(ii_elementsAdjusting);
        if ~ismember('screen', elementAdjusting.with)
            error('If property .move = true, target must be a visual element.')
        end
    
    if isa(elementAdjusting.user.position, 'numeric')
        moveUnit = 'deg';
    else
        moveUnit = elementAdjusting.user.position{2};
    end
else
    if numel(clickAreaSize) == 1 && clickAreaSize == inf
        %Click anywhere on screen
        rect = [0 0 windowSize];
    else
        %Rect of area can start click & drag centered at object position on screen, relative to window top left.
        %PsychBench translated position to relative to window top left for type scripts.
        rect = [0 0 clickAreaSize]-repmat((clickAreaSize+1)/2, 1, 2)+[position position];
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
this.moveUnit = moveUnit;

%Initialize some record properties for first iteration of runFrame
this.tf_buttonsDown_prev = [];
this.dragCursorPosition_prev = [];
this.pollTime_prev = [];