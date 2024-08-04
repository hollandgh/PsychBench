function out = isemptycell(x)

% 
% ans = ISEMPTYCELL(x)
% 
% Returns a logical array the same size as cell array x containing true where
% a cell is empty (contains empty).


% Giles Holland 2024


if isempty(x)
    %Special case else tf will be double for empty cell array
    out = true(size(x));
else
    out = cellfun(@(y) isempty(y),    x);
end