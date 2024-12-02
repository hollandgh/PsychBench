%Giles Holland 2022


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.areaPositions = element_deg2px(this.areaPositions);
this.areaSize = element_deg2px(this.areaSize);

%Standardize strings from "x"/'x' to 'x'
this.cursorShape = var2char(this.cursorShape);
%---


areaPositions = this.areaPositions;
areaSize = this.areaSize;
cursorShape = this.cursorShape;
position = this.position;
windowSize = devices.screen.windowSize;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isa(areaPositions, 'numeric') && ismatrix(areaPositions) && size(areaPositions, 2) == 2 || isempty(areaPositions))
    error('Property .areaPositions must be an nx2 matrix or [].')
end
numAreas = size(areaPositions, 1);

if numAreas > 0
    if size(areaSize, 1) == 1
        %Same size across areas
        areaSize = repmat(areaSize, numAreas, 1);
    end
    if size(areaSize, 2) == 1
        %Square areas
        areaSize = repmat(areaSize, 1, 2);
    end
    if ~(isa(areaSize, 'numeric') && ismatrix(areaSize) && size(areaSize, 1) == numAreas && size(areaSize, 2) == 2 && all2(areaSize > 0))
        error('Property .areaSize must be a number or 1x2 vector of numbers > 0. It can also have multiple rows matching number of areas in .areaPositions.')
    end
    this.areaSize = areaSize;
end


if ~(isRowChar(cursorShape) || (isOneNum(cursorShape) && isIntegerVal(cursorShape) && cursorShape >= 0) || isempty(cursorShape))
    error([XMsgPre 'Property .cursorShape must be a string, number, or [].'])
end
%---


if numAreas == 0
    areaRects = [];
else
    %Area positions relative to window top left.
    %Area positions were set relative to object position.
    %PsychBench translated object position to relative to window top left for type scripts.
    areaPositions = areaPositions+repmat(position, numAreas, 1);
    
    %Get rects from sizes + positions.
    areaRects = [areaPositions-areaSize/2 areaPositions+areaSize/2];
end


this.areaRects = areaRects;

%Initialize some record properties for first iteration of runFrame
this.tf_buttonsDown_prev = [];
this.pollTime_prev = [];