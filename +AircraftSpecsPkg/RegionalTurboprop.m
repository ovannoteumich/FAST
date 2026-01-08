function [Aircraft] = RegionalTurboprop(iarch)
%
% [Aircraft] = RegionalTurboprop()
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 08 jan 2026
% 
% specifications for a 90-passenger regional turboprop configuration.
%
% INPUTS:
%     iarch    - propulsion system architecture to be defined. the power
%                management strategy remains fixed for this sizing study.
%                the following system architectures are available:
%
%                    a) 1 = turboelectric architecture - one gas turbine
%                           engine powering two electric motors (one per
%                           wing).
%
%                    b) 2 = hybrid turboelectric architecture - one gas
%                           turbine engine powering two electric motors
%                           one per wing). the electric motor output power
%                           is supplemented by a battery.
%
%                    c) 3 = distributed turboelectric architecture - one
%                           gas turbine engine powers six electric motors
%                           (three per wing).
%
% OUTPUTS:
%     Aircraft - an aircraft structure to be used for analysis.
%                size/type/units: 1-by-1 / struct / []
%


%% TOP-LEVEL AIRCRAFT REQUIREMENTS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% expected entry-into-service year
Aircraft.Specs.TLAR.EIS = 2035;

% aircraft class, can be either:
%     "Piston"    = piston engine
%     "Turboprop" = turboprop engine
%     "Turbofan"  = turbojet or turbofan engine
Aircraft.Specs.TLAR.Class = "Turboprop";

% approximate number of passengers 
Aircraft.Specs.TLAR.MaxPax = 90;
 

%% VEHICLE PERFORMANCE %%
%%%%%%%%%%%%%%%%%%%%%%%%%

% takeoff speed (m/s)
Aircraft.Specs.Performance.Vels.Tko = 63;

% cruise speed (mach)
Aircraft.Specs.Performance.Vels.Crs = 0.60;

% takeoff altitude (m)
Aircraft.Specs.Performance.Alts.Tko = 0;

% cruise altitude (m)
Aircraft.Specs.Performance.Alts.Crs = 7600;

% design range (m)
Aircraft.Specs.Performance.Range = 750e+03;

% maximum rate of climb (m/s)
Aircraft.Specs.Performance.RCMax = 10.16;


%% AERODYNAMICS %%
%%%%%%%%%%%%%%%%%%

% get a lift-to-drag ratio multiplier for the distributed propulsion system
if (iarch == 3)
    LDMult = 1.04;
    
else
    LDMult = 1.00;
    
end

% lift-drag ratio during cruise
Aircraft.Specs.Aero.L_D.Crs = 24.00 * LDMult;

% lift-drag ratio during climb and descent (80% of cruise L/D)
Aircraft.Specs.Aero.L_D.Clb = 19.20 * LDMult;
Aircraft.Specs.Aero.L_D.Des = 19.20 * LDMult;

% wing loading (kg / m^2)
Aircraft.Specs.Aero.W_S.SLS = 510;


%% WEIGHTS %%
%%%%%%%%%%%%%

% maximum takeoff weight (kg) [initial estimate, not exact result]
Aircraft.Specs.Weight.MTOW = 30500;


%% PROPULSION %%
%%%%%%%%%%%%%%%%

% set the number of distributed propulsors, if necessary
if (iarch == 3)
    Aircraft.Specs.Propulsion.NumDTE = 6;
end

% function to create propulsion system
Aircraft = AircraftSpecsPkg.RegionalTurbopropPropulsion(Aircraft, iarch);

% select a turboshaft engine used on a regional transport aircraft
Aircraft.Specs.Propulsion.Engine = EngineModelPkg.EngineSpecsPkg.PW_127M();


%% POWER %%
%%%%%%%%%%%

% gravimetric specific energy of fuel (kWh/kg)
Aircraft.Specs.Power.SpecEnergy.Fuel = 11.90;

% gravimetric specific energy of battery (kWh/kg), if necessary
Aircraft.Specs.Power.SpecEnergy.Batt = 0.360;

% power-weight ratio for the aircraft (kW/kg)
Aircraft.Specs.Power.P_W.SLS = 0.15;

% electric motor and generator power-weight ratio (kW/kg)
Aircraft.Specs.Power.P_W.EM = 5;
Aircraft.Specs.Power.P_W.EG = 5;

% battery cells in series and parallel, if necessary
if (iarch == 2)
    
    % initial battery size (assume a system voltage of 240 V, vary cells in
    % parallel during the sizing process)
    Aircraft.Specs.Power.Battery.ParCells = 100;
    Aircraft.Specs.Power.Battery.SerCells =  59;
    
    % initial battery SOC
    Aircraft.Specs.Power.Battery.BegSOC = 100;
    
else
    
    % no cells in series/parallel
    Aircraft.Specs.Power.Battery.ParCells = NaN;
    Aircraft.Specs.Power.Battery.SerCells = NaN;
    
    % no SOC necessary
    Aircraft.Specs.Power.Battery.BegSOC = NaN;
    
end


%% SETTINGS %%
%%%%%%%%%%%%%%

% iteration limit and convergence tolerance for OEW iteration
Aircraft.Settings.OEW.MaxIter = 50;
Aircraft.Settings.OEW.Tol     = 0.001;

% maximum number of iterations during aircraft sizing
Aircraft.Settings.Analysis.MaxIter = 50;

% analysis type, either:
%     +1 for on -design mode (aircraft performance and sizing)
%     -1 for off-design mode (aircraft performance           )
Aircraft.Settings.Analysis.Type = +1;

% ----------------------------------------------------------

end