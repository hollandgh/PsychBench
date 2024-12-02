maxNumLoops = this.maxNumLoops;
ii_elements = this.ii_elements;
times = this.times;
n_element_prev = this.n_element_prev;
startTime = this.startTime;
nextnextFrameTime = trial.nextnextFrameTime;


%Elements cued to change in this frame (n_frame), will change at end of next frame (n_frame+1) = start of next next frame (n_frame+2).
%Wrap element numbers if past end of sequence and set to loop.
t = nextnextFrameTime-startTime;
if t > maxNumLoops*times(end)
    %Past maximmum number of loops -> END OBJECT ON ITS OWN

    this = element_end(this);
    %Child elements end automatically when this element ends

    return
end
t = mod(t, times(end));

%Last child object that is at or past its start time
n_element = find(t >= times(1:end-1), 1, 'last');
if n_element ~= n_element_prev
    if ~isnan(ii_elements(n_element_prev))
        %Cue to sleep current child object
        this = element_sleepElement(this, ii_elements(n_element_prev));
    end
    if ~isnan(ii_elements(n_element))
        %Cue to start next child object
        this = element_startElement(this, ii_elements(n_element));
    end

    n_element_prev = n_element;
end


this.n_element_prev = n_element_prev;