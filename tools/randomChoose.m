function out = randomChoose(vals, numSamples, dim, varargin)

% 
% out = RANDOMCHOOSE(vals, [numSamples], [dim], [flag], [flag], ...)
%     [input] = for default you can input [], or omit if you don't use any inputs after it.
% 
% Returns random samples from a discrete set (array) of any data type, without
% replacement. Number of samples can be > size of set--if so, RANDOMCHOOSE 
% samples from a set replicated the minimum number of times needed. e.g. for 14
% samples from a set of 10, it samples from the set replicated to 20.
%
% In the simplest case, samples numbers from a vector. You can also sample
% across a specified dimension of an array of any size, e.g. columns from a
% matrix.
%
% To sample with replacement, use <a href="matlab:disp([10 10 10 '------------']), help randomRoll">randomRoll</a> instead. 
% 
% By default RANDOMCHOOSE shuffles MATLAB's random number generator before
% sampling. You can use flag -ns to not do this.
% 
% 
% INPUTS
% ----------
% 
% vals
%     Array to sample from.
% 
% [numSamples]
%     Number of samples to return.
% 
%     DEFAULT: 1
% 
% [dim]
%     If values to sample from is a row or column vector, RANDOMCHOOSE samples
%     scalar values. If it is 2+ -dimensional, RANDOMCHOOSE samples across a
%     dimension which you can specify here. e.g. if values is a matrix and
%     dimension = 2, RANDOMCHOOSE returns column vectors.
% 
%     DEFAULT: 1 (sample across rows)
% 
% [flag], [flag], ...
%     You can input any number of the following strings (" or '):
% 
%     "-c"
%         By default if RANDOMCHOOSE samples one cell from a cell array, it
%         returns the value out of the cell, e.g. 2. If you input flag -c, it
%         returns the cell containing the value, e.g. {2}.
%
%     "-ns"
%         Don't shuffle MATLAB's random number generator.
% 
% 
% See also randomRoll, randomNum, randomNum_normal, randomBalancePerms,
% randomOrder, perms, nchoosek.


% Giles Holland 2022


if nargin < 2 || isempty(numSamples)
    numSamples = 1;
end
if nargin < 3 || isempty(dim)
    dim = [];
end
flags = varargin;


    if nargin < 1
        error('Not enough inputs.')
    end
    if isempty(vals)
        error('Array to sample from cannot be empty.')
    end
    if ~(isOneNum(numSamples) && isIntegerVal(numSamples) && numSamples >= 0)
        error('Number of samples must be an integer >= 0.')
    end
    if ~(isOneNum(dim) && isIntegerVal(dim) && dim >= 1 || isempty(dim))
        error('Dimension must be an integer >= 1.')
    end
    
flags = var2char(flags);


if isempty(dim)
    if isrow(vals)
        dim = 2;
    else
        dim = 1;
    end
end


if ~any(strcmpi(flags, '-ns'))
    %Seed random number generator
    rng('shuffle')
end

%Without replacement
n = ceil(numSamples/size(vals, dim));
ii = repmat(1:size(vals, dim), 1, n);
ii = ii(randperm(numel(ii), numSamples));

s.type = '()';
s.subs = repmat({':'}, 1, ndims(vals));
s.subs{dim} = ii;
out = subsref(vals, s);

if isa(out, 'cell') && numel(out) == 1 && ~any(strcmpi(flags, '-c'))
    out = out{1};
end