function [FAR] = PropCeil(W_S, P_W, Aircraft)
%
% PropCeil.m
% written by Paul Mokotoff, prmoko@umich.edu
% adapted from code used in AEROSP 481 as a GSI
% last updated: 03 mar 2024
%
% find which wing-loading and power-loading combinations are (in)feasible
% for the given service ceiling.
%
% inputs : W_S      - grid of wing -loadings
%          P_W      - grid of power-loadings
%          Aircraft - data structure with info about the aircraft
%
% outputs: FAR      - grid indicating which wing-loading and power-loading
%                     combinations satisfy the service ceiling requirement.
%


%% PRE-PROCESSING %%
%%%%%%%%%%%%%%%%%%%%

% get the density at cruise altitude and sea-level
[~, ~, RhoCrs] = MissionSegsPkg.StdAtm(Aircraft.Specs.Performance.Alts.Crs);
[~, ~, RhoSL ] = MissionSegsPkg.StdAtm(                                  0);

% get the lift coefficient at cruise (offset, as recommended by Raymer)
CL = Aircraft.Specs.Aero.CLmax.Clb - 0.2;

% get the propeller efficiency
EtaPropeller = Aircraft.Specs.Power.Eta.Propeller;

% get the lift-drag ratio at climb
L_D = Aircraft.Specs.Aero.L_D.Clb;


%% FIND THE (IN)FEASIBLE COMBINATIONS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% assume a small climb gradient
G = 0.010;

% compute the density ratio
RhoRatio = RhoCrs / RhoSL;

% convert the wing-loading from kg/m^2 to lbm/ft^2
W_S = W_S .* convmass(1, "kg", "lbm") .* convlength(1, "ft", "m") ^ 2;

% convert the power-loading from W/kg to hp/lbm
P_W = P_W ./ 1644;

% compute the constraint (no corrections needed, assume MTOW and AEO)
FAR = sqrt(W_S ./ CL) .* (G + 1 / L_D) ./ (18.97 * EtaPropeller * RhoRatio) - P_W;

% ----------------------------------------------------------

end