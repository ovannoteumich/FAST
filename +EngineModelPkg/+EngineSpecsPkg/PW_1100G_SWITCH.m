function [Engine] = PW_1100G_SWITCH() 
%
% [Engine] = PW_1100G_SWITCH()
% Written by: Emma Cassidy, emmasmit@umich.edu
% Last Updated: 7/10/25
%
% Hybrid-electric engine model for the PW1100G-JM with integrated 
% SWITCH generator-motor system. Includes conventional turbofan 
% architecture with electrical power components for parallel hybrid operation.
%
% Type = hybridized Turbofan
% Applicable Aircraft = Airbus A320neo (SWITCH Hybrid Configuration)

%% Design Point Values

% Design point Mach number
% Use 0.05 for Sea-Level Static (SLS) conditions
Engine.Mach = 0.05;

% Design point altitude [m]
% Use 0 for SLS conditions
Engine.Alt = 0;

% Overall Pressure Ratio (OPR)
% Typical for modern GTFs
Engine.OPR = 50;

% Fan Pressure Ratio (FPR)
% Ratio of fan exit pressure to inlet pressure
Engine.FPR = 1.65;

% Bypass Ratio (BPR)
% Ratio of bypass air to core air; high BPR for efficiency
Engine.BPR = 12.2;

% Turbine Inlet Temperature [K]
% Peak Tt4 value; reduced via electric assist in SWITCH
Engine.Tt4Max = 1850;

% Temperature Limits (not active yet)
Engine.TempLimit.Val = NaN;
Engine.TempLimit.Type = NaN;

% Design thrust at SLS [N]
% Nominal maximum takeoff thrust
Engine.DesignThrust = 111200;

%% Architecture

% Number of rotating spools (HP, LP)
Engine.NoSpools = 2;

% Spool RPMs [Fan/LP, HP]
% RPM of LP spool (fan-driven), and HP spool
Engine.RPMs = [10500, 24000];

% Fan Gearbox Ratio
% Gear reduction between fan and LP turbine
Engine.FanGearRatio = 3.0625;

% Fan Boosters (pre-compression stages)
% False if no additional boosting stages after fan
Engine.FanBoosters = false;

%% Airflows

% Passenger bleed flow (fraction of core flow)
% Used for cabin pressurization
Engine.CoreFlow.PaxBleed = 0.03;

% Leakage losses (fraction of core flow)
Engine.CoreFlow.Leakage = 0.01;

% Cooling air (not needed in SWITCH for hybrid modeling)
Engine.CoreFlow.Cooling = 0.0;

%% Sizing Limits

% Max iterations for engine sizing convergence
Engine.MaxIter = 300;

%% Efficiencies (Updated for SWITCH hybrid use case)
% more efficient then og GTF because of better operating conditions

Engine.EtaPoly.Inlet = 0.99;
Engine.EtaPoly.Diffusers = 0.99;
Engine.EtaPoly.Fan = 0.985;             % Reduced fan loading from motor assist
Engine.EtaPoly.Compressors = 0.91;      % Reduced bleed and improved stability margin
Engine.EtaPoly.BypassNozzle = 0.99;
Engine.EtaPoly.Combustor = 0.995;
Engine.EtaPoly.Turbines = 0.985;        % Lower blade loading and cooling demand
Engine.EtaPoly.CoreNozzle = 0.99;
Engine.EtaPoly.Nozzles = 0.99;
Engine.EtaPoly.Mixing = 0.955;          % Better flow matching

%% Hybrid Electric Integration (SWITCH-specific)

% Generator Specifications
% Converts mechanical power from HP spool to electrical power
Engine.Hybrid.Generator.Power_kW = 300;          % Max generator power
Engine.Hybrid.Generator.Efficiency = 0.96;       % Electrical conversion efficiency
Engine.Hybrid.Generator.Weight_kg = 80;          % Estimated weight
Engine.Hybrid.Generator.Spool = 'HP';            % Mounted to HP spool

% Inverter (Power Electronics)
% Converts AC/DC between generator, motor, and battery
Engine.Hybrid.Inverter.Efficiency = 0.97;
Engine.Hybrid.Inverter.Weight_kg = 25;

% Motor Characteristics
% Electrically assists fan shaft (LP spool) during takeoff/climb
Engine.Hybrid.Motor.Power_kW = 300;
Engine.Hybrid.Motor.Efficiency = 0.94;
Engine.Hybrid.Motor.Weight_kg = 85;
Engine.Hybrid.Motor.Location = 'Fan';            % Drives fan via LP shaft

% Battery System (optional)
% Supplies stored energy to motor; Lithium-ion assumed
Engine.Hybrid.Battery.SpecificEnergy_WhPerKg = 300;      % [Wh/kg]
Engine.Hybrid.Battery.Energy_kWh = 100;                  % Usable energy
Engine.Hybrid.Battery.Weight_kg = ...
    Engine.Hybrid.Battery.Energy_kWh * 1000 / Engine.Hybrid.Battery.SpecificEnergy_WhPerKg;
Engine.Hybrid.Battery.Voltage = 800;                     % High-voltage architecture

% Thermal Management System
% Handles motor/generator/inverter cooling
Engine.Hybrid.Cooling.Weight_kg = 30;
Engine.Hybrid.Cooling.Efficiency = 0.95;

% Electrical Architecture Description
% Defines power flow and integration strategy
Engine.Hybrid.Architecture = 'Parallel';  % Electric motor adds torque to fan shaft

end
