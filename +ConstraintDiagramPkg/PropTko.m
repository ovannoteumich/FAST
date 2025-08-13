function [FAR] = PropTko(W_S, P_W, Aircraft)
%
% PropTko.m
% written by Paul Mokotoff, prmoko@umich.edu
% adapted from code used in AEROSP 481 as a GSI
% last updated: 22 feb 2024
%
% find which wing-loading and power-loading combinations are (in)feasible
% for the given takeoff field length requirements.
%
% inputs : W_S      - grid of wing -loadings
%          P_W      - grid of power-loadings
%          Aircraft - data structure with info about the aircraft
%
% outputs: FAR      - grid indicating which wing-loading and power-loading
%                     combinations satisfy the TOFL requirement.
%


%% PRE-PROCESSING %%
%%%%%%%%%%%%%%%%%%%%

% get the density at takeoff altitude and sea-level
[~, ~, RhoTko] = MissionSegsPkg.StdAtm(Aircraft.Specs.Performance.Alts.Tko);
[~, ~, RhoSL ] = MissionSegsPkg.StdAtm(                                  0);

% get the maximum lift coefficient
CLmax = Aircraft.Specs.Aero.CLmax.Tko;

% get the takeoff field length (convert to ft for equation below)
TOFL = convlength(Aircraft.Specs.Performance.FieldLength.Tko, "m", "ft");


%% FIND THE (IN)FEASIBLE COMBINATIONS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% compute the takeoff parameter
TOP23 = (-8.1340 + sqrt(8.1340 ^ 2 + 4 * 0.0149 * TOFL)) / (2 * 0.0149);

% compute the density ratio (and assume a hot day --> multiply by 0.95)
RhoRatio = 0.95 * RhoTko / RhoSL;

% convert the wing-loading from kg/m^2 to lbm/ft^2
W_S = W_S .* convmass(1, "kg", "lbm") .* convlength(1, "ft", "m") ^ 2;

% convert the power-loading from W/kg to hp/lbm
P_W = P_W ./ 1644;

% compute the constraint
FAR = W_S ./ (TOP23 * RhoRatio * CLmax) - P_W;

% ----------------------------------------------------------

end