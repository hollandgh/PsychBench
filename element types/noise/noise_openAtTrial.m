siz = this.size;
meanIntensity = this.meanIntensity;
sigma = this.sigma;
numLevels = this.numLevels;
color = this.color;
temporalFrequency = this.temporalFrequency;
repeatInterval = this.repeatInterval;
seed = this.seed;
addDisplay = this.addDisplay;
textureDims = this.textureDims;


if ~isempty(seed)
    %Seed matlab rng to reproduce random pattern
    try
        rng(seed);
    catch X
            error(['Property .seed must be a MATLAB random number generator state as returned by rng(), or [].' 10 ...
                '->' 10 ...
                10 ...
                X.message])
    end
end

if temporalFrequency == 0 || repeatInterval == inf
    %Static noise -> one texture; or No repeat -> first texture to show
    numTextures = 1;
else
    %Dynamic noise saved in textures repeating across time.
    %numTextures = max texture number possible in runFrame.
    numTextures = floor(repeatInterval*temporalFrequency)+1;
end

%Convert image data to textures (first texture only if no repeat).
%In openAtTrial instead of open cause textures Psychtoolbox holds can use
%significant memory, so only hold for each object during its trial instead of
%for all objects at same time at experiment startup.
    nn_textures = zeros(1, numTextures);
    colorTexture = repmat(reshape(color, 1, 1, 3), textureDims);
for i = 1:numTextures
    if addDisplay
            %Noise between -1 ... +1 for pixel-wise addition to whatever is behind it on screen.
            %Gaussian distribution based on sigma only.

            if numLevels == inf
                k = min(max(sigma*randn(textureDims), -1), 1);
            else
                k = min(max(floor((sigma*randn(textureDims))*numLevels)/(numLevels-1), -1), 1);
            end
        image = repmat(k, 1, 1, 3);
    else
        if sigma == inf
            %Rectangular distribution 0-1

            if numLevels == inf
                %Continuous levels (will be up to intensity resolution PTB is running at)

                k = rand(textureDims);
            else
                %Discrete levels.
                %numLevels before min/max so 0/1 are equally likely as other values.

                k = floor(rand(textureDims)*numLevels)/(numLevels-1);
            end
        else
            %Gaussian distribution based on mean, sigma

            if numLevels == inf
                k = min(max(meanIntensity+sigma*randn(textureDims), 0), 1);
            else
                k = min(max(floor((meanIntensity+sigma*randn(textureDims))*numLevels)/(numLevels-1), 0), 1);
            end
        end
        image = repmat(k, 1, 1, 3).*colorTexture;
    end
    nn_textures(i) = element_openTexture([], [], image);
end

%We have first image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, nn_textures(1), [], siz(2));

if ~isempty(seed)
    %Re-shuffle rng for other elements
    rng('shuffle')
end


this.nn_textures = nn_textures;