function s = val2char(x)

% 
% string = VAL2CHAR(val)
% 
% Converts any value to a string (row character array '') representation, e.g.
% for use in <a href="matlab:disp([10 10 10 '------------']), help disp">disp</a> or error messages.


% Giles Holland 2021


if isa(x, 'cell') && all(size(x) == 0)
    %Special case not using MATLAB disp
    s = '{}';

elseif isa(x, 'logical') && numel(x) == 1
    %Special case not using MATLAB disp

    s = char(string(x));
else
    %Base on disp
    s = evalc('x');

    %Trim and left align
    %---
    %At first only remove leading line breaks cause removing ' ' breaks alignment in multi-line values, e.g. matrix.
    %But include whole blank lines.
            s = s(find(s == '=', 1)+1:end);
            i = find(~isspace(s), 1);
            i = find(s(1:i-1) == 10, 1, 'last');
            s(1:i) = [];

    %Trim end completely--can't break alignment
            i = find(~isspace(s), 1, 'last');
            s(i+1:end) = [];

    %Trim line starts to left align, keeping alignment in multi-line values, e.g. matrix
            ll = splitlines(s);
            jj = zeros(1, numel(ll));
    for n = 1:numel(ll)
            l = ll{n};

            jj(n) = min([find(~isspace(l), 1) inf]);
    end
            %Number of spaces to remove from start of each line
            j = min(jj)-1;
    for n = 1:numel(ll)
            l = ll{n};

            l(1:min(j, length(l))) = [];

            ll{n} = l;
    end
            s = joinLines(ll);
    %---

    %Add brackets or quotes if needed, and indent to keep columns aligned.
    %Allow for later MATLAB versions that include a hyperlinked array desc.
    if isa(x, 'numeric') && numel(x) > 1
            s = ['[ ' s ' ]'];
            ii = find(s == 10);
        for i_i = 1:numel(ii)
            i = ii(i_i)+2*(i_i-1);
            s = [s(1:i) '  ' s(i+1:end)];
        end
    elseif isa(x, 'char')
            s = ['''' s ''''];
            ii = find(s == 10);
        for i_i = 1:numel(ii)
            i = ii(i_i)+2*(i_i-1);
            s = [s(1:i) ' ' s(i+1:end)];
        end
    elseif isa(x, 'string') && numel(x) > 1 && isempty(strfind(s, '</a> array')) %#ok<*STREMP>
            s = ['[ ' s ' ]'];
            ii = find(s == 10);
        for i_i = 1:numel(ii)
            i = ii(i_i)+2*(i_i-1);
            s = [s(1:i) '  ' s(i+1:end)];
        end
    elseif isa(x, 'cell') && numel(x) > 0 && isempty(strfind(s, '</a> array'))
            s = ['{ ' s ' }'];
            ii = find(s == 10);
        for i_i = 1:numel(ii)
            i = ii(i_i)+2*(i_i-1);
            s = [s(1:i) '  ' s(i+1:end)];
        end
    end
    
end