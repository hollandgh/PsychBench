%PREPROCESS INPUT PROPERTIES FOR DATA TYPE, UNITS
%---
%Standardize strings from "x"/'x' to 'x'.
this.portName = var2Char(this.portName);
this.options = var2Char(this.options);
%---


portName = this.portName;
data = this.data;
options = this.options;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isRowChar(portName) && ~isempty(portName))
    error('Property .portName must be a string.')
end
if ~(isRowNum(data) && all(isIntegerVal(data) & data >= 0 & data <= 255) && ~isempty(data))
    error('Property .data must be a row vector of integers between 0-255.')
end
if ~(isRowChar(options) || isempty(options))
    error('Property .options must be a string or [].')
end
%---


%Convert data to unsigned 8-bit integer type (byte values) for PTB IOPort('Write')
data = uint8(data);