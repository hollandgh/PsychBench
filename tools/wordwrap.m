function msg = wordwrap(msg, wrapLength, indentLength, varargin)

% 
% msg = WORDWRAP(msg, [wrapLength], [indentLength], [flag], [flag], ...)
%     [input] = for default you can input [], or omit if you don't use any inputs after it.
% 
% Adds line breaks (char(10)) to a string to word-wrap it to a specified width
% in number of characters, for example to wrap a message for readable display in
% the MATLAB command window. Preserves any existing line breaks in the string.
% Any word with length > wrap length will appear alone on a line and unbroken.
% 
% 
% INPUTS
% ----------
% 
% msg
%     String (" or ') to wrap.
% 
% [wrapLength]
%     Number of characters to wrap to. inf = don't wrap to width but possibly
%     still apply "indentLength" below based on existing line breaks in the
%     string.
% 
%     DEFAULT: 80
% 
% [indentLength]
%     You can add an indent to each wrapped line by specifying an indent length
%     in number of characters. By default indents are applied before wrapping,
%     i.e. indent length is included in line length when determining wrapping.
% 
%     DEFAULT: 0 (don't indent)
% 
% [flag], [flag], ...
%     You can input any number of the following strings (" or '):
% 
%     "-h"
%         If you specify an indent, adds a hanging indent only, i.e. only to
%         wrapped lines 2+.
% 
%     "-wi"
%         Apply indents after wrapping, i.e. indent length is not included in
%         line length when determining wrapping.


% Giles Holland 2021


if nargin < 2 || isempty(wrapLength)
    wrapLength = 80;
end
if nargin < 3 || isempty(indentLength)
    indentLength = 0;
end
flags = varargin;


    if nargin < 1
        error('Not enough inputs.')
    end

outputString = isa(msg, 'string');
msg = var2char(msg);
    if ~isRowChar(msg)
        error('Message to wrap must be a string.')
    end
    
    if ~(isOneNum(wrapLength) && isIntegerVal(wrapLength) && wrapLength > 0)
        error('Wrap length must be an integer > 0.')
    end
    if ~(isOneNum(indentLength) && isIntegerVal(indentLength) && indentLength >= 0)
        error('Indent length must be an integer > 0.')
    end
    if ~(wrapLength > indentLength)
        error('Wrap length must be > indent length.')
    end
    
flags = var2char(flags);
    

    ii_spaces = find(msg == 32);
    ii_lineBreaks = find(msg == 10);
    ii_x = ii_spaces(ismember(ii_spaces, ii_lineBreaks-1));
while ~isempty(ii_x)
    %Remove insignificant spaces at line ends
    msg(ii_x) = [];

    ii_spaces = find(msg == 32);
    ii_lineBreaks = find(msg == 10);
    ii_x = ii_spaces(ismember(ii_spaces, ii_lineBreaks-1));
end


        i_1 = 1;
    
if ~any(strcmpi(flags, '-h'))
        %Add indent to first line
        msg = [repmat(' ', 1, indentLength) msg];
        ii_spaces = ii_spaces+indentLength;
        ii_lineBreaks = ii_lineBreaks+indentLength;
%else hanging indent only
end
    if any(strcmpi(flags, '-wi'))
        i_1 = i_1+indentLength;
    end
    
while true
        i_max = i_1-1+wrapLength;
        
    j = min(ii_lineBreaks(ii_lineBreaks >= i_1 & ii_lineBreaks <= i_max+1));
    if ~isempty(j)
        %Line break in line -> take it
        i = j;
    elseif i_max < length(msg)
        %No line break in line -> find last space in line.
        %If msg ends with space don't take that one--would add a line break to end of msg.
        i = max(ii_spaces(ii_spaces >= i_1 & ii_spaces <= i_max+1 & ii_spaces < length(msg)));
        
        if ~isempty(i)
            %Replace with line break
            msg = [msg(1:i-1) 10 msg(i+1:end)];
        else
            %No space in line -> find line break OR space after line
            j = min(ii_lineBreaks(ii_lineBreaks > i_max+1));
            i = min(ii_spaces(ii_spaces > i_max+1 & ii_spaces < length(msg)));
            if ~isempty(j) && (isempty(i) || j < i)
                %Pre-existing line break in line -> leave it, go to next line after it
                i = j;
            elseif ~isempty(i)
                %Replace with line break
                msg = [msg(1:i-1) 10 msg(i+1:end)];
            else
                %End of msg
                break
            end
        end
    else
        %End of msg
        break
    end

        %Next line after line break
        i_1 = i+1;

        %Add indent
        msg = [msg(1:i_1-1) repmat(' ', 1, indentLength) msg(i_1:end)];
        ii_spaces(ii_spaces >= i_1) = ii_spaces(ii_spaces >= i_1)+indentLength;
        ii_lineBreaks(ii_lineBreaks >= i_1) = ii_lineBreaks(ii_lineBreaks >= i_1)+indentLength;
    if any(strcmpi(flags, '-wi'))
        i_1 = i_1+indentLength;
    end
end


if outputString
    msg = string(msg);
end