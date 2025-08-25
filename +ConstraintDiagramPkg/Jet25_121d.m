function [FAR] = Jet25_121d(W_S, T_W, Aircraft)
%
% [FAR] = Jet25_121d(W_S, T_W, Aircraft)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 25 aug 2025
%
% derive the constraints for landing climb with one engine inoperative.
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
CL      = 0.85 * Aircraft.Specs.Aero.CL.Lnd;
CD0     = (Aircraft.Specs.Aero.CD0.Lnd + Aircraft.Specs.Aero.CD0.Tko) / 2;
AR      = Aircraft.Specs.Aero.AR;
e       = Aircraft.Specs.Aero.e.Lnd;
TempInc = Aircraft.Specs.Performance.TempInc;
MaxCont = Aircraft.Specs.Performance.MaxCont;
NumEng  = Aircraft.Specs.Propulsion.NumEngines;

% set tolerance
EPS06 = 1.0e-06;

% check for valid inputs
if (W_S < EPS06)
    error('ERROR - Jet25_121d: wing loading (W_S) must be greater than 0.');
end

if (CL < EPS06)
    error('ERROR - Jet25_121d: lift coefficient at landing (CL) must be greater than 0.');
end

if (CD0 < EPS06)
    error('ERROR - Jet25_121d: parasite drag coefficient at landing (CD0) must be greater than 0.');
end

if (AR < EPS06)
    error('ERROR - Jet25_121d: aspect ratio (AR) must be greater than 0.');
end

if (e < EPS06)
    error('ERROR - Jet25_121d: Oswald efficiency factor at landing (e) must be greater than 0.');
end

if (TempInc < EPS06)
    error('ERROR - Jet25_121d: temperature correction factor (TempInc) must be greater than 0.');
end

if (MaxCont < EPS06)
    error('ERROR - Jet25_121d: landing weight correction factor (MaxCont) must be greater than 0.');
end

if ((NumEng ~= 2) && (NumEng ~= 3) && (NumEng ~= 4))
    error('ERROR - Jet25_121d: number of engines (NumEng) must be 2, 3, or 4.');
end

if ((NumEng - floor(NumEng)) > EPS06)
    error('ERROR - Jet25_121d: number of engines (NumEng) must be an integer.');
end


%% EVALUATE THE CONSTRAINT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% correction for one-engine inoperative
OEI = ConstraintDiagramPkg.OEIMultiplier(Aircraft);

% correction for standard temperature increase, one engine inoperative, and landing weight 
CorrFactor = TempInc * OEI * 0.65;

% get the constraint type
Type = Aircraft.Settings.ConstraintType;

% find climb gradient
if (Type == 0)
    
    % find the number of engines and define the climb gradient
    if     (NumEng == 2)
        G = 0.021;
        
    elseif (NumEng == 3)
        G = 0.024;
        
    else
        G = 0.027;
        
    end

elseif (Type == 1)
    
    % compute the climb gradient from a sigmoid curve
    G = ConstraintDiagramPkg.Sigmoid(Aircraft, 0.6800, -16.8421, 0.5481, 2.0839);
    
else
    
    % throw an error
    error("ERROR - Jet25_121d: invalid Type selected, must be 0 or 1.");
    
end

% ratio of flight speed to stall speed is 1.5
ks = 1.5;

% return performance requirement as an inequality constraint
FAR = CorrFactor * (ks ^ 2 * CD0 / CL + CL / ks ^ 2 / pi / AR / e + G) - T_W;

% ----------------------------------------------------------

end