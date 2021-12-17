%   FRAMEWORKS
%   Which frameworks does the class work in? (string or array of strings)
%   One or both of 'ptb', 'mgl'.
frameworks = {'ptb' 'mgl'};


%   CORE FUNCTIONALITY OPTIONS
%   (array of strings)
%   e.g. 'screen', 'audio', 'responseRecorder', etc. See Programming Manual.
with = 'screen';


%   INPUT PROPERTY DEFINITIONS (DURABLE CLASS ONLY)
%   What input properties will objects of the class have?
%   Input properties can be set by users when building experiments.
%   Only define properties specific to the class, not core properties.
%   (2-column cell array)
%
%   Name (string, first letter lower case)
%
%                                       Default value
%   --------------------------------------------
inputPropertyDefs = {
    'size'                           	8
    'showFill'                        	true
    'color'                           	[1 1 1]
    'showBorder'                      	false
    'borderWidth'                     	0.15
    'borderColor'                   	[1 1 1]
    };


%   ADJUSTABLE PROPERTIES
%   What input properties can users let subjects adjust during experiments?
%   (2-column cell array)
%
%   Input property name (string)
%
%                                      	Dependent record property names (array of strings)
%   --------------------------------------------
adjustable = {
    'position'                          []
    'nn_eyes'                           []
    'rotate'                            []
    'opacity'                           []
    };


%   SLEEPABLE
%   (true/false)
%   Can the stimulus/functionality be stopped and restarted just by stopping and
%   restarting calling the runFrame class script?
isSleepable = true;


%   DESCRIPTION
%   Description in the PsychBench menu (string).
desc = 'A circle/ellipse or circular/elliptical frame.';


%   HEADING
%   Heading in the PsychBench menu (string). [] = automatic.
heading = [];