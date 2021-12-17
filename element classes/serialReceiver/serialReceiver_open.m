%PREPROCESS INPUT PROPERTIES FOR DATA TYPE, UNITS
%---
%Standardize strings from "x"/'x' to 'x'.
this.portName = var2Char(this.portName);
this.options = var2Char(this.options);
%---


portName = this.portName;
numBytes = this.numBytes;
listenData = this.listenData;
options = this.options;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isRowChar(portName) && ~isempty(portName))
    error('Property .portName must be a string.')
end

if isempty(listenData)
    listenData = {};
end
if ~isa(listenData, 'cell')
    listenData = {listenData};
end
listenData = row(listenData(:));
if ~(isa(listenData, 'cell') && all(cellfun(@(x) isRowNum(x) && all(isIntegerVal(x) & x >= 0 & x <= 255),    listenData)))
    error('Property .listenData must be a row vector of integers between 0-255, cell array of row vectors, or [].')
end
this.listenData = listenData;
if isempty(listenData)
    if isempty(numBytes)
        error('One of properties .numBytes or .listenData must be set.')
    end
    if ~(isOneNum(numBytes) && isIntegerVal(numBytes) && numBytes > 0)
        error('Property .numBytes must be an integer > 0, or inf, or [].')
    end
end

if ~(isRowChar(options) || isempty(options))
    error('Property .options must be a string or [].')
end
%---


%Initialize some record properties for runFrame
this.data = [];
this.dataTime = [];