%Giles Holland 2022


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Standardize strings from "x"/'x' to 'x'
this.portName = var2char(this.portName);
%---


portName = this.portName;
nn_listenButtons = this.nn_listenButtons;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isRowChar(portName) || isempty(portName))
    error('Property .portName must be a string or [].')
end

nn_listenButtons = row(nn_listenButtons);
if ~(isa(nn_listenButtons, 'numeric') && all(isIntegerVal(nn_listenButtons) & nn_listenButtons >= 1) || isempty(nn_listenButtons))
    error('Property .nn_listenButtons must be a vector of positive integers, or [].')
end
this.nn_listenButtons = nn_listenButtons;
%---


%Tell PsychBench this object will use a Cedrus pad on the specified port.
%Opens pad if not already opened by another object.
%User can specify pad options with a cedrusPad object in their experiment script.
%If portName = [] then user must have made ONE cedrusPad object to specify port or they will get an error.
%Returns pad number for use with PTB CedrusResponseBox commands.
%Also returns cedrusPad object with properties containing more info, also available in later type scripts in devices.cedrusPad.
%Replaces PTB CedrusResponseBox('Open'), ('ClearQueues'), ('GetBaseTimer'), ('Close').
[this, n_pad, cedrusPad] = element_openCedrusPad(this, portName);

    
if isempty(nn_listenButtons)
    %[] -> listen to all buttons
    nn_listenButtons = 1:8;
end


this.nn_listenButtons = nn_listenButtons;
this.n_pad = n_pad;
this.t0 = cedrusPad.t0;