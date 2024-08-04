function warningOnce(wId, w, varargin)

% 
% ans = warningOnce(warningId, warning, [a, b, ...])
%     [input] = omit or input [] for default.
% 
% Like MATLAB <a href="matlab:disp([10 10 10 '------------']), help warning">warning</a> except if WARNINGONCE is called more than once for the 
% same warning, it only displays it the first time. To reset this, call
% warningOnce('clear', warningId) or warning('on', warningId). Note warning ID
% is required for warningOnce, unlike warning() where it is optional.
% 
% 
% See also warning.


% Giles Holland 2024


if strcmpi(wId, 'clear')
    wId = w;
    warning('on', wId)
else
    warning(wId, w, varargin{:})
    warning('off', wId)
end