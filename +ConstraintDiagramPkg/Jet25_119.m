function [FAR] = Jet25_119(W_S, T_W, Aircraft)
%
% [FAR] = Jet25_119(W_S, T_W, Aircraft)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 25 aug 2025
%
% derive the constraints for a balked landing climb with all engines
% operative.
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
CD0     = Aircraft.Specs.Aero.CD0.Lnd;
AR      = Aircraft.Specs.Aero.AR;
e       = Aircraft.Specs.Aero.e.Lnd;
TempInc = Aircraft.Specs.Performance.TempInc;
MaxCont = Aircraft.Specs.Performance.MaxCont;

% set tolerance
EPS06 = 1.0e-06;

% check for valid inputs
if (W_S < EPS06)
    error('ERROR - Jet25_119: wing loading (W_S) must be greater than 0.');
end

if (CL < EPS06)
    error('ERROR - Jet25_119: lift coefficient at landing (CL) must be greater than 0.');
end

if (CD0 < EPS06)
    error('ERROR - Jet25_119: parasite drag coefficient at landing (CD0) must be greater than 0.');
end

if (AR < EPS06)
    error('ERROR - Jet25_119: aspect ratio (AR) must be greater than 0.');
end

if (e < EPS06)
    error('ERROR - Jet25_119: Oswald efficiency factor at landing (e) must be greater than 0.');
end

if (TempInc < EPS06)
    error('ERROR - Jet25_119: temperature correction factor (TempInc) must be greater than 0.');
end

if (MaxCont < EPS06)
    error('ERROR - Jet25_119: landing weight correction factor (MaxCont) must be greater than 0.');
end


%% EVALUATE THE CONSTRAINT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% correction for standard temperature increase and landing weight
CorrFactor = TempInc * 0.65;

% get the constraint type
Type = Aircraft.Settings.ConstraintType;

% find climb gradient
if (Type == 0)
    
    % climb gradient is >= 3.2% regardless of number of engines
    G = 0.032;
    
elseif (Type == 1)
    
    % compute the climb gradient from a sigmoid curve
    G = ConstraintDiagramPkg.Sigmoid(Aircraft, 0, 0, 0, 3.2);
    
else
    
    % throw an error
    error("ERROR - Jet25_119: invalid Type selected, must be 0 or 1.");
    
end

% ratio of flight speed to stall speed is 1.3
ks = 1.3;

% return performance requirement as an inequality constraint
FAR = CorrFactor * (ks ^ 2 * CD0 / CL + CL / ks ^ 2 / pi / AR / e + G) - T_W;

% ----------------------------------------------------------

end