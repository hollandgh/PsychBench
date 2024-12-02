fileName = this.fileName;


if this.profileWholeTrial
    %Undocumented
    profile on
end

    %For error checking in close
    if exist(fileName, 'file')
        s = load(fileName);
            if ~(isa(s, 'struct') && numel(fieldnames(s)) == 1 && isfield(s, 'profilerResults'))
                error('In property .fileName: File must contain only compatible profiler results to append to.')
            end
        n_results = numel(s.profilerResults)+1;
    else
        n_results = 1;
    end


this.n_results = n_results;