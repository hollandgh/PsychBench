%Translate recorded data to relative to experiment start for experiment results output.
%Also times in core record properties in runFrame script are EXPECTED times, used for running object.
%Need to wait until close for actual MEASURED times, used for experiment results output.
this.dataTime = this.dataTime-experiment.startTime;