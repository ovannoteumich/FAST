function [] = Engine_LCC()
%
% [] = Life_Cycle_COst(Preq, Time, SOCBeg, Parallel, Series)
% originally written by Emma Cassidy, emmasmit@umich.edu
% 
% last updated: 31 July 2025
%
% 
%
%

%% Life Cycle Overview %%
%%%%%%%%%%%%%%%%%%%%%%%%%

% aircraft life span (years)
span = 25;

% year into service
eis = 2025;

% aircraft base case
range = 800; %nmi
time = 2; %hrs

% MRO break down (Flight Equivalent Cycles)
SV1_FEC = 1e4; % intitial check, oiling, and repairs
SV2_FEC = 2e4; % full engine teardown, LLPs replacements

%% Engine Cost Values %%
%%%%%%%%%%%%%%%%%%%%%%%%

% initial aquisition cost
Initial_Cost = 12e6;

% flight energy costs
%JetFuelkwh_Cost = Aircraft.Specs.Cost.AvgFuel_kwh;
%Electkwh_Cost   = Aircraft.Specs.Cost.AvgFuel_kwh;

% energy inflation rate
r_JetFuel = 0.005;
r_Elect   = 0.039;

% base yar labor cost (per hour)
labor_cost = 170;

% labor cost increase rate (%)
r_labor = 0.027;


%% Initial Cost %%

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Flight Operating Cost %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% size legacy aircraft

Aircraft = AircraftSpecsPkg.A320neo;
Aircraft.Specs.Propulsion.PropArch.Type = "PHE";
Aircraft.Specs.Propulsion.PropArch.TrnType = [];
Aircraft.Settings.PowerStrat = -1;

% gravimetric specific energy of battery (kWh/kg), not used here
Aircraft.Specs.Power.SpecEnergy.Batt = .25;
Aircraft.Settings.PowerOpt = 0;

% battery cells in series and parallel 
Aircraft.Specs.Power.Battery.ParCells = 100;
Aircraft.Specs.Power.Battery.SerCells = 62;

% initial battery SOC
Aircraft.Specs.Power.Battery.BegSOC = 100;


AircraftOG = Main(Aircraft, @MissionProfilesPkg.A320);

%% fly legacy aircraft on performance mission

Aircraft2 = AircraftOG;
Aircraft2.Specs.Weight.Payload = Aircraft2.Specs.Weight.Payload + 500; %500 kh of reserve fuel

Aircraft2.Specs.Performance.Range = UnitConversionPkg.ConvLength(800, "naut mi", "m");
Aircraft2.Settings.Analysis.Type = -1;

Aircraft2.Specs.Power.LamUps = rmfield(Aircraft2.Specs.Power.LamUps, 'Miss');
Aircraft2.Specs.Power.LamDwn = rmfield(Aircraft2.Specs.Power.LamDwn, 'Miss');
Aircraft2 = Main(Aircraft2, @MissionProfilesPkg.NarrowBodyMission);

Aircraft2 = CostPkg.EnergyCost_perAirport(Aircraft2);

%% MRO Comparison

%% EGT Plots





end
