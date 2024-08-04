function [out, ii_in, ii_out] = randomOrder(in, dim, varargin)

% 
% [out, ii_in, ii_out] = RANDOMORDER(in, [dim], [flag])
%     [input] = for default you can input [], or omit if you don't use any inputs after it.
% 
% Randomizes the order in a row/column array of any data type. Can also
% randomize across a specified dimension of an array of any size.
% 
% By default RANDOMORDER shuffles MATLAB's random number generator before
% working. You can use flag -ns to not do this.
% 
% 
% INPUTS
% ----------
% 
% in
%     Array to randomize.
% 
% [dim]
%     Dimension (1, 2, ...) to randomize across. e.g. if input is a matrix and
%     dimension = 2 then randomizes order of columns.
% 
%     DEFAULT: If input is row/column then randomize across its length, else
%     randomize across rows (1).
% 
% [flag]
%     If you input the string "-ns" (" or ') then RANDOMORDER doesn't shuffle
%     MATLAB's random number generator.
% 
% 
% OUTPUTS
% ----------
% 
% out
%     Randomized array.
% 
% ii_in
%     A row vector containing indexes such that out = in(ii_in). Or for non-row/column 
%     arrays indexes in the dimension set above, e.g. out = in(ii_in,:).
% 
% ii_out
%     Same except in = out(ii_out). i.e. ii_out are the indexes that undo the
%     randomization.
% 
% 
% See also randomNum, randomNum_normal, randomRoll, randomChoose,
% randomBalancePerms, perms, nchoosek, rep.


% Giles Holland 2021


if nargin < 2 || isempty(dim)
    dim = [];
end
flags = varargin;


    if nargin < 1
        error('Not enough inputs.')
    end
    if ~(isOneNum(dim) && isIntegerVal(dim) && dim >= 1 || isempty(dim))
        error('Dimension must be an integer >= 1.')
    end
    
flags = var2char(flags);
    

if isempty(dim)
    if isrow(in)
        dim = 2;
    else
        dim = 1;
    end
end

if ~any(strcmpi(flags, '-ns'))
    %Seed random number generator
    rng('shuffle')
end

    ii_in = randperm(size(in, dim));
if nargout > 2
    [~, ii_out] = sort(ii_in);
end

s.type = '()';
s.subs = repmat({':'}, 1, ndims(in));
s.subs{dim} = ii_in;
out = subsref(in, s);