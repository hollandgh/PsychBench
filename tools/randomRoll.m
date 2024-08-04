function out = randomRoll(vals, numSamples, dim, varargin)

% 
% out = RANDOMROLL(vals, [numSamples], [dim], [flag], [flag], ...)
%     [input] = for default you can input [], or omit if you don't use any inputs after it.
% 
% Returns random samples from a discrete set (array) of any data type, with
% replacement. In the simplest case samples numbers from a vector. You can also
% sample across a specified dimension of an array of any size, e.g. columns from
% a matrix.
%
% To sample without replacement, possible with repetition, use <a href="matlab:disp([10 10 10 '------------']), help randomChoose">randomChoose</a> 
% instead. 
% 
% Note for the special case of random integers you can also use <a href="matlab:disp([10 10 10 '------------']), help randomNum">randomNum</a> with 
% flag "-i".
% 
% By default RANDOMROLL shuffles MATLAB's random number generator before
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
%     If values to sample from is a row or column vector, RANDOMROLL samples
%     scalar values. If it is 2+ -dimensional, RANDOMROLL samples across a
%     dimension which you can specify here. e.g. if values is a matrix and
%     dimension = 2, RANDOMROLL returns column vectors.
% 
%     DEFAULT: 1 (sample across rows)
% 
% [flag], [flag], ...
%     You can input any number of the following strings (" or '):
% 
%     "-c"
%         By default if RANDOMROLL samples one cell from a cell array, it
%         returns the value out of the cell, e.g. 2. If you input flag -c, it
%         returns the cell containing the value, e.g. {2}.
%
%     "-ns"
%         Don't shuffle MATLAB's random number generator.
% 
% 
% See also randomChoose, randomNum, randomNum_normal, randomBalancePerms,
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

%With replacement
ii = randi(size(vals, dim), 1, numSamples);

s.type = '()';
s.subs = repmat({':'}, 1, ndims(vals));
s.subs{dim} = ii;
out = subsref(vals, s);

if isa(out, 'cell') && numel(out) == 1 && ~any(strcmpi(flags, '-c'))
    out = out{1};
end