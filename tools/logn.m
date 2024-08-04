function ans = logn(x, n)

% 
% ans = LOGN(x, n)
% 
% Logarithm of x with base n.
% 
% 
% See also log, log2, log10.


try

    
ans = log(x)/log(n);


catch X
    if nargin < 2
        error('Not enough inputs.')
    end

    if ~isa(x, 'numeric')
        error('First input must be numeric.')
    end
    if ~isOneNum(n)
        error('Base must be a number.')
    end

    rethrow(X)
end