%Draw display to window to show in next frame.
%Use element_redraw for efficiency if same image as previous, else element_draw.
%Display starts showing at object frame 1 start (screen refresh) after this script runs in object frame 0.
%Don't draw in last object frame cause then there is no next frame.
%element_draw/redraw automatically applies all core display functionality.
%Apply height for single image (just = texture height for multiple), center offset for multiple images (just = [0 0] for single).
%Crop already done in open.

if ~this.isEnding
    siz = this.size;
    centerOffset = this.centerOffset;
    n_texture = this.n_texture;


    this = element_redraw(this, n_texture, [], siz(2), centerOffset);
end