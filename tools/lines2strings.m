function lines2strings(fileInName, fileOutName, quotes)

%STUB
%TODO doc
%TODO Contents.m
%TODO error checking
%TODO visual file chooser option
%TODO default save location same as read location
%TODO check ''x' works in spreadsheets


if nargin < 3 || isempty(quotes)
    quotes = 2;
end


quotes = var2char(quotes);
    if ~(isOneNum(quotes) && ismember(quotes, [1 2]) || isa(quotes, 'char') && any(strcmpi(quotes, {'1' '2' '1s' '2s' 's'})))
        error('Input 3 must be a number or string "1", "2", "1s", "2s", or "s".')
    end
quotes = num2str(quotes);


if      strcmpi(quotes, '1')
    qq = {'''' ''''};
elseif  strcmpi(quotes, '2')
    qq = {'"' '"'};
elseif  strcmpi(quotes, '1s')
    qq = {'''''' ''''};
elseif  any(strcmpi(quotes, {'2s' 's'}))
    qq = {'''"' '"'};
end


ss = readlines(fileInName);
ss = qq{1}+ss+qq{2};
ss = joinLines(ss);

n_file = fopen(fileOutName, 'wt');
fwrite(n_file, ss);
fclose(n_file);