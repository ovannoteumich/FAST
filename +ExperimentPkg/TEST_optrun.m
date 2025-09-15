function [Aircraft] = TEST_optrun(Aircraft)
%

% gravimetric specific energy of battery (kWh/kg), not used here
Aircraft.Specs.Power.SpecEnergy.Batt = .25;

% battery cells in series and parallel 
Aircraft.Specs.Power.Battery.ParCells = 100;
Aircraft.Specs.Power.Battery.SerCells = 62;

% initial battery SOC
Aircraft.Specs.Power.Battery.BegSOC = 100;

%%
%{
Aircraft.Specs.Power.LamUps = [];
Aircraft.Specs.Power.LamDwn = [];
% upstream power splits
Aircraft.Specs.Power.LamUps.SLS = 1;
Aircraft.Specs.Power.LamUps.Tko = 0;
Aircraft.Specs.Power.LamUps.Clb = .9;
Aircraft.Specs.Power.LamUps.Crs = 0;
Aircraft.Specs.Power.LamUps.Des = 0;
Aircraft.Specs.Power.LamUps.Lnd = 0;

% downstream power splits
Aircraft.Specs.Power.LamDwn.SLS = .15;
Aircraft.Specs.Power.LamDwn.Tko = 0;
Aircraft.Specs.Power.LamDwn.Clb = .15;
Aircraft.Specs.Power.LamDwn.Crs = 0;
Aircraft.Specs.Power.LamDwn.Des = 0;
Aircraft.Specs.Power.LamDwn.Lnd = 0;
Aircraft.Specs.Weight.Batt = 3e3;
%}
pts = [10:27,37:45,55:63];
load('PC.mat')
    Aircraft.Specs.Power.LamUps.Miss(pts, [1,3]) = PC;
    Aircraft.Specs.Power.LamUps.Miss(pts, [2,4]) = PC;
% settings
Aircraft.Settings.PowerStrat = 1;
Aircraft.Settings.PowerOpt = 1;
Aircraft.Settings.Analysis.Type = -2;
Aircraft.Settings.PrintOut = 1;
% -1 = prioritize downstream, go from fan back to energy sources

Aircraft = Main(Aircraft, @MissionProfilesPkg.A320);
%end

end