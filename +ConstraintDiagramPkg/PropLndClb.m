function [FAR] = PropLndClb(W_S, P_W, Aircraft)
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

% get the lift coefficient during landing (assume flaps extended)
CL = Aircraft.Specs.Aero.CLmax.Lnd - 0.2;

% get the propeller efficiency
EtaPropeller = Aircraft.Specs.Power.Eta.Propeller;

% get the lift-drag ratio at climb
L_D = Aircraft.Specs.Aero.L_D.Clb;


%% FIND THE (IN)FEASIBLE COMBINATIONS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the required climb gradient is 3.0%
G = 0.030;

% convert the wing-loading from kg/m^2 to lbm/ft^2
W_S = W_S .* convmass(1, "kg", "lbm") .* convlength(1, "ft", "m") ^ 2;

% convert the power-loading from W/kg to hp/lbm
P_W = P_W ./ 1644;

% landing weight correction
Wland_MTOW = 0.65;

% compute the constraint (correct for landing weight, assume AEO)
FAR = (sqrt(W_S ./ CL) .* (G + 1 / L_D) ./ (18.97 * EtaPropeller)) .* ...
      Wland_MTOW ^ (3 / 2) - P_W;

% ----------------------------------------------------------

end