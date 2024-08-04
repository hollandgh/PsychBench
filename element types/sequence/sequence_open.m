%Giles Holland 2022


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Standardize strings from "x"/'x' to 'x'.
%-c: cell array of strings even for one.
this.elementExprs = var2char(this.elementExprs, '-c');
%---


elementExprs = this.elementExprs;
interval = this.interval;
repeat = this.repeat;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
elementExprs = row(elementExprs);
if ~(isa(elementExprs, 'cell') && ~isempty(elementExprs) && all(cellfun(@(x) isRowChar(x) || isempty(x),    elementExprs)))
    error('Property .elementExprs must be an array of strings, or a cell array with each cell containing a string or [].')
end
this.elementExprs = elementExprs;


if numel(interval) == 1
    interval = repmat(interval, 1, numel(elementExprs));
end
    interval = row(interval);
if ~(isa(interval, 'numeric') && numel(interval) == numel(elementExprs) && all(interval > 0))
    error('Property .interval must be a number > 0. It can also be a 1xn vector where n is number of elements in .elementExprs.')
end
this.interval = interval;


if ~is01(repeat)
    error('Property .repeat must be true/false.')
end
%---


%Convert intervals -> start times relative to object start for each child object.
%Append one dummy start time = time when last child object should end.
times = [0 cumsum(interval)];

%Get child object indexes
ii_elements = element_getElementIndex(elementExprs);

if ~isnan(ii_elements(1))
    %Cue first child object to start when sequence starts
    this = element_startElement(this, ii_elements(1));
end

%Initialize for first iteration of runFrame
n_element_prev = 1;


this.ii_elements = ii_elements;
this.times = times;
this.n_element_prev = n_element_prev;