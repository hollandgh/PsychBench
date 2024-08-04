data = this.data;


%Convert image data to textures.
%In openAtTrial instead of open cause textures Psychtoolbox holds can use
%significant memory, so only hold for each object during its trial instead of
%for all objects at same time at experiment startup.
for i = 1:numel(data)
    nn_textures(i) = element_openTexture([], [], data{i}); %#ok<*SAGROW>
end

%We have first image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, nn_textures(1));


this.nn_textures = nn_textures;