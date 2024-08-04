frequency = this.frequency;
orientation = this.orientation;
driftVel = this.driftVel;
n_texture = this.n_texture;
isEnding = this.isEnding;
startTime = this.startTime;
nextFrameTime = trial.nextFrameTime;


%Draw display to window to show in next frame.
%Display starts showing at object frame 1 start (screen refresh) after this script runs in object frame 0.
%Don't draw in last object frame cause then there is no next frame.
%element_draw/redraw automatically applies all core display functionality.
if ~isEnding
    if driftVel == 0
        %Static display so use element_redraw instead of element_draw for efficiency
        this = element_redraw(this, n_texture);
        
    else
        %Dynamic display so use element_draw instead of element_redraw.
        %Apply drift velocity, periodic by 1 spatial period so when occluded by mask, appears to drift smoothly.
        t = nextFrameTime-startTime;
        drift = rem(driftVel*t, 1/frequency)*[cosd(orientation) sind(orientation)];
        this = element_draw(this, n_texture, [], [], drift);
        
    end
end