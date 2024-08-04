fileName = this.fileName;
n_results = this.n_results;


if this.profileWholeTrial
    %Undocumented
    profile off
end


%If ran save results
if this.ran
    profilerResults = profile('info');

    if exist(fileName, 'file')
        %Append to existing profiler results in file
        s = load(fileName);
            if ~(isa(s, 'struct') && numel(fieldnames(s)) == 1 && isfield(s, 'profilerResults'))
                error('In property .fileName: File must contain only compatible profiler results to append to.')
            end
            if numel(s.profilerResults)+1 > n_results
                error('You can only run one profiler element in a trial.')                
            end
        try
            profilerResults = [s.profilerResults profilerResults];
        catch
                error('In property .fileName: File must contain compatible profiler results to append to.')
        end
    end

    save(fileName, 'profilerResults')
end