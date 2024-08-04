function out = randomNum(a, b, numSamples, varargin)

% 
% out = RANDOMNUM(min, max, [numSamples], [flag], [flag], ...)
%     [input] = for default you can input [], or omit if you don't use any inputs after it.
% 
% Returns one or more random numbers from a uniform distribution between
% specified minimum and maximum values. Can generalize to returning random
% samples from a uniform distribution of any dimensions. You can constrain to
% integers (sampled with replacement) if you input a flag "-i".
% 
% By default RANDOMNUM shuffles MATLAB's random number generator before
% sampling. You can use flag -ns to not do this.
% 
% 
% INPUTS
% ----------
% 
% min
% max
%     Minimum and maximum numbers to sample between. Or to sample from a
%     multidimensional distribution, min/max can be any size (each the same
%     size).
% 
%     If you are not generating integers, min ... max is an open interval such
%     that min and max will never occur. If you are generating integers (flag
%     "-i" below), min ... max is a closed interval such that min and max occur
%     with the same probability as all other integers in the interval.
% 
% [numSamples]
%     Number of numbers/samples to generate:
% 
%     min/max = scalar:         
%         RANDOMNUM outputs a 1 x numSamples vector.
% 
%     min/max = vector:         
%         RANDOMNUM outputs a matrix with size numSamples in the singleton
%         dimension.
% 
%     min/max = 2+ dimensional: 
%         RANDOMNUM outputs an array with size numSamples in the first singleton
%         dimension.
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
% See also randomNum_normal, randomRoll, randomChoose, randomBalancePerms,
% randomOrder, perms, nchoosek.


% Giles Holland 2021


if nargin < 3 || isempty(numSamples)
    numSamples = 1;
end
flags = varargin;


    if nargin < 2
        error('Not enough inputs.')
    end
    
    if ~isa(a, 'numeric')
        error('Minimum must be numeric.')
    end
    if ~isa(b, 'numeric')
        error('Maximum must be numeric.')
    end
    if ~isequaln(size(a), size(b))
        error('Sets of minimum and maximum values must be the same size.')
    end
    if ~all(a <= b)
        error('Minimum must be <= maximum.')
    end
    
    if ~(isOneNum(numSamples) && isIntegerVal(numSamples) && numSamples >= 0)
        error('Number of samples must be an integer >= 0.')
    end
    
flags = var2char(flags);


if ~any(strcmpi(flags, '-ns'))
    %Seed random number generator
    rng('shuffle')
end

if ismatrix(a)
    if      size(a, 2) == 1
        siz = [size(a, 1) numSamples];
    elseif  size(a, 1) == 1
        siz = [numSamples size(a, 2)];
    else
        siz = [size(a) numSamples];
    end
else
        siz = [size(a) numSamples];
end

if any(strcmpi(flags, '-i'))
    %Integers -> fix range so least/greatest integers within it have equal probability to all others
    a  = ceil(a)-0.5;
    b = floor(b)+0.5;
    out = rand(siz).*(b-a)+a;
    %Round to integers.
    %Assume rand never returns 1 so will never get <max int>+0.5 and round to <max int>+1.
    out = round(out);
else
    out = rand(siz).*(b-a)+a;
end