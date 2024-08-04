%   HEADING
%   Heading in the pb menu (string).
%   For a visual stimulus element type leave at default [] = automatic based on core options below.
heading = [];


%   DESCRIPTION
%   Description in the pb menu (string).
desc = 'Records subject response or other input by key press. At default waits for any key press, then records and ends on its own.';


%   CORE OPTIONS
%   (array of strings)
%   For a visual stimulus element type leave at default 'screen'.
with = {'responseHandler'};


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
    'listenKeyNames'                    strings(0)
    'ignoreKeyNames'                   	strings(0)
    'n_device'                         	[]
    'useQueue'                          []
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
    };


%   DEPRECATED PROPERTIES (DURABLE TYPE ONLY)
%   Names of input properties that are no longer used but the type code can
%   still handle if users set them, e.g. renamed properties.
%   (array of strings)
inputPropertyDeprecatedNames = {
    'nn_listenKeys'
    'nn_ignoreKeys'
    };


%   SLEEPABLE
%   (true/false)
%   Would object stimulus/functionality always stop and restart smoothly if
%   PsychBench stops and restarts calling the _runFrame script?
%   For a visual stimulus element type typically leave at default true.
isSleepable = true;