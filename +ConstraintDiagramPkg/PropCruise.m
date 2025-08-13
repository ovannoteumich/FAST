function [FAR] = PropCruise(W_S, P_W, Aircraft)
%
% PropCruise.m
% written by Paul Mokotoff, prmoko@umich.edu
% adapted from code used in AEROSP 481 as a GSI
% last updated: 03 mar 2024
%
% find which wing-loading and power-loading combinations are (in)feasible
% for the required cruise power.
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

% get the true airspeed at cruise
[~, V, ~, ~, ~, Rho] = MissionSegsPkg.ComputeFltCon(Aircraft.Specs.Performance.Alts.Crs, 0, "Mach", Aircraft.Specs.Performance.Vels.Crs);

% convert the airspeed to ft/s
V = convvel(V, "m/s", "ft/s");

% convert the volume to slug/ft^3
Rho = Rho * convmass(1, "kg", "slug") * convlength(1, "ft", "m") ^ 3;

% get the propeller efficiency
EtaPropeller = Aircraft.Specs.Power.Eta.Propeller;

% get the lift-drag ratio at cruise
L_D = Aircraft.Specs.Aero.L_D.Crs;

% get the coefficient of lift at cruise
CLcrs = Aircraft.Specs.Aero.CLmax.Crs;

% convert from lift coefficient to drag coefficient
CDcrs = CLcrs / L_D;

% compute the dynamic pressure
q = 0.5 * Rho * V ^ 2;


%% FIND THE (IN)FEASIBLE COMBINATIONS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% convert the wing-loading from kg/m^2 to lbm/ft^2
W_S = W_S .* convmass(1, "kg", "lbm") .* convlength(1, "ft", "m") ^ 2;

% convert the power-loading from W/kg to hp/lbm
P_W = P_W ./ 1644;

% compute the constraint (account for lapsed power)
FAR = (q .* V  .* CDcrs ./ (550 .* EtaPropeller .* W_S)) ./ 0.75 - P_W;

% ----------------------------------------------------------

end