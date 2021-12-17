repeat = this.repeat;
ii_elements = this.ii_elements;
tt = this.tt;
n_element_prev = this.n_element_prev;
startTime = this.startTime;
nextnextFrameTime = trial.nextnextFrameTime;


%Elements cued to change in this frame (n_frame), will change at end of next frame (n_frame+1) = start of next next frame (n_frame+2)
t = nextnextFrameTime-startTime;
if repeat
    %Wrap element numbers if past end of sequence and set to repeat.
    %This is the time check for repeating sequence.
    t = mod(t, tt(end));
elseif t > tt(end)
    %End of sequence and not set to repeat -> END OBJECT ON ITS OWN

    this = element_end(this);
    %Child elements end automatically when this element ends

    return
end

%+1 for first element where time is not past its end time, -1 for dummy zero
n_element = find(tt <= t, 1, 'last')+1-1;
if n_element ~= n_element_prev
    if ii_elements(n_element_prev) > 0
        this = element_sleepElement(this, ii_elements(n_element_prev));
    end
    if ii_elements(n_element) > 0
        this = element_startElement(this, ii_elements(n_element));
    end

    n_element_prev = n_element;
end


this.n_element_prev = n_element_prev;