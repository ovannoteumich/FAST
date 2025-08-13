function [FAR] = PropLnd(W_S, P_W, Aircraft)
%
% PropLnd.m
% written by Paul Mokotoff, prmoko@umich.edu
% adapted from code used in AEROSP 481 as a GSI
% last updated: 22 feb 2024
%
% find which wing-loading and power-loading combinations are (in)feasible
% for the given landing field length requirements.
%
% inputs : W_S      - grid of wing -loadings
%          P_W      - grid of power-loadings
%          Aircraft - data structure with info about the aircraft
%
% outputs: FAR      - grid indicating which wing-loading and power-loading
%                     combinations satisfy the landing field length
%                     requirement.
%


%% PRE-PROCESSING %%
%%%%%%%%%%%%%%%%%%%%

% get the density at landing altitude (assume same as takeoff) and sea-level
[~, ~, RhoLnd] = MissionSegsPkg.StdAtm(Aircraft.Specs.Performance.Alts.Tko);
[~, ~, RhoSL ] = MissionSegsPkg.StdAtm(                                  0);

% get the maximum lift coefficient
CLmax = Aircraft.Specs.Aero.CLmax.Lnd;

% get the landing field length
LFL = convlength(Aircraft.Specs.Performance.FieldLength.Lnd, "m", "ft");


%% FIND THE (IN)FEASIBLE COMBINATIONS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% compute the density ratio (assume a hot day --> multiply by 0.95
RhoRatio = 0.95 * RhoLnd / RhoSL;

% compute the maximum wing loading to land safely
MaxW_S = (LFL - 600) * RhoRatio * CLmax / 80;

% convert the wing-loading from kg/m^2 to lbm/ft^2
W_S = W_S .* convmass(1, "kg", "lbm") .* convlength(1, "ft", "m") ^ 2;

% compute the constraint
FAR = W_S - MaxW_S;

% ----------------------------------------------------------

end