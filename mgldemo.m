%PsychBench+MGL demo for MathWorks contract.
%Please see Milestone 2 Report (15 Dec 2021) for instructions.
%---


%Don't need to call if framework PsychBench is using is already set to MGL, but call just in case
pb_framework mgl

%Cross object.
%Leave all properties at default.
c = pbObject("cross");

%Linear dot mask object
%Leave all properties at default.
l = pbObject("linearDotMask");

%Sound object
%Leave all properties at default.
%NOTE: I'm assuming here your Submarine.aiff sound file is in the standard place--if not please change the path.
s = pbObject("sound");
s.fileName = ("/System/Library/Sounds/Submarine.aiff");

%Walker object.
%Leave all properties at default.
%Load data it needs--this .mat file is included in PsychBench.
load bmlWalkerData.mat
w = pbObject("bmlWalker");
w.dataExpr = "bmlWalkerData{2}";

%Show these three elements.
%Press spacebar to move between them.
showElements(c, l, s, w);