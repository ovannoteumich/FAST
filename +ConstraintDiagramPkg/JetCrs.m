function [FAR] = JetCrs(W_S, T_W, Aircraft)
%
% [FAR] = JetCrs(W_S, T_W, Aircraft)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 16 sep 2025
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

% get the aircraft class
aclass = Aircraft.Specs.TLAR.Class;

% retrieve parameters from the aircraft structure
CD0  = Aircraft.Specs.Aero.CD0.Crs;  % cruise CD0
AR   = Aircraft.Specs.Aero.AR;
e    = Aircraft.Specs.Aero.e.Crs;
Mcrs = Aircraft.Specs.Performance.Vels.Crs;
zcrs = Aircraft.Specs.Performance.Alts.Crs; % keep in SI units for ComputeFltCon


%% EVALUATE THE CONSTRAINT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% compute the density and temperature at cruise
[~, ~, ~, ~   , ~, RhoSLS] = MissionSegsPkg.ComputeFltCon(   0, 0, "Mach", 0);
[~, ~, ~, TCrs, ~, RhoCrs] = MissionSegsPkg.ComputeFltCon(zcrs, 0, "Mach", 0);

% compute the speed of sound
a = sqrt(1.4 * 1716 * UnitConversionPkg.ConvTemp(TCrs, "K", "R"));

% compute the freestream velocity
VInf = a * Mcrs;

% compute the dynamic pressure
q = 0.5 * RhoCrs * UnitConversionPkg.ConvMass(1, "kg", "slug") / UnitConversionPkg.ConvLength(1, "m", "ft") ^ 3 * VInf ^ 2;

% compute density ratio to account for lost thrust
RhoRatio = RhoCrs / RhoSLS;
    
% convert wing loading to english units
W_S = W_S .* UnitConversionPkg.ConvMass(1, "kg", "lbm") ./ UnitConversionPkg.ConvLength(1, "m", "ft") ^ 2;

% check for turboprop/piston aircraft
if (strcmpi(aclass, "Turboprop") || strcmpi(aclass, "Piston"))
    
    % get the airspeed and convert to m/s
    V = UnitConversionPkg.ConvVel(VInf, "ft/s", "m/s");
    
    % convert to T/W
    T_W = 1 ./ (V .* T_W);
    
end

% Roskam and Mattingly's equations match
FAR = (q .* CD0 ./ W_S + W_S ./ q ./ pi ./ AR ./ e) ./ RhoRatio ^ 0.6 - T_W;
    
% ----------------------------------------------------------

end