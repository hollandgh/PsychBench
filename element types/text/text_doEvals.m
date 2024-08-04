function text = text_doEvals(text, this, trial, experiment) %#ok<*INUSD>

%Replace object property references in text with values...
%<this.>
%<trial.>
%<experiment.>


for exprStart = {'<this.' '<trial.' '<experiment.'}, exprStart = exprStart{1};
    ii = strfind(text, exprStart);
    for i = flip(ii)
        j = i+find(text(i+1:end) == '>', 1);
        if ~isempty(j)
            expr = text(i+1:j-1);
            try
                val = eval(expr);
            catch X
                    error(['In text: Cannot evaluate ' expr '.' 10 ...
                        '->' 10 ...
                        10 ...
                        X.message])
            end
                if ~(isRowNum(val) || isa(val, 'char'))
                    error(['Evaluating ' expr ' in text: Value referenced must be a number, row vector, or string. This value is:' 10 ...
                        10 ...
                        val2char(val)])
                end
            if isa(val, 'numeric')
                val = num2str(val);
            end
            text = [text(1:i-1) val text(j+1:end)];
        end
    end
end