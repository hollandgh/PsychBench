%   HEADING
%   Heading in the pb menu (string).
%   For a visual stimulus element type leave at default [] = automatic based on core options below.
heading = [];


%   DESCRIPTION
%   Description in the pb menu (string).
desc = 'A radial checker disc with option for flicker, phase drift';


%   CORE OPTIONS
%   (array of strings)
%   For a visual stimulus element type leave at default 'screen'.
with = {'screen'};


%   INPUT PROPERTIES (DURABLE TYPE ONLY)
%   What input properties will objects of the type have?
%   Input properties can be set by users when building experiments.
%   Only define properties specific to the type, not core properties.
%   (2-column cell array)
%
%   Name (string, first letter lower case)
%
%                                       Default value
%   --------------------------------------------
inputPropertyDefs = {
    'diameter'                        	10
    'centerDiameter'                    0.2
    'numAngularChecks'                  20
    'numRadialChecks'                   8
    'radialScale'                       []
    'phase'                             1
    'meanIntensity'                 	0.5
    'amplitude'                      	0.5
    'contrast'                       	[]
    'color'                            	[1 1 1]
    'flickerFrequency'                  0
    'angularTemporalFrequency'          0
    'radialTemporalFrequency'           0
    'angularTemporalFrequencyBalanced'  0
    'radialTemporalFrequencyBalanced'   0
    'fps'                               30
    };


%   ADJUSTABLE PROPERTIES
%   What input properties can users allow subjects to adjust during experiments?
%   (2-column cell array)
%
%   Input property name (string)
%
%                                      	Dependent record property names (array of strings)
%   --------------------------------------------
adjustable = {
    'position'                          []
    'nn_eyes'                           []
    'rotation'                          []
    'colorMask'                         []
    'alpha'                             []
    'intensity'                         []
    'contrastMult'                      []
    };


%   DEPRECATED PROPERTIES (DURABLE TYPE ONLY)
%   Names of input properties that are no longer used but the type code can
%   still handle if users set them, e.g. renamed properties.
%   (array of strings)
inputPropertyDeprecatedNames = {
    };


%   SLEEPABLE
%   (true/false)
%   Would object stimulus/functionality always stop and restart smoothly if
%   PsychBench stops and restarts calling the _runFrame script?
%   For a visual stimulus element type typically leave at default true.
isSleepable = true;