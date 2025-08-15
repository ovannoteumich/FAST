function [Split] = EvalSplit(SplitFun, SplitVal)
%
% [Split] = EvalSplit(SplitFun, SplitVal)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 13 aug 2025
%
% given a power management strategy (SplitFun), evaluate it for a given set
% of values (SplitVal). this function now works for an unlimited number of
% power splits (now vectorized instead of individual arguments).
%
% INPUTS:
%     SplitFun - function handle to evaluate the power split.
%                size/type/units: 1-by-1 / function handle / []
%
%     SplitVal - power split values.
%                size/type/units: m-by-n / double / []
%
% OUTPUTS:
%     Split    - the power split after it has been evaluated.
%                size/type/units: p-by-q / double / []
%

% ----------------------------------------------------------

% get the number of arguments in the split
narg = length(SplitVal);%nargin(SplitFun);

% create a cell array for storing arguments
Vals = cell(1, narg);

% loop through all values
for i = 1:narg
    Vals{i} = SplitVal(i);
end

% evaluate the function
if (narg > 0)
    Split = SplitFun(Vals{:});
    
else
    Split = SplitFun();
    
end

% ----------------------------------------------------------

end