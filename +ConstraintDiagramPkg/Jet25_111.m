function [FAR] = Jet25_111(W_S, T_W, Aircraft)
%
% [FAR] = Jet25_111(W_S, T_W, Aircraft)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 05 sep 2025
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
CD0     = Aircraft.Specs.Aero.CD0.Tko - 0.025;
AR      = Aircraft.Specs.Aero.AR;
e       = Aircraft.Specs.Aero.e.Tko;
TempInc = Aircraft.Specs.Performance.TempInc;
NumEng  = Aircraft.Specs.Propulsion.NumEngines;
ReqType = Aircraft.Specs.TLAR.ReqType;
Vstall  = Aircraft.Specs.Performance.Vels.Stl;


%% EVALUATE THE CONSTRAINT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% correction for one-engine inoperative
OEI = ConstraintDiagramPkg.OEIMultiplier(Aircraft);

% correction for standard temperature increase and one engine inoperative
CorrFactor = TempInc * OEI;

% get the constraint type
Type = Aircraft.Settings.ConstraintType;

% find climb gradient
if (Type == 0)
    
    % find the number of engines and define the climb gradient
    if     (NumEng == 2)
        G = 0.012;
        
    elseif (NumEng == 3)
        G = 0.015;
        
    else % (NumEng == 4)
        G = 0.017;
        
    end

elseif (Type == 1)
    
    % compute the climb gradient from a sigmoid curve
    G = ConstraintDiagramPkg.Sigmoid(Aircraft, 0.5440, -18.0643, 0.5745, 1.1842);
    
else
    
    % throw an error
    error("ERROR - Jet25_111: invalid Type selected, must be 0 or 1.");
    
end

% required speed ratio is 1.2
ks = 1.2;

% assume a takeoff speed
Vtko = convvel(135, "kts", "ft/s");
Rho = 0.002377;

qinf = 0.5 * Rho * Vtko ^ 2;

% convert wing loading to english units
W_S = W_S .* UnitConversionPkg.ConvMass(1, "kg", "lbm") ./ UnitConversionPkg.ConvLength(1, "m", "ft") ^ 2;

% compute the lift coefficient
CL = W_S ./ qinf;

% return performance requirement as an inequality constraint
if (ReqType == 0)
    
    % use Roskam's equation
    FAR = CorrFactor * (ks ^ 2 * CD0 / CL + CL / ks ^ 2 / pi / AR / e + G) - T_W;
    
elseif (ReqType == 1)
    
    % convert wing loading to english units
    W_S = W_S .* 9.81 .* UnitConversionPkg.ConvForce(1, "N", "lbf") ./ UnitConversionPkg.ConvLength(1, "m", "ft") ^ 2;
    
    % compute the density at sea level (metric)
    [~, ~, ~, ~, ~, RhoSLS] = MissionSegsPkg.ComputeFltCon(0, 0, "Mach", 0);
    
    % convert density to english units
    RhoSLS = RhoSLS * UnitConversionPkg.ConvMass(1, "kg", "slug") / UnitConversionPkg.ConvLength(1, "m", "ft") ^ 3;
        
    % convert the stall speed to english units
    Vstall = Vstall * UnitConversionPkg.ConvVel(1, "m/s", "ft/s");
    
    % compute the dynamic pressure
    q = 0.5 .* RhoSLS .* (Vstall .* ks) .^ 2;
    
    % use Mattingly's equation
    FAR = CorrFactor .* (q .* CD0 ./ W_S + W_S ./ q ./ (pi * AR * e) + G) - T_W;
    
else
    
    % throw error
    error("ERROR - Jet25_111: ReqType must be either 0 (Roskam) or 1 (Mattingly).");
    
end

% ----------------------------------------------------------

end