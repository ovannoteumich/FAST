function [FAR] = JetLFL(W_S, T_W, Aircraft)
%
% [FAR] = JetLFL(W_S, T_W, Aircraft)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 05 sep 2025
%
% derive the constraints for landing field length.
%
% INPUTS:
%     W_S      - grid of wing loading values.
%                size/type/units: m-by-p / double / [kg/m^2]
%
%     T_W      - grid of thrust-weight ratios.
%                size/type/units: m-by-p / double / [N/N]
%
%     Aircraft - information about the configuration being analyzed
%                size/type/units: 1-by-1 / struct / []
%
% OUTPUTS:
%     FAR      - inequality constraints pertaining to the performance
%                requirement.
%                size/type/units: m-by-p / double / []
%


%% PRE-PROCESSING %%
%%%%%%%%%%%%%%%%%%%%

% retrieve parameters from the aircraft structure
CL    = Aircraft.Specs.Aero.CL.Lnd;
SLand = Aircraft.Specs.Performance.LFL;
SObst = Aircraft.Specs.Performance.ObstLen;
Wl_W0 = Aircraft.Specs.Performance.Wland_MTOW;

% convert units for the lengths
SLand = SLand * UnitConversionPkg.ConvLength(1, "m", "ft");
SObst = SObst * UnitConversionPkg.ConvLength(1, "m", "ft");

% assume a 95% density ratio for a "hot day"
RhoRwy = 0.95;


%% EVALUATE THE CONSTRAINT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% landing distance is 60% of total landing distance
SLand = 0.6 * SLand - SObst;

% convert wing loading to english units
W_S = W_S .* UnitConversionPkg.ConvMass(1, "kg", "lbm") ./ UnitConversionPkg.ConvLength(1, "m", "ft") ^ 2;

% use Roskam's equation
FAR = W_S - RhoRwy * CL * SLand / 80 / Wl_W0;
    
% ----------------------------------------------------------

end