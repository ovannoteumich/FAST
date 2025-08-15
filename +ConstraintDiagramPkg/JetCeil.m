function [FAR] = JetCeil(W_S, T_W, Aircraft)
%
% [FAR] = JetCeil(W_S, T_W, Aircraft)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 15 aug 2025
%
% derive the constraints for service ceiling.
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
CD0     = Aircraft.Specs.Aero.CD0.Crs;
AR      = Aircraft.Specs.Aero.AR;
e       = Aircraft.Specs.Aero.e.Crs;
ServCeil = Aircraft.Specs.Performance.Alts.Srv; % keep in SI units for ComputeFltCon
NumEng  = Aircraft.Specs.Propulsion.NumEngines;

% set tolerance
EPS06 = 1.0e-06;

% check for valid inputs
if (W_S < EPS06)
    error('ERROR - JetCeil: wing loading (W_S) must be greater than 0.');
end

if (CD0 < EPS06)
    error('ERROR - JetCeil: parasite drag coefficient at cruise (CD0) must be greater than 0.');
end

if (AR < EPS06)
    error('ERROR - JetCeil: aspect ratio (AR) must be greater than 0.');
end

if (e < EPS06)
    error('ERROR - JetCeil: Oswald efficiency factor at cruise (e) must be greater than 0.');
end

if (ServCeil < -EPS06)
    error('ERROR - JetCeil: service ceiling (ServCeil) must be greater than or equal to 0.');
end

if ((NumEng ~= 2) && (NumEng ~= 3) && (NumEng ~= 4))
    error('ERROR - JetCeil: number of engines (NumEng) must be 2, 3, or 4.');
end

if ((NumEng - floor(NumEng)) > EPS06)
    error('ERROR - JetCeil: number of engines (NumEng) must be an integer.');
end


%% EVALUATE THE CONSTRAINT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get densities at sea-level and service ceiling
[~, ~, ~, ~, ~, RhoSLS] = MissionSegsPkg.ComputeFltCon(0       , 0, "Mach", 0);
[~, ~, ~, ~, ~, RhoSrv] = MissionSegsPkg.ComputeFltCon(ServCeil, 0, "Mach", 0);

% compute density ratio of service ceiling to sea-level
RhoRatio = RhoSrv / RhoSLS;

% use climb gradient from enroute climb phase
if     (NumEng == 2)
    G = 0.012;
    
elseif (NumEng == 3)
    G = 0.015;
    
else % (NumEng == 4)
    G = 0.017;
    
end

% return performance requirement as an inequality constraint
FAR = (2 * sqrt(CD0 / pi / e / AR) + G) / RhoRatio ^ 0.6 - T_W;

% ----------------------------------------------------------

end