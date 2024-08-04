function out = randomNum_normal(m, sd, numSamples, varargin)

% 
% out = RANDOMNUM_NORMAL(mean, standardDev, [numSamples], [flag], [flag], ...)
%     [input] = for default you can input [], or omit if you don't use any inputs after it.
% 
% Returns a random number from a normal (Gaussian) distribution with specified
% mean and standard deviation. Can generalize to returning random samples from a
% uniform distribution of any dimensions. You can constrain to integers (sampled
% with replacement) if you input a flag "-i".
% 
% By default RANDOMNUM_NORMAL shuffles MATLAB's random number generator before
% sampling. You can use flag -ns to not do this.
% 
% 
% INPUTS
% ----------
% 
% mean
% standardDev
%     Mean and standard deviation. Or to sample from a multidimensional
%     distribution, mean/standardDev can be any size (each the same size).
% 
% [numSamples]
%     Number of numbers/samples to generate:
% 
%     min/max = scalar:         
%         RANDOMNUM_NORMAL outputs a 1 x numSamples vector.
% 
%     min/max = vector:         
%         RANDOMNUM_NORMAL outputs a matrix with size numSamples in the
%         singleton dimension.
% 
%     min/max = 2+ dimensional: 
%         RANDOMNUM_NORMAL outputs an array with size numSamples in the first
%         singleton dimension.
% 
%     DEFAULT: 1
% 
% [flag], [flag], ...
%     You can input any number of the following strings (" or '):
% 
%     "-i"
%         Return integers only.
%
%     "-ns"
%         Don't shuffle MATLAB's random number generator.
% 
% 
% See also randomNum, randomRoll, randomChoose, randomBalancePerms,
% randomOrder, perms, nchoosek.


% Giles Holland 2021


if nargin < 3 || isempty(numSamples)
    numSamples = 1;
end
flags = varargin;


    if nargin < 2
        error('Not enough inputs.')
    end
    
    if ~isa(m, 'numeric')
        error('Mean must be numeric.')
    end
    if ~(isa(sd, 'numeric') && all2(sd >= 0))
        error('Standard deviation must be numeric with all numbers >= 0.')
    end
    if ~isequaln(size(m), size(sd))
        error('Sets of mean and standard deviation values must be the same size.')
    end
    
    if ~(isOneNum(numSamples) && isIntegerVal(numSamples) && numSamples >= 0)
        error('Number of samples must be an integer >= 0.')
    end
    
flags = var2char(flags);

    
if ~any(strcmpi(flags, '-ns'))
    %Seed random number generator
    rng('shuffle')
end

if ismatrix(m)
    if      size(m, 2) == 1
        siz = [size(m, 1) numSamples];
    elseif  size(m, 1) == 1
        siz = [numSamples size(m, 2)];
    else
        siz = [size(m) numSamples];
    end
else
        siz = [size(m) numSamples];
end

    out = randn(siz).*sd+m;
if any(strcmpi(flags, '-i'))
    %Round to integers
    out = round(out);
end