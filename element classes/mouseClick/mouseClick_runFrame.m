rects = this.rects;
cursorShape = this.cursorShape;
tf_buttonsDown_prev = this.tf_buttonsDown_prev;
pollTime_prev = this.pollTime_prev;
n_window = this.n_window;
isStarting = this.isStarting;


%Get mouse cursor position and button #s down using PTB GetMouse
[x, y, tf_buttonsDown] = GetMouse(n_window);
%Get mouse poll time using PTB GetSecs
pollTime = GetSecs;


if isStarting
    %Show mouse cursor when object starting
    this = element_showMouseCursor(this, cursorShape);
    
    
else
    %Look for mouse button PRESS: if buttons are down and different from prev frame.
    %Omit check in object frame 0 cause don't have buttons down or poll time from prev
    %frame. Also if a buttons is already down from before object starts we don't
    %want to register it. So first frame object can register a button press is 
    %object frame 1.

    tf_buttonsClicked = tf_buttonsDown & ~tf_buttonsDown_prev;
    if any(tf_buttonsClicked)
        if isempty(rects)
            %Mouse button mode -> response = button #.
            %Get only first button clicked in case more than one.
            response = find(tf_buttonsClicked, 1);
        else
            %Screen area mode -> response = rect #.
            %Check if click was in a rect.
            %Get only first rect in case overlapping and click in more than one.
            response = find(x > rects(:,1) & x <= rects(:,3) & y > rects(:,2) & y <= rects(:,4), 1);
        end
        if ~isempty(response)
            %Register response
            [this, maxNumResponsesRegistered] = element_registerResponse(this, response, pollTime_prev, pollTime);
            if maxNumResponsesRegistered
                this = element_end(this);
            end
        end
    end
end


this.tf_buttonsDown_prev = tf_buttonsDown;        
this.pollTime_prev = pollTime;


%PsychBench automatically hides cursor if no other objects using it when object ends