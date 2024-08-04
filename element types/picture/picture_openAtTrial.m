rotations = this.rotations;
numImages = this.numImages;
images = this.images;
rects_texture = this.rects_texture;
siz = this.size;
centerOffset = this.centerOffset;


%Make texture(s) to show.
%In openAtTrial instead of open cause textures Psychtoolbox holds can use
%significant memory, so only hold for each object during its trial instead of
%for all objects at same time at experiment startup.

if numImages > 1 || rotations(1) ~= 0
    %Multiple images or rotated image -> draw to one texture
    
    %Open one texture to show
    n_texture = element_openTexture(siz);

    %Convert each image data to a texture
        nn_imageTextures = zeros(1, numImages);
    for n_image = 1:numImages
        nn_imageTextures(n_image) = element_openTexture([], [], images{n_image});
    end

    %Draw image textures to texture to show.
    %Draw with first above last to match convention for property .depth (+ = behind).
    %Apply rotations if any.
    Screen('DrawTextures', n_texture, flip(nn_imageTextures), [], flip(rects_texture, 2), flip(rotations))

    %Close image textures
    Screen('Close', nn_imageTextures)
else
    %One image, not rotated -> convert directly to texture.
    %Center offset maybe still applied at draw.
    
    n_texture = element_openTexture([], [], images{1});
end

%We have first image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, n_texture, [], siz(2), centerOffset);


this.n_texture = n_texture;