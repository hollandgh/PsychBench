driftVel = this.driftVel;
data = this.data;


%Convert image data to texture.
%In openAtTrial instead of open cause textures Psychtoolbox holds can use
%significant memory, so only hold for each object during its trial instead of
%for all objects at same time at experiment startup.
n_texture  = element_openTexture([], [], data);

if driftVel == 0
    %Static display so we have first image ready here so can predraw to minimize latency at first draw during frames
    this = element_predraw(this, n_texture);
end


this.n_texture = n_texture;