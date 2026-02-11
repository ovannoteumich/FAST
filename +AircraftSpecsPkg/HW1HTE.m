function [Aircraft] = HW1HTE()
%
% [Aircraft] = ERJ175LR_Elec()
% originally written for E175 by Nawa Khailany
% modified to E175LR by Paul Mokotoff, prmoko@umich.edu
% modified to E175LR_Elec by Yipeng Liu
% last updated: 08 jan 2026
% 
% Create a baseline model of the ERJ 175, long-range (also known as
% an ERJ 170-200) and electrified version. This version uses a parallel 
% hybrid propulsion architecture.
% 
% INPUTS:
%     none
%
% OUTPUTS:
%     Aircraft - an aircraft structure to be used for analysis.
%                size/type/units: 1-by-1 / struct / []
%


%% TOP-LEVEL AIRCRAFT REQUIREMENTS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% expected entry-into-service year
Aircraft.Specs.TLAR.EIS = 2035;

% ** REQUIRED **
% aircraft class, can be either:
%     'Piston'    = piston engine
%     'Turboprop' = turboprop engine
%     'Turbofan'  = turbojet or turbofan engine
Aircraft.Specs.TLAR.Class = "Turboprop";

% ** REQUIRED **
% approximate number of passengers
Aircraft.Specs.TLAR.MaxPax = 90;
 

%% VEHICLE PERFORMANCE %%
%%%%%%%%%%%%%%%%%%%%%%%%%

% takeoff speed (m/s)
Aircraft.Specs.Performance.Vels.Tko = 63;

% cruise  speed (mach)
Aircraft.Specs.Performance.Vels.Crs = 0.6; % at 35,000 ft, Mach 0.78

% takeoff altitude (m)
Aircraft.Specs.Performance.Alts.Tko = 0;

% cruise altitude (m)
Aircraft.Specs.Performance.Alts.Crs = 7600;

% ** REQUIRED **
% design range (m)
Aircraft.Specs.Performance.Range = UnitConversionPkg.ConvLength(750, "km", "m");

% maximum rate of climb (m/s), assumed 2,250 ft/min (and converted)
Aircraft.Specs.Performance.RCMax = 10.16;


%% AERODYNAMICS %%
%%%%%%%%%%%%%%%%%%

% lift-drag ratio during climb  (assumed same as ERJ175, standard range)
Aircraft.Specs.Aero.L_D.Clb = 19.2;

% lift-drag ratio during cruise (assumed same as ERJ175, standard range)
Aircraft.Specs.Aero.L_D.Crs = 24.0;

% assume same lift-drag ratio during climb and descent
Aircraft.Specs.Aero.L_D.Des = Aircraft.Specs.Aero.L_D.Clb;

% wing loading (kg / m^2)
Aircraft.Specs.Aero.W_S.SLS = 510;


%% WEIGHTS %%
%%%%%%%%%%%%%

% maximum takeoff weight (kg)
Aircraft.Specs.Weight.MTOW = 30500;

% electric generator weight (kg)
Aircraft.Specs.Weight.EG = NaN;

% electric motor weight (kg)
Aircraft.Specs.Weight.EM = 0;

% block fuel weight (kg)
Aircraft.Specs.Weight.Fuel = UnitConversionPkg.ConvMass(20785, "lbm", "kg");

% battery weight (kg), leave NaN for propulsion systems without batteries
Aircraft.Specs.Weight.Batt = 0;


%% PROPULSION %%
%%%%%%%%%%%%%%%%

% ** REQUIRED ** propulsion system architecture, either:
%     (1) "C"   = conventional
%     (2) "E"   = fully electric
%     (3) "TE"  = fully turboelectric
%     (4) "PE"  = partially turboelectric
%     (5) "PHE" = parallel hybrid electric
%     (6) "SHE" = series hybrid electric
%     (7) "O"   = other architecture (specified by the user)
Aircraft.Specs.Propulsion.PropArch.Type = "O";

