%Giles Holland 2022


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Standardize strings from "x"/'x' to 'x'
this.portName = var2char(this.portName);
%---


portName = this.portName;
data = this.data;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isRowChar(portName) && ~isempty(portName))
    error('Property .portName must be a string.')
end

data = row(data);
if ~(isa(data, 'numeric') && all(isIntegerVal(data) & data >= 0 & data <= 255) && ~isempty(data))
    error('Property .data must be a vector of integers between 0-255.')
end
this.data = data;
%---


%Tell PsychBench this object will use the specified port.
%Opens port if not already opened by another object.
%User can specify port options with a port object in their experiment script.
%Returns port number for use with PTB IOPort commands.
%Replaces PTB IOPort('OpenSerialPort'), ('Close').
%TEST in port_open, port_close.
[this, n_port] = element_openPort(this, portName);


%Convert data to unsigned 8-bit integer type (byte values) for PTB IOPort('Write')
data = uint8(data);


this.data = data;
this.n_port = n_port;