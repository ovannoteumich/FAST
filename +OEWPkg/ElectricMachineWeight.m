function [W] = ElectricMachineWeight(P)
%
% [W] = ElectricMachineWeight(P)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 29 oct 2025
%
% predict the weight of an electric motor using a regression.
%
% INPUTS:
%     P - rated power.
%         size/type/units: m-by-n / double / [W]
%
%     W - weight.
%         size/type/units: m-by-n / double / [kg]
%

% convert the rated power from W to kW
P = P ./ 1000;

% compute the weight
W = 113.8 .* log10(P) -236.73;

end