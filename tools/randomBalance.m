function [x, ii_in, ii_out] = randomBalance(x, varargin)

%STUB
%Replicates, randomizes order, counterbalances. Must be 2D. Automatically
%detects dimension for vector, else within rows.
%TODO docs
%TODO Contents.m and other see alsos
%TODO work for uneven numbers of values
%TODO more error checking
%TODO commenting


%2-CHECK HANDLING FRACTIONAL OKAY OR COULD BE BETTER?
%CHECK STILL NEEDS TO SORT X?

%     try either minimizing for just this randval OR minimizing collateral damage--when you close rows that WERE open. i.e. minimize nnRowsJUSTCLOSED, not all closed
%         basically trying to get at avoiding those double-value rows
%         minimize loss within each other ref vals


%     %TEST
%     testSize = [80 3];
    

    if nargin < 2
        error('Not enough inputs.')
    end


if numel(varargin{end}) == 1
    dim = varargin{end};
    refs = varargin(1:end-1);
else
    dim = [];
    refs = varargin;
end
numRefs = numel(refs);


    x = var2char(x, '-c');
        if ~((isa(x, 'numeric') || iscellstr(x)) && ismatrix(x))
            error('Inputs must be 2D arrays of numbers or strings.')
        end
for n_ref = 1:numRefs
    ref = refs{n_ref};
    
    ref = var2char(ref, '-c');
        if ~((isa(ref, 'numeric') || iscellstr(ref)) && ismatrix(ref))
            error('Inputs must be 2D arrays of numbers or strings.')
        end
        
    refs{n_ref} = ref;
end
        if ~(isOneNum(dim) && ismember(dim, [1 2]) || isempty(dim))
            error('Dimension must be 1 or 2.')
        end


if isempty(dim)
    if isvector(x)
                dim = find(size(x) > 1, 1);
    else
            n_ref = 0;
        while isempty(dim)
            n_ref = n_ref+1;
            if isvector(refs{n_ref})
                dim = find(size(refs{n_ref}) > 1, 1);
            end
        end
    end
    
    if isempty(dim)
        dim = 1;
    end
end
if dim == 2
        x = transpose(x);
    for n_ref = 1:numRefs
        refs{n_ref} = transpose(refs{n_ref});
    end
%     dim = 1;
    transposed = true;
else
    transposed = false;
end


s_x = size(x, 1);
s_r = size(refs{1}, 1);
    for n_ref = 2:numRefs
        if size(refs{n_ref}, 1) ~= s_r
            if size(refs{n_ref}, 2) == s_r
                error('Array to balance and arrays to balance with respect to must have the same orientation (dimension to balance within).')
            else
                error('Arrays to balance with respect to must have equal lengths in the dimension to balance within.')
            end
        end
    end
    if isvector(x) && size(x, 2) == s_r
                error('Array to balance and arrays to balance with respect to must have the same orientation (dimension to balance within).')
    end
    if ~(s_x <= s_r)
                error('Length of array to balance must be <= lengths of arrays to balance with respect to in the dimension to balance within.')
    end
if s_x < s_r
    %Auto replicate input as close as possible.
    %Randomize shortfall if doesn't divide in equally.
    x = repmat(x, ceil(s_r/s_x), 1);
    x(end-s_x+1:end,:) = randomOrder(x(end-s_x+1:end,:), 1);
    x(end-(s_r-size(x, 1))+1:end,:) = [];
end
numRows = size(x, 1);


x_in = x;
    if isa(x, 'numeric')
        %Converts to cell array of strings.
        %num2str still works on char.
        %cellstr would modify by dropping leading/trailing spaces.
        x = num2cell(char(x));
    end
        %Joins to 1 col
        x = join(x, 2);
for n_ref = 1:numRefs
    if isa(refs{n_ref}, 'numeric')
        refs{n_ref} = num2cell(char(refs{n_ref}));
    end
        refs{n_ref} = join(refs{n_ref}, 2);
