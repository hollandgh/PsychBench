function y = joinList(x)

% 
% y = JOINLIST(x)
% 
% Joins an array of strings (["x" "x" ...] or {'x' 'x' ...}) into one string
% with ', ' separating them. Output data type matches input.
% 
% e.g. JOINLIST({'hello', 'goodbye'}) -> 
%     'hello, goodbye'


% Giles Holland 2023


y = var2char(x, '-c');
    if ~iscellstr(y)
        error('Input must be a string array.')
    end

    
y = join(y, ', '); %#ok<*CHARTEN>

if isa(x, 'string')
    y = string(y);
elseif ~isempty(y)
    y = y{1};
else
    y = '';
end