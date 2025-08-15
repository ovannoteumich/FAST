function [FAR] = JetLFL(W_S, T_W, Aircraft)
%
% [FAR] = JetLFL(W_S, T_W, Aircraft)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 15 aug 2025
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
CL      = Aircraft.Specs.Aero.CL.Lnd;
TotLandDist = UnitConversionPkg.ConvLength(Aircraft.Specs.Performance.LFL, "m", "ft");
SObst = UnitConversionPkg.ConvLength(Aircraft.Specs.Performance.ObstLen, "m", "ft");
RhoRwy = 0.95;

% set tolerance
EPS06 = 1.0e-06;

% check for valid inputs
if (TotLandDist < EPS06)
    error('ERROR - JetLFL: total landing distance (TotLandDist) must be greater than 0.');
end

if (CL < EPS06)
    error('ERROR - JetLFL: lift coefficient at landing (CL) must be greater than 0.');
end

if (RhoRwy < EPS06)
    error('ERROR - JetLFL: density correction factor (RhoRwy) must be greater than 0.');
end


%% EVALUATE THE CONSTRAINT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% landing distance is 60% of total landing distance
SLand = 0.6 * TotLandDist - SObst;

% convert wing loading to english units
W_S = W_S .* UnitConversionPkg.ConvMass(1, "kg", "lbm") ./ UnitConversionPkg.ConvLength(1, "m", "ft") ^ 2;

% return performance requirement as an inequality constraint
FAR = W_S - RhoRwy * CL * SLand / 80 / 0.65;

% ----------------------------------------------------------

end