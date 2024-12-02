function out = setprod(varargin)

%STUB


sets = varargin;

numSets = numel(sets);

    numels = zeros(1, numel(sets));
for n_set = 1:numSets
    numels(n_set) = numel(sets{n_set});
end

n = prod(numels);
    
[ii{1:numSets}] = ind2sub(numels, 1:n);


if      all(cellfun(@(x) isa(x, 'numeric'),    sets))
    out = zeros(n, numSets);
elseif  all(cellfun(@(x) isa(x, 'string'),    sets))
    out = strings(n, numSets);
else
    out = cell(n, numSets);
    for n_set = find(~cellfun(@(x) isa(x, 'cell'),    sets))
        %Wraps numbers and strings in cells
        sets{n_set} = num2cell(sets{n_set});
    end
end
for n_set = 1:numSets
    out(:,n_set) = sets{n_set}(ii{n_set});
end