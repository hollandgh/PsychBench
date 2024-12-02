drag_x = this.drag_x;
drag_y = this.drag_y;
drag_xy = this.drag_xy;
deltaRate = this.deltaRate;
deltaIncrement = this.deltaIncrement;
move = this.move;
n_dragButton = this.n_dragButton;
cursorShape = this.cursorShape;
rect = this.rect;
deltaBuffer = this.deltaBuffer;
moveUnit = this.moveUnit;
tf_buttonsDown_prev = this.tf_buttonsDown_prev;
dragCursorPosition_prev = this.dragCursorPosition_prev;
pollTime_prev = this.pollTime_prev;
ii_elementsAdjusting = this.ii_elementsAdjusting;
n_window = this.n_window;
isStarting = this.isStarting;


%Get mouse cursor position and button #s down using PTB GetMouse
[x, y, tf_buttonsDown] = GetMouse(n_window);
cursorPosition = [x y];
%Get mouse poll time using PTB GetSecs
pollTime = GetSecs;


                            %Empty drag cursor position -> ends drag if button released
                            dragCursorPosition = [];
                        
                            
if isStarting
    %OBJECT FRAME 0
    %Object starting at next frame start (frame 1 start)
    %===
    
    %Show mouse cursor when object starts.
    %PsychBench automatically hides mouse cursor if no other objects using it when object ends.
    this = element_showMouseCursor(this, cursorShape);
    
    
else
    %OBJECT RUNNING
    %===
    
    if any(tf_buttonsDown)
        %Look for mouse button PRESS: if buttons are down and different from prev frame.
        %Omit check in object frame 0 cause don't have buttons down or poll time from prev
        %frame. Also if a buttons is already down from before object starts we don't
        %want to register it. So first frame object can register a button press is 
        %object frame 1.        
        %Get only first button down/clicked in case more than one.
        
        n_buttonDown = find(tf_buttonsDown, 1);
        n_buttonClicked = find(tf_buttonsDown & ~tf_buttonsDown_prev, 1);
        if ~isempty(n_buttonClicked)
            if any(n_buttonClicked == n_dragButton)
                %Clicked a drag button
                
                if move
                    %Special move target element -> rect is its display rect
                    elementAdjusting = element_getElement(ii_elementsAdjusting);
                    rect = elementAdjusting.displayRect;
                %else rect set by user in input property
                end
                if ~isempty(rect)
                    if cursorPosition(1) > rect(1) && cursorPosition(1) <= rect(3) && cursorPosition(2) > rect(2) && cursorPosition(2) <= rect(4)
                        %Clicked a drag button inside rect -> drag started

                        %Initialize drag cursor position -> next frame will use to get first frame of this drag
                        if drag_x
                            dragCursorPosition = cursorPosition(1);
                        elseif drag_y
                            dragCursorPosition = cursorPosition(2);
                        else
                            dragCursorPosition = cursorPosition;
                        end
                    end
                end
            else
                %Clicked a non-drag button -> register response (done adjusting).
                %Also ends object at end of this frame if maximum number responses registered.
                
                this = element_registerResponse(this, [], pollTime_prev, pollTime);
            end
        elseif any(n_buttonDown == n_dragButton) && ~isempty(dragCursorPosition_prev)
            %Button down and dragging

            %Get current drag cursor position
            if drag_x
                dragCursorPosition = cursorPosition(1);
            elseif drag_y
                dragCursorPosition = cursorPosition(2);
            else
                dragCursorPosition = cursorPosition;
            end

            if any(dragCursorPosition ~= dragCursorPosition_prev)
                %Dragged since last frame

                if move
                            %Adjustment = px dragged since last frame
                            d = dragCursorPosition-dragCursorPosition_prev;
                            %Convert to distance units target position is in since adjustment must be in terms user sets in (e.g. deg), not type code terms (px)
                            d = element_px2deg({d moveUnit});

                            %-clip flag says if adjustment would take target property past min/max set in
                            %this.adjust, property will adjust up to min/max instead of being ignored. Used
                            %here because otherwise drags that are too fast (too many px in one frame)
                            %cannot move the target element if it is near min/max.
                            this = element_adjustElements(this, d, '-clip');
                else
                            %Adjustment = adjustment rate*px dragged since last frame
                            d = deltaRate.*(dragCursorPosition-dragCursorPosition_prev);
                            %Up = - in screen coords--switch to + for adjustment
                        if drag_y
                            d = -d;
                        elseif drag_xy
                            d(2) = -d(2);
                        end
                    if deltaIncrement == 0
                            this = element_adjustElements(this, d, '-clip');
                    else
                            %Buffer adjustment to send in increments deltaIncrement.
                            %Note don't just round to nearest deltaIncrement cause then some drag could be lost or gained each frame.
                            deltaBuffer = deltaBuffer+d;
                            d = floor(deltaBuffer./deltaIncrement).*deltaIncrement;
                        if any(d ~= 0)
                            deltaBuffer = deltaBuffer-d;
                            this = element_adjustElements(this, d, '-clip');
                        end
                    end
                end
            end
        end
    end
end


this.tf_buttonsDown_prev = tf_buttonsDown;
this.dragCursorPosition_prev = dragCursorPosition;
this.pollTime_prev = pollTime;
this.deltaBuffer = deltaBuffer;