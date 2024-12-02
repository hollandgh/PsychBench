n_texture = this.n_texture;
centerOffset = this.centerOffset;


%Draw display to window to show in next frame, with center offset from position calculated in open.
%Static display so use element_redraw instead of element_draw for efficiency.
%Display starts showing at object frame 1 start (screen refresh) after this script runs in object frame 0.
%Don't draw in last object frame cause then there is no next frame.
%element_redraw automatically applies all core display functionality.
if ~this.isEnding
    this = element_redraw(this, n_texture, [], [], centerOffset);
end