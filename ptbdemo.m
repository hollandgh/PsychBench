%PsychBench+Psychtoolbox demo for MathWorks contract.
%Please see Milestone 2 Report (15 Dec 2021) for instructions.
%---


%This is the same as mgldemo.m except for the commented parts below.
%See comments in mgldemo.m.


%Change framework PsychBench is using to Psychtoolbox
pb_framework ptb

c = pbObject("cross");

l = pbObject("linearDotMask");

s = pbObject("sound");
s.fileName = ("/System/Library/Sounds/Submarine.aiff");

load bmlWalkerData.mat
w = pbObject("bmlWalker");
w.dataExpr = "bmlWalkerData{2}";


%Some additional general objects to make it more likely that Psychtoolbox will not crash in macOS...
%---
audio = pbObject("audio");
audio.sampleRate = 48000;

screen = pbObject("screen");
screen.doSyncTests = -1;
%---


showElements(c, l, s, w, screen, audio);