%Giles Holland 2022


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Standardize strings from "x"/'x' to 'x'
this.portName = var2char(this.portName);
%---


portName = this.portName;
numBytes = this.numBytes;
listenData = this.listenData;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isRowChar(portName) && ~isempty(portName))
    error('Property .portName must be a string.')
end

    if ~(~isempty(numBytes) || ~isempty(listenData))
        error('One of properties .numBytes or .listenData must be set.')
    end
if ~isempty(listenData)
    if ~isa(listenData, 'cell')
        listenData = {listenData};
    end
    listenData = row(listenData);
    for n = 1:numel(listenData)
        listenData{n} = row(listenData{n});
        if ~(isa(listenData{n}, 'numeric') && all(isIntegerVal(listenData{n}) & listenData{n} >= 0 & listenData{n} <= 255))
            error('Property .listenData must be a vector of integers between 0-255, a cell array of vectors, or [].')
        end
    end
    this.listenData = listenData;
else    
    if ~(isOneNum(numBytes) && isIntegerVal(numBytes) && numBytes > 0)
        error('Property .numBytes must be an integer > 0, or inf, or [].')
    end
end
%---


%Tell PsychBench this object will use the specified port.
%Opens port if not already opened by another object.
%User can specify port options with a port object in their experiment script.
%Returns port number for use with PTB IOPort commands.
%Replaces PTB IOPort('OpenSerialPort'), ('Close').
%TEST in port_open, port_close.
[this, n_port] = element_openPort(this, portName);


this.n_port = n_port;

%Initialize some record properties for first iteration of runFrame
this.data = [];
this.dataTimes = [];