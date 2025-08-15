function [FAR] = Jet25_111(W_S, T_W, Aircraft)
%
% [FAR] = Jet25_111(W_S, T_W, Aircraft)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 15 aug 2025
%
% derive the constraints for takeoff climb with one engine inoperative.
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
CD0     = Aircraft.Specs.Aero.CD0.Tko;
AR      = Aircraft.Specs.Aero.AR;
e       = Aircraft.Specs.Aero.e.Tko;
TempInc = Aircraft.Specs.Performance.TempInc;
NumEng  = Aircraft.Specs.Propulsion.NumEngines;

% set tolerance
EPS06 = 1.0e-06;

% check for valid inputs
if (W_S < EPS06)
    error('ERROR - Jet25_111: wing loading (W_S) must be greater than 0.');
end

if (CL < EPS06)
    error('ERROR - Jet25_111: lift coefficient at takeoff (CL) must be greater than 0.');
end

if (CD0 < EPS06)
    error('ERROR - Jet25_111: pARasite drag coefficient at takeoff (CD0) must be greater than 0.');
end

if (AR < EPS06)
    error('ERROR - Jet25_111: aspect ratio (AR) must be greater than 0.');
end

if (e < EPS06)
    error('ERROR - Jet25_111: Oswald efficiency factor at takeoff (e) must be greater than 0.');
end

if (TempInc < EPS06)
    error('ERROR - Jet25_111: temperature correction factor (TempInc) must be greater than 0.');
end

if ((NumEng ~= 2) && (NumEng ~= 3) && (NumEng ~= 4))
    error('ERROR - Jet25_111: number of engines (NumEng) must be 2, 3, or 4.');
end

if ((NumEng - floor(NumEng)) > EPS06)
    error('ERROR - Jet25_111: number of engines (NumEng) must be an integer.');
end


%% EVALUATE THE CONSTRAINT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% correction for one-engine inoperative
OEI = NumEng / (NumEng - 1);

% correction for standard temperature increase and one engine inoperative
CorrFactor = TempInc * OEI;

% find climb gradient
if     (NumEng == 2)
    G = 0.012;
    
elseif (NumEng == 3)
    G = 0.015;
    
else % (NumEng == 4)
    G = 0.017;
    
end

% required speed ratio is 1.2
ks = 1.2;

% return performance requirement as an inequality constraint
FAR = CorrFactor * (ks ^ 2 * CD0 / CL + CL / ks ^ 2 / pi / AR / e + G) - T_W;

% ----------------------------------------------------------

end