% architecture matrix
Aircraft.Specs.Propulsion.PropArch.Arch = ...
    [0,0,1,0,0,0,0,0,0,0,0;
     0,0,0,0,1,1,0,0,0,0,0;
     0,0,0,1,0,0,0,0,0,0,0;
     0,0,0,0,0,0,1,1,0,0,0;
     0,0,0,0,0,0,1,0,0,0,0;
     0,0,0,0,0,0,0,1,0,0,0;
     0,0,0,0,0,0,0,0,1,0,0;
     0,0,0,0,0,0,0,0,0,1,0;
     0,0,0,0,0,0,0,0,0,0,1;
     0,0,0,0,0,0,0,0,0,0,1;
     0,0,0,0,0,0,0,0,0,0,0;
     ];

% upstream operational matrix
Aircraft.Specs.Propulsion.PropArch.OperUps = @(lam) ...
    [0,0,1,0,0,0,0,0,0,0,0;
     0,0,0,0,0.5,0.5,0,0,0,0,0;
     0,0,0,1,0,0,0,0,0,0,0;
     0,0,0,0,0,0,0.5,0.5,0,0,0;
     0,0,0,0,0,0,lam,0,0,0,0;
     0,0,0,0,0,0,0,lam,0,0,0;
     0,0,0,0,0,0,0,0,1,0,0;
     0,0,0,0,0,0,0,0,0,1,0;
     0,0,0,0,0,0,0,0,0,0,1;
     0,0,0,0,0,0,0,0,0,0,1;
     0,0,0,0,0,0,0,0,0,0,0];
 
% downstream operational matrix
Aircraft.Specs.Propulsion.PropArch.OperDwn = @(lam) ...
    [0,0,0,0,0,0,0,0,0,0,0;
     0,0,0,0,0,0,0,0,0,0,0;
     1,0,0,0,0,0,0,0,0,0,0;
     0,0,1,0,0,0,0,0,0,0,0;
     0,1,0,0,0,0,0,0,0,0,0;
     0,1,0,0,0,0,0,0,0,0,0;
     0,0,0,1-lam,lam,0,0,0,0,0,0;
     0,0,0,1-lam,0,lam,0,0,0,0,0;
     0,0,0,0,0,0,1,0,0,0,0;
     0,0,0,0,0,0,0,1,0,0,0;
     0,0,0,0,0,0,0,0,0.5,0.5,0
     ];
 
% upstream efficiency matrix
Aircraft.Specs.Propulsion.PropArch.EtaUps = ...
    [1,1,1,1,1,1,1,1,1,1,1;
     1,1,1,1,1,1,1,1,1,1,1;
     1,1,1,0.96,1,1,1,1,1,1,1;
     1,1,1,1,1,1,0.96,0.96,1,1,1;
     1,1,1,1,1,1,0.96,1,1,1,1;
     1,1,1,1,1,1,1,0.96,1,1,1;
     1,1,1,1,1,1,1,1,0.87,1,1;
     1,1,1,1,1,1,1,1,1,0.87,1;
     1,1,1,1,1,1,1,1,1,1,1;
     1,1,1,1,1,1,1,1,1,1,1;
     1,1,1,1,1,1,1,1,1,1,1;
     ];

% downstream efficiency matrix
Aircraft.Specs.Propulsion.PropArch.EtaDwn = ...
    [1,1,1,1,1,1,1,1,1,1,1;
     1,1,1,1,1,1,1,1,1,1,1;
     1,1,1,1,1,1,1,1,1,1,1;
     1,1,0.96,1,1,1,1,1,1,1,1;
     1,1,1,1,1,1,1,1,1,1,1;
     1,1,1,1,1,1,1,1,1,1,1;
     1,1,1,0.96,0.96,1,1,1,1,1,1;
     1,1,1,0.96,1,0.96,1,1,1,1,1;
     1,1,1,1,1,1,0.87,1,1,1,1;
     1,1,1,1,1,1,1,0.87,1,1,1;
     1,1,1,1,1,1,1,1,1,1,1;
     ]; 

% source type (1 = fuel, 0 = battery)
Aircraft.Specs.Propulsion.PropArch.SrcType = [1,0];

% transmitter type (1 = engine, 0 = electric motor, 2 = propeller/fan, 3 = electric generator, 4 = cable)
Aircraft.Specs.Propulsion.PropArch.TrnType = [1,3,4,4,0,0,2,2];

% get the engine
Aircraft.Specs.Propulsion.Engine = EngineModelPkg.EngineSpecsPkg.AE2100_D3;

% number of engines
Aircraft.Specs.Propulsion.NumEngines = 1;

% engine propulsive efficiency
Aircraft.Specs.Propulsion.Eta.Prop = 0.8;


%% POWER %%
%%%%%%%%%%%

% gravimetric specific energy of combustible fuel (kWh/kg)
Aircraft.Specs.Power.SpecEnergy.Fuel = 11.9;

% gravimetric specific energy of battery (kWh/kg), not used here
Aircraft.Specs.Power.SpecEnergy.Batt = 0.36;

% downstream power splits
Aircraft.Specs.Power.LamDwn.SLS = 0.08;
Aircraft.Specs.Power.LamDwn.Tko = 0.08;
Aircraft.Specs.Power.LamDwn.Clb = 0.02;
Aircraft.Specs.Power.LamDwn.Crs = 0;
Aircraft.Specs.Power.LamDwn.Des = 0;
Aircraft.Specs.Power.LamDwn.Lnd = 0;

% upstream power splits
Aircraft.Specs.Power.LamUps.SLS = 1;
Aircraft.Specs.Power.LamUps.Tko = 1;
Aircraft.Specs.Power.LamUps.Clb = 1;
Aircraft.Specs.Power.LamUps.Crs = 0;
Aircraft.Specs.Power.LamUps.Des = 0;
Aircraft.Specs.Power.LamUps.Lnd = 0;

% electric motor and generator efficiencies, not used here just in HEA one
Aircraft.Specs.Power.Eta.EM = 0.96;
Aircraft.Specs.Power.Eta.EG = 0.96;

% propeller efficiency
Aircraft.Specs.Power.Eta.Propeller = 0.87;

% power-weight ratio for the aircraft (kW/kg, if a turboprop)
Aircraft.Specs.Power.P_W.SLS = 0.15;

% power-weight ratio for the electric motor and generator (kW/kg)
% leave as NaN if an electric motor or generator isn't in the powertrain
Aircraft.Specs.Power.P_W.EM = 5;
Aircraft.Specs.Power.P_W.EG = 5;

% battery cells in series and parallel
Aircraft.Specs.Power.Battery.ParCells = 100; % 100;
Aircraft.Specs.Power.Battery.SerCells = 59; % 62;

% initial battery SOC (commented value used for electrified aircraft)
Aircraft.Specs.Power.Battery.BegSOC = 100; % 100;

% nominal cell voltage [V]
Aircraft.Specs.Battery.NomVolCell = 3.6;

% maxinum extracted voltage [V]
Aircraft.Specs.Battery.MaxExtVolCell = 4.0880;

% maxinum cell capacity [Ah]
Aircraft.Specs.Battery.CapCell = 3;

% internal resistance [Ohm]
Aircraft.Specs.Battery.IntResist = 0.0199;

% exponential voltage [V]
Aircraft.Specs.Battery.ExpVol = 0.0986;

% exponential capacity [(Ah)^-1]
Aircraft.Specs.Battery.ExpCap = 30;

% acceptable SOC threshold
Aircraft.Specs.Battery.MinSOC = 20;

% intitial SOC
Aircraft.Specs.Battery.BegSOC = 100;

% acceptable max c-rate during discharging
Aircraft.Specs.Battery.MaxAllowCRate = 5;

% charging rate 
Aircraft.Specs.Battery.Charging = 500*1000;


%% SETTINGS (LEAVE AS NaN FOR DEFAULTS) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% number of control points in each segment
Aircraft.Settings.TkoPoints = NaN;
Aircraft.Settings.ClbPoints = NaN;
Aircraft.Settings.CrsPoints = NaN;
Aircraft.Settings.DesPoints = NaN;

% maximum number of iterations during oew estimation
Aircraft.Settings.OEW.MaxIter = 50;

% oew relative tolerance for convergence
Aircraft.Settings.OEW.Tol = 1e-12;

% maximum number of iterations during aircraft sizing
Aircraft.Settings.Analysis.MaxIter = 30;

% analysis type, either:
%     +1 for on -design mode (aircraft performance and sizing)
%     -1 for off-design mode (aircraft performance           )
Aircraft.Settings.Analysis.Type = +1;

% plotting, either:
%     1 for plotting on
%     0 for plotting off
Aircraft.Settings.Plotting = 1;

% make a tble of mission history
%     1 for make table
%     0 for no table
Aircraft.Settings.Table = 1;

% ----------------------------------------------------------

end