function text = text_doEvals(text, this, trial, experiment) %#ok<*INUSD>

%Replace object property references in text with values...
%<this.>
%<trial.>
%<experiment.>


ii = strfind(text, '<pb:');
for i = flip(ii)
    k = [];
    j = i;
    while isempty(k)
        j = j+find(text(j+1:end) == '>', 1);
        if      isempty(j)
            break
        elseif  j+1 <= length(text)
            if  text(j+1) ~= '>'
                k = j;
            else
                %Allow '>>' = >
                text(j+1) = [];
            end
        else
                k = j;
        end
    end

    if ~isempty(k)
        expr = text(i+4:k-1);
        try
            val = evaler(expr, this, trial, experiment);
        catch X
                error(['In text: Cannot evaluate ' expr ' .' 10 ...
                    '->' 10 ...
                    10 ...
                    X.message])
        end
        %Works if already a string
        val = num2str(val);
            if ~isRowChar(val)
                error([expr ' in text must evaluate to a number, row vector, or string.'])
            end
        text = [text(1:i-1) val text(k+1:end)];
    end
end


end




function ans = evaler(uyzruywyhwlhxkmgtrdbsxkvnnyvsvmheirvupgbectovuchuj, this, trial, experiment)


%Needs to work for all cases: expression, script setting ans, etc.
try
    ans = eval(uyzruywyhwlhxkmgtrdbsxkvnnyvsvmheirvupgbectovuchuj); %#ok<NOANS>
catch
    eval(uyzruywyhwlhxkmgtrdbsxkvnnyvsvmheirvupgbectovuchuj)
end


end