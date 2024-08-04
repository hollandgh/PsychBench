function y = joinLines(x)

% 
% y = JOINLINES(x)
% 
% Joins an array of strings (["x" "x" ...] or {'x' 'x' ...}) into one string
% with char(10) (new line) separating them. Output data type matches input.
% 
% e.g. JOINLINES({'hello', 'goodbye'}) -> 
%     'hello
%      goodbye'


% Giles Holland 2022


y = var2char(x, '-c');
    if ~iscellstr(y)
        error('Input must be a string array.')
    end

    
y = join(y, char(10)); %#ok<*CHARTEN>

if isa(x, 'string')
    y = string(y);
elseif ~isempty(y)
    y = y{1};
else
    y = '';
end