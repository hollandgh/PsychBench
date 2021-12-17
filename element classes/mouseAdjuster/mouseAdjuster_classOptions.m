%   FRAMEWORKS
%   Which frameworks does the class work in? (string or array of strings)
%   One or both of 'ptb', 'mgl'.
frameworks = {'ptb' 'mgl'};


%   CORE FUNCTIONALITY OPTIONS
%   (array of strings)
%   e.g. 'screen', 'audio', 'responseRecorder', etc. See Programming Manual.
with = {'screen' 'adjuster'};


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
    'drag_x'                            false
    'drag_y'                            false
    'drag_xy'                           false
    'deltaRate'                         []
    'deltaIncrement'                    0
    'clickAreaSize'                     inf
    'move'                           	false
    'n_dragButton'                    	1
    'cursorShape'                       []
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
    };


%   SLEEPABLE
%   (true/false)
%   Can the stimulus/functionality be stopped and restarted just by stopping and
%   restarting calling the runFrame class script?
isSleepable = false;


%   DESCRIPTION
%   Description in the PsychBench menu (string).
desc = 'Lets subject adjust properties of other elements by mouse click & drag.';


%   HEADING
%   Heading in the PsychBench menu (string). [] = automatic.
heading = [];