end

    
%Allow for uneven numbers of unique values and dividing unevenly, handling randomly.
%If divides evenly for some values but unevenly for others, gets the evenly ones perfect.


%Need to sort so distribute all of each unique value at a time so searching ref vals works below
[x, ii_sort] = sort(x);


    randVals = struniqueish(x);
    numRandVals = numel(randVals);
        numsRandVals = zeros(1, numRandVals);
        nn_randVals = zeros(numRows, 1);
    for n_randVal = 1:numRandVals
        ii = find(strcmp(x, randVals{n_randVal}));
        numsRandVals(n_randVal) = numel(ii);
        nn_randVals(ii) = n_randVal;
    end
%     
%     %TEST
%     numRandVals
%     numsRandVals
%     nn_randVals
    
        
    numRefValss = zeros(1, numRefs);
    numsRefValss = cell(1, numRefs);
    nn_refValss = zeros(numRows, numRefs);
for n_ref = 1:numRefs
    ref = refs{n_ref};
    
    %Def can't sort ref cols cause would lose correspondence between them if more than one
    refVals = struniqueish(ref);
    numRefVals = numel(refVals);
        numsRefVals = zeros(1, numRefVals);
        nn_refVals = zeros(numRows, 1);
    for n_refVal = 1:numRefVals
        ii = find(strcmp(ref, refVals{n_refVal}));
        numsRefVals(n_refVal) = numel(ii);
        nn_refVals(ii) = n_refVal;
    end
    
    numRefValss(n_ref) = numRefVals;
    numsRefValss{n_ref} = numsRefVals;
    nn_refValss(:,n_ref) = nn_refVals;
%     
%     %TEST
%     numRefVals
%     numsRefVals
%     nn_refVals
end

    %This will be the order we relax search criteria for reference values in.
    %(Most relaxed = most picky = largest number of referfence values, which we won't even search for.)
    [~, nn_searchRefs] = sort(numRefValss, 'descend');
    nn_searchRefs = nn_searchRefs(2:end);
% 
%     %TEST
%     nn_searchRefs
    
    
%             randCounts = numsRandVals;
%             %TEST
%             randCounts
%             
            refCounts = cell(1, numRefs);
            nn_searchRefVals = cell(1, numRefs);
            refrandCounts = cell(1, numRefs);
            refrandMaxs = cell(1, numRefs);
for n_ref = 1:numRefs
            refCounts{n_ref} = zeros(numRefValss(n_ref), 1);
            nn_searchRefVals{n_ref} = 1:numRefValss(n_ref);
            
            refrandCounts{n_ref} = zeros(numRefValss(n_ref), numRandVals);
    for n_refVal = 1:numRefValss(n_ref)
        for n_randVal = 1:numRandVals
            refrandMaxs{n_ref}(n_refVal,n_randVal) = numsRandVals(n_randVal)*(numsRefValss{n_ref}(n_refVal)/numRows);
        end
    end
%     
%     %TEST
%     refCounts{n_ref}
%     nn_searchRefVals{n_ref}
%     refrandCounts{n_ref}
%     refrandMaxs{n_ref}
end


    ii_rand = tryme(numRows, numRandVals, numRefs, nn_randVals, nn_refValss, refrandCounts, refrandMaxs);
while isempty(ii_rand)
    disp('.')
    ii_rand = tryme(numRows, numRandVals, numRefs, nn_randVals, nn_refValss, refrandCounts, refrandMaxs);
end

    ii_in = ii_sort(ii_rand);
    ii_out = sort(ii_in);


    x = x_in(ii_in,:);
if transposed
    x = transpose(x);
end


end




function ii_rand = tryme(numRows, numRandVals, numRefs, nn_randVals, nn_refValss, refrandCounts, refrandMaxs)


%     %TEST
%     x_test = zeros(testSize);
    
    ii_rand = zeros(1, numRows);
            rowsOpen = true(numRows, numRandVals);
% %TEST
% try
for n_row1 = 1:numRows
    n_randVal = nn_randVals(n_row1);
%     randCounts(n_randVal) = randCounts(n_randVal)-1
    
    
            tff = rowsOpen(:,n_randVal);
            if ~any(rowsOpen(:,n_randVal))
                ii_rand = [];
                return
            end
%                 if ~any(rowsOpen(:,n_randVal))
%                     error('Failed to balance because of conflicting requirements of the multiple arrays to balance with respect to. Check that it is logically possible to balance these values and/or please try again.')
%                 end
%     for n_searchRef = nn_searchRefs
%             i = 1;
%             tff_try = tff & nn_refValss(:,n_searchRef) == nn_searchRefVals{n_searchRef}(i);
%         while ~any(tff_try)
%             i = i+1;
%             tff_try = tff & nn_refValss(:,n_searchRef) == nn_searchRefVals{n_searchRef}(i);
%             %nn_searchRefVals has all ref vals for this ref in it so will find one since checked at least one row open above, just order of preference
%         end
%             tff = tff_try;
%         
%         %TEST
%         nn_searchRefVals{n_searchRef}(i)
%     end
    nn_rows2 = randomOrder(find(tff));
        numRowsOpen_try = zeros(size(nn_rows2));
    for i_row2 = 1:numel(nn_rows2)
        n_row2 = nn_rows2(i_row2);
        
        refrandCounts_try = refrandCounts;
        rowsOpen_try = rowsOpen;
        
        nn_refVals = nn_refValss(n_row2,:);
        for n_ref = 1:numRefs
            n_refVal = nn_refVals(n_ref);

            refrandCounts_try{n_ref}(n_refVal,n_randVal) = refrandCounts_try{n_ref}(n_refVal,n_randVal)+1;
            if refrandCounts_try{n_ref}(n_refVal,n_randVal) >= refrandMaxs{n_ref}(n_refVal,n_randVal)
                %Close all other rows with this refVal for this randVal
                tff_rowsClose = nn_refValss(:,n_ref) == n_refVal;
                rowsOpen_try(tff_rowsClose,n_randVal) = false;
            end
% 
%             %Search in order of fewest assigned
%             refCounts{n_ref}(n_refVal) = refCounts{n_ref}(n_refVal)+1;
%             [~, nn_searchRefVals{n_ref}] = sort(refCounts{n_ref});
        end
                %Close this row for all randVals
                rowsOpen_try(n_row2,:) = false;
        
        numRowsOpen_try(i_row2) = numel(find(rowsOpen_try));
    end
    [~, i_row2] = max(numRowsOpen_try);
% 
% TEST - DISABLE MAX OPEN
% i_row2 = 1;
    
    
        n_row2 = nn_rows2(i_row2);
        nn_refVals = nn_refValss(n_row2,:);
        for n_ref = 1:numRefs
            n_refVal = nn_refVals(n_ref);

            refrandCounts{n_ref}(n_refVal,n_randVal) = refrandCounts{n_ref}(n_refVal,n_randVal)+1;
            if refrandCounts{n_ref}(n_refVal,n_randVal) >= refrandMaxs{n_ref}(n_refVal,n_randVal)
                %Close all other rows with this refVal for this randVal
                tff_rowsClose = nn_refValss(:,n_ref) == n_refVal;
                rowsOpen(tff_rowsClose,n_randVal) = false;
            end
% 
%             %Search in order of fewest assigned
%             refCounts{n_ref}(n_refVal) = refCounts{n_ref}(n_refVal)+1;
%             [~, nn_searchRefVals{n_ref}] = sort(refCounts{n_ref});
        end
                %Close this row for all randVals
                rowsOpen(n_row2,:) = false;
        

    ii_rand(n_row2) = n_row1; %#ok<*AGROW>
    
%     %TEST
%     x_test(n_row2) = inf
%     x_test(n_row2) = x_in(ii_sort(n_row1));
end
% %TEST
% catch X
%     n_row1
%     rowsOpen
%     ii_rand
%     rethrow(X)
% end


end