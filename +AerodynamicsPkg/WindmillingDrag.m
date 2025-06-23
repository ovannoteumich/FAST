function [CD] = WindmillDrag(Aircraft)
%
% [CD] = WindmillDrag(Aircraft)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 10 jun 2025
%
% estimate the windmilling drag from any failed engines.
%
% INPUTS:
%     Aircraft - data structure with the aircraft specifications and
%                mission history.
%                size/type/units: 1-by-1 / struct / []
%
% OUTPUTS:
%     CD       - drag coefficient due to windmilling engines.
%                size/type/units: n-by-1 / double / []
%

% return 0 for now
CD = 0;

end