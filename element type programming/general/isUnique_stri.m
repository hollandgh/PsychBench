function tf = isUnique_stri(x)

% 
% ans = ISUNIQUE_STRI(x)
% 
% Returns a logical array same size as x containing true where the string is
% unique in x by <a href="matlab:disp([10 10 10 '------------']), help strcmpi">strcmpi</a> (case-insensitive). x must be char (works at the
% string level, so just returns true), cell array of char, or string.
% 
% 
% See also isUnique_str, isUnique.


% Giles Holland 2021


    if nargin < 1
        error('Not enough inputs.')
    end
    if ~(isa(x, 'char') || iscellstr(x) || isa(x, 'string') || isempty(x))
        error('Input must be char, cell array of char, or string. For numeric use ISUNIQUE.')
    end
    

if isa(x, 'char')
    tf = true;
elseif isempty(x)
    %Treat '' above as a string but [] as empty cell array of strings.
    %Need to check this cause strcmp treats [] as a scalar value.
    tf = false(size(x));
else
    tf = false(size(x));
    %Use lower instead of strcmpi cause sort doesn't group lower/upper together
    x_sorted = lower(x);
    [x_sorted, ii] = sort(x_sorted(:));
    blarg = [true; ~strcmp(x_sorted(1:end-1), x_sorted(2:end))];
    tf(ii) = blarg & blarg([2:end 1]);
end