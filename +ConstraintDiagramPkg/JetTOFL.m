function [FAR] = JetTOFL(W_S, T_W, Aircraft)
%
% [FAR] = JetTOFL(W_S, T_W, Aircraft)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 15 aug 2025
%
% derive the constraints for takeoff field length.
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
CL      = Aircraft.Specs.Aero.CL.Tko;
BalFieldLen = UnitConversionPkg.ConvLength(Aircraft.Specs.Performance.TOFL, "m", "ft");
RhoRwy = 0.95;

% set tolerance
EPS06 = 1.0e-06;

% check for valid inputs
if (W_S < EPS06)
    error('ERROR - JetTOFL: wing loading (W_S) must be greater than 0.');
end

if (BalFieldLen < EPS06)
    error('ERROR - JetTOFL: balanced field length (BalFieldLen) must be greater than 0.');
end

if (CL < EPS06)
    error('ERROR - JetTOFL: lift coefficient at takeoff (CL) must be greater than 0.');
end

if (RhoRwy < EPS06)
    error('ERROR - JetTOFL: density correction factor (RhoRwy) must be greater than 0.');
end


%% EVALUATE THE CONSTRAINT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% compute the takeoff parameter, based on FAR 25
Top25 = BalFieldLen / 37.5;

% convert wing loading to english units
W_S = W_S .* UnitConversionPkg.ConvMass(1, "kg", "lbm") ./ UnitConversionPkg.ConvLength(1, "m", "ft") ^ 2;

% return performance requirement as an inequality constraint
FAR = W_S ./ (RhoRwy * CL * Top25) - T_W;

% ----------------------------------------------------------

end