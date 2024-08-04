function out = rep(in, varargin)

% 
% out = REP(in, numReps...)
% 
% Replicates (tiles) an array of any data type. The simplest use is to replicate
% a scalar into a row vector, or replicate a vector across its length. However,
% you can also replicate by any amounts across any dimensions.
% 
% 
% INPUTS
% ----------
% 
% in
%     Array to replicate.
% 
% numReps...
%     Amount to replicate by. Two different usages:
% 
%     numReps = a number n:
%         in is scalar:         Replicates in x n into a row vector.
%         in is vector:         Replicates in x n across its length (row or column).
%         in is 2+ dimensional: Replicates in x n across dimension 1 (rows).
% 
%     numReps = a row vector [n m ...] or multiple inputs n, m, ...
%         Replicates in x n across dim 1, x m across dim 2, ...
% 
% 
% See also randomOrder, randomBalancePerms.


% Giles Holland 2021, 22


numReps = varargin;


    if nargin < 2
        error('Not enough inputs.')
    end
    
    if  ~( ...
        numel(numReps) == 1 && isRowNum(numReps{1}) || ...
        all(cellfun(@(x) isOneNum(x),    numReps)) ...
        )
    
        error('Number of repetitions must be one input that is a row array of integers >= 0, or multiple inputs that are integers >= 0.')
    end
numReps = [numReps{:}];
    if ~all(isIntegerVal(numReps) & numReps >= 0)
        error('Number of repetitions must be one input that is a row array of integers >= 0, or multiple inputs that are integers >= 0.')
    end


if numel(numReps) == 1
    if numel(in) == 1
        numReps = [1 numReps];
    else
        x = ones(1, ndims(in));
        x(find(size(in) > 1, 1)) = numReps;
        numReps = x;
    end
end    
out = repmat(in, numReps);