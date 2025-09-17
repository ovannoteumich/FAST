%function [Aircraft] = SWITCH_A320()
%
% 

%% test one-switch on design mission

Aircraft = AircraftSpecsPkg.A320Neo;
Aircraft.Specs.Propulsion.PropArch.Type = "PHE";
Aircraft.Specs.Propulsion.PropArch.TrnType = [];
Aircraft.Settings.PowerStrat = -1;

% gravimetric specific energy of battery (kWh/kg), not used here
Aircraft.Specs.Power.SpecEnergy.Batt = .5;
Aircraft.Settings.PowerOpt = 0;

% battery cells in series and parallel 
Aircraft.Specs.Power.Battery.ParCells = 100;
Aircraft.Specs.Power.Battery.SerCells = 62;

% initial battery SOC
Aircraft.Specs.Power.Battery.BegSOC = 100;

AircraftOG = Main(Aircraft, @MissionProfilesPkg.A320);

%% test 2 

Aircraft2 = AircraftOG;
Aircraft2.Specs.Performance.Range = UnitConversionPkg.ConvLength(800, "naut mi", "m");
Aircraft2.Settings.Analysis.Type = -1;
Aircraft2 = Main(Aircraft2, @MissionProfilesPkg.A320);

%%

Aircraft = Aircraft2;
%Aircraft = ans;
Aircraft.Specs.Performance.Range = UnitConversionPkg.ConvLength(800, "naut mi", "m");
Aircraft.Settings.Analysis.Type = -1;

Aircraft.Specs.Weight.EM = 400;

Aircraft.Specs.Power.P_W.EM = 10;

Aircraft.Specs.Propulsion.SLSPower(:,[3,4]) = [200,200]*10*1000; % EM weight x spec pow x watt/kw
Aircraft.Specs.Propulsion.SLSThrust(:,[3,4]) = Aircraft.Specs.Propulsion.SLSPower(:,[3,4])/Aircraft.Specs.Performance.Vels.Tko;

Aircraft.Specs.Power.LamUps = [];
Aircraft.Specs.Power.LamDwn = [];
% upstream power splits
Aircraft.Specs.Power.LamUps.SLS = 1;
Aircraft.Specs.Power.LamUps.Tko = 0;
Aircraft.Specs.Power.LamUps.Clb = 1;
Aircraft.Specs.Power.LamUps.Crs = 0;
Aircraft.Specs.Power.LamUps.Des = 0;
Aircraft.Specs.Power.LamUps.Lnd = 0;

% downstream power splits
Aircraft.Specs.Power.LamDwn.SLS = .08;
Aircraft.Specs.Power.LamDwn.Tko = .0;
Aircraft.Specs.Power.LamDwn.Clb = .08;
Aircraft.Specs.Power.LamDwn.Crs = 0;
Aircraft.Specs.Power.LamDwn.Des = 0;
Aircraft.Specs.Power.LamDwn.Lnd = 0;

% settings
Aircraft.Settings.PowerStrat = -1;
Aircraft.Settings.PowerOpt = 0;
% -1 = prioritize downstream, go from fan back to energy sources

Aircraft = Main(Aircraft, @MissionProfilesPkg.A320);
%end


%% test 2 

%{
Aircraft.Specs.Performance.Range = UnitConversionPkg.ConvLength(800, "naut mi", "m");
Aircraft.Settings.Analysis.Type = -1;
Aircraft.Settings.PowerStrat = 1;
Aircraft.Settings.PowerOpt = 0;
pc = zeros(10,2);
pcc = .8*ones(9,2);
Aircraft.Specs.Power.LamUps.Miss(10:end, [3,4])=0;
Aircraft.Specs.Power.LamUps.Miss(10:28, [3,4]) = [pc;pcc];
Aircraft_Ups = Main(Aircraft, @MissionProfilesPkg.A320);
%}