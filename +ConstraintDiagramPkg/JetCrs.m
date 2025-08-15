function [FAR] = JetCrs(W_S, T_W, Aircraft)
%
% [FAR] = JetCrs(W_S, T_W, Aircraft)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 15 aug 2025
%
% derive the constraints for cruise performance.
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
CD0     = Aircraft.Specs.Aero.CD0.Crs;  % cruise CD0
AR      = Aircraft.Specs.Aero.AR;
e       = Aircraft.Specs.Aero.e.Crs;
MachCrs = Aircraft.Specs.Performance.Vels.Crs;
CruiseAlt = Aircraft.Specs.Performance.Alts.Crs; % keep in SI units for ComputeFltCon

% set tolerance
EPS06 = 1.0e-06;

% check for valid inputs
if (W_S < EPS06)
    error('ERROR - JetCrs: wing loading (W_S) must be greater than 0.');
end

if (CD0 < EPS06)
    error('ERROR - JetCrs: parasite drag coefficient at cruise (CD0) must be greater than 0.');
end

if (AR < EPS06)
    error('ERROR - JetCrs: aspect ratio (AR) must be greater than 0.');
end

if (e < EPS06)
    error('ERROR - JetCrs: Oswald efficiency factor at cruise (e) must be greater than 0.');
end

if (MachCrs < EPS06)
    error('ERROR - JetCrs: Mach number at cruise (MachCrs) must be greater than 0.');
end

if (CruiseAlt < -EPS06)
    error('ERROR - JetCrs: cruise altitude (CruiseAlt) must be greater than or equal to 0.');
end


%% EVALUATE THE CONSTRAINT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% compute the density and temperature at cruise
[~, ~, ~, ~   , ~, RhoSLS] = MissionSegsPkg.ComputeFltCon(        0, 0, "Mach", 0);
[~, ~, ~, TCrs, ~, RhoCrs] = MissionSegsPkg.ComputeFltCon(CruiseAlt, 0, "Mach", 0);

% compute the speed of sound
a = sqrt(1.4 * 1716 * UnitConversionPkg.ConvTemp(TCrs, "K", "R"));

% compute the freestream velocity
VInf = a * MachCrs;

% compute the dynamic pressure
q = 0.5 * RhoCrs * UnitConversionPkg.ConvMass(1, "kg", "slug") / UnitConversionPkg.ConvLength(1, "m", "ft") ^ 3 * VInf ^ 2;

% compute density ratio to account for lost thrust
RhoRatio = RhoCrs / RhoSLS;

% convert wing loading to english units
W_S = W_S .* UnitConversionPkg.ConvMass(1, "kg", "lbm") ./ UnitConversionPkg.ConvLength(1, "m", "ft") ^ 2;

% return performance requirement as an inequality constraint
FAR = (q .* CD0 ./ W_S + W_S ./ q ./ pi ./ AR ./ e) ./ RhoRatio ^ 0.6 - T_W;

% ----------------------------------------------------------

end