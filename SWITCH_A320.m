%function [Aircraft] = SWITCH_A320()
%
% 

Aircraft = AircraftSpecsPkg.A320Neo;
Aircraft.Specs.Propulsion.PropArch.Type = "PHE";

% gravimetric specific energy of battery (kWh/kg), not used here
Aircraft.Specs.Power.SpecEnergy.Batt = .25;

% battery cells in series and parallel 
Aircraft.Specs.Power.Battery.ParCells = 100;
Aircraft.Specs.Power.Battery.SerCells = 62;

% initial battery SOC
Aircraft.Specs.Power.Battery.BegSOC = 100;

Aircraft = Main(Aircraft, @MissionProfilesPkg.A320);
%Aircraft = ans;
Aircraft.Settings.Analysis.Type = -1;

Aircraft.Specs.Weight.EM = 200;

Aircraft.Specs.Power.P_W.EM = 10;

% upstream power splits
Aircraft.Specs.Power.LamUps.SLS = 0.0003;
Aircraft.Specs.Power.LamUps.Tko = 0.0003;
Aircraft.Specs.Power.LamUps.Clb = 0.0003;
Aircraft.Specs.Power.LamUps.Crs = 0;
Aircraft.Specs.Power.LamUps.Des = 0;
Aircraft.Specs.Power.LamUps.Lnd = 0;

% downstream power splits
Aircraft.Specs.Power.LamDwn.SLS = 0.0003;
Aircraft.Specs.Power.LamDwn.Tko = 0.0003;
Aircraft.Specs.Power.LamDwn.Clb = 0.0003;
Aircraft.Specs.Power.LamDwn.Crs = 0;
Aircraft.Specs.Power.LamDwn.Des = 0;
Aircraft.Specs.Power.LamDwn.Lnd = 0;

Aircraft = Main(Aircraft, @MissionProfilesPkg.A320);
%end