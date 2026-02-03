%function [Aircraft] = SWITCH_A320()
%
% 
%% sizing battery is off fix that it allows the EM to be over its limits

%% size conventional aircraft on design mission

Aircraft = AircraftSpecsPkg.A320neo;
Aircraft.Settings.PowerStrat = -1;
Aircraft.Settings.PowerOpt = 0;
AircraftOG1 = Main(Aircraft, @MissionProfilesPkg.A320);

%% size convential arcraft as PHE with 0 EM and batt

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

%% test 4 
%{
Aircraft = AircraftOG;
Aircraft.Specs.Performance.Range = UnitConversionPkg.ConvLength(800, "naut mi", "m");
Aircraft.Settings.Analysis.Type = -1;

Aircraft.Specs.Power.LamUps = rmfield(Aircraft.Specs.Power.LamUps, 'Miss');
Aircraft.Specs.Power.LamDwn = rmfield(Aircraft.Specs.Power.LamDwn, 'Miss');
%Aircraft = Main(Aircraft, @MissionProfilesPkg.A320);
%}

%% test 2 

Aircraft2 = AircraftOG;
Aircraft2.Specs.Weight.Payload = Aircraft2.Specs.Weight.Payload + 500; %500 kh of reserve fuel
%Aircraft2 = DataStructPkg.InitMissionHistory(Aircraft2);
Aircraft2.Specs.Performance.Range = UnitConversionPkg.ConvLength(800, "naut mi", "m");
Aircraft2.Settings.Analysis.Type = -1;

Aircraft2.Specs.Power.LamUps = rmfield(Aircraft2.Specs.Power.LamUps, 'Miss');
Aircraft2.Specs.Power.LamDwn = rmfield(Aircraft2.Specs.Power.LamDwn, 'Miss');
Aircraft2 = Main(Aircraft2, @MissionProfilesPkg.NarrowBodyMission);

%%

Aircraft = Aircraft2;
%Aircraft = ans;
Aircraft.Specs.Performance.Range = UnitConversionPkg.ConvLength(800, "naut mi", "m");
Aircraft.Settings.Analysis.Type = -1;

Aircraft.Specs.Weight.EM = 400;
Aircraft.Specs.Weight.OEW = Aircraft.Specs.Weight.OEW + Aircraft.Specs.Weight.EM;


Aircraft.Specs.Power.P_W.EM = 10*1000; % specprocessng doesnt get called

Aircraft.Specs.Propulsion.SLSPower(:,[3,4]) = [200,200]*10*1000;
Aircraft.Specs.Propulsion.SLSPower(:,[5,6]) = Aircraft.Specs.Propulsion.SLSPower(:,[5,6]) + Aircraft.Specs.Propulsion.SLSPower(:,[3,4]).*.99;% add EM to SLS power
Aircraft.Specs.Propulsion.SLSThrust(:,[3,4]) = Aircraft.Specs.Propulsion.SLSPower(:,[3,4])/Aircraft.Specs.Performance.Vels.Tko;
Aircraft.Specs.Propulsion.SLSThrust(:,[5,6]) = Aircraft.Specs.Propulsion.SLSThrust(:,[5,6]) + Aircraft.Specs.Propulsion.SLSThrust(:,[3,4]);
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
Aircraft.Specs.Power.LamDwn.SLS = 0.02;
Aircraft.Specs.Power.LamDwn.Tko = 0;
Aircraft.Specs.Power.LamDwn.Clb = 0.02;
Aircraft.Specs.Power.LamDwn.Crs = 0;
Aircraft.Specs.Power.LamDwn.Des = 0;
Aircraft.Specs.Power.LamDwn.Lnd = 0;
%{
Npar = 200;
Nser = 62;
QMax = Aircraft.Specs.Battery.CapCell;
 VNom = Aircraft.Specs.Battery.NomVolCell;
ebatt = Aircraft.Specs.Power.SpecEnergy.Batt;
 Wbatt = QMax * Npar * VNom * Nser * 3600 ./ ebatt;
     Aircraft.Specs.Weight.Batt = Wbatt;
%}
    % remember the new cell arrangement
    %Aircraft.Specs.Power.Battery.ParCells = Npar;

% settings
Aircraft.Settings.PowerStrat = -1;
Aircraft.Settings.PowerOpt = 0;
% -1 = prioritize downstream, go from fan back to energy sources

Aircraft = Main(Aircraft, @MissionProfilesPkg.NarrowBodyMission);
%end
b = Aircraft.Mission.History.SI.Power.Pav - Aircraft.Mission.History.SI.Power.Pout;
pav = Aircraft.Mission.History.SI.Power.Pav;
pout = Aircraft.Mission.History.SI.Power.Pout;

%% no battery hybrid aircraft run

Aircraft = Aircraft2;
%Aircraft = ans;
Aircraft.Specs.Performance.Range = UnitConversionPkg.ConvLength(800, "naut mi", "m");
Aircraft.Settings.Analysis.Type = -1;

Aircraft.Specs.Weight.EM = 400;
Aircraft.Specs.Weight.OEW = Aircraft.Specs.Weight.OEW + Aircraft.Specs.Weight.EM;


Aircraft.Specs.Power.P_W.EM = 10*1000; % specprocessng doesnt get called

Aircraft.Specs.Propulsion.SLSPower(:,[3,4]) = [200,200]*10*1000;
Aircraft.Specs.Propulsion.SLSPower(:,[5,6]) = Aircraft.Specs.Propulsion.SLSPower(:,[5,6]) + Aircraft.Specs.Propulsion.SLSPower(:,[3,4]).*.99;% add EM to SLS power
Aircraft.Specs.Propulsion.SLSThrust(:,[3,4]) = Aircraft.Specs.Propulsion.SLSPower(:,[3,4])/Aircraft.Specs.Performance.Vels.Tko;
Aircraft.Specs.Propulsion.SLSThrust(:,[5,6]) = Aircraft.Specs.Propulsion.SLSThrust(:,[5,6]) + Aircraft.Specs.Propulsion.SLSThrust(:,[3,4]);
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
Aircraft.Specs.Power.LamDwn.SLS = 0.3;
Aircraft.Specs.Power.LamDwn.Tko = 0;
Aircraft.Specs.Power.LamDwn.Clb = 0.3;
Aircraft.Specs.Power.LamDwn.Crs = 0;
Aircraft.Specs.Power.LamDwn.Des = 0;
Aircraft.Specs.Power.LamDwn.Lnd = 0;


% settings
Aircraft.Settings.PowerStrat = -1;
Aircraft.Settings.PowerOpt = 0;
% -1 = prioritize downstream, go from fan back to energy sources

Aircraft_nobatt = Main(Aircraft, @MissionProfilesPkg.NarrowBodyMission);

%%
Aircraft.Settings.Analysis.Type = -2;

Aircraft22 = Main(Aircraft, @MissionProfilesPkg.NarrowBodyMission);

%% get lamups splits after sizing
Aircraft.Settings.PowerStrat = 1;
Aircraft = PropulsionPkg.RecomputeSplits(Aircraft, 1, 102);

%% Aircraft
Aircraft1 = Aircraft22;
n = 10;
fuel = zeros(n,1);
egt = linspace(0,50,n);
fuel(1) = Aircraft1.Specs.Weight.Fuel;
for i = 2:n
    sfcIn = (egt(i)-egt(i-1))/1000;
    Aircraft1.Specs.Propulsion.MDotCF = Aircraft1.Specs.Propulsion.MDotCF .* (1+sfcIn);
    Aircraft1 = Main(Aircraft1, @MissionProfilesPkg.NarrowBodyMission);
    fuel(i)=Aircraft1.Specs.Weight.Fuel;
end
figure;
plot(egt, fuel)
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

%%
figure;
plot(Aircraft.Mission.History.SI.Performance.Time/60/60, Aircraft.Mission.History.SI.Power.LamUps(:,1))
xlabel("Time (hr)")
ylabel("GT Throttle")
hold on
yyaxis right
plot(Aircraft.Mission.History.SI.Performance.Time/60/60, Aircraft.Mission.History.SI.Performance.Alt)
ylabel("Altitude (m)")

%% size ideal a320neo hea

Aircraft = AircraftSpecsPkg.A320neo;
Aircraft.Specs.Propulsion.PropArch.Type = "PHE";
Aircraft.Specs.Propulsion.PropArch.TrnType = [];
Aircraft.Settings.PowerStrat = -1;

% gravimetric specific energy of battery (kWh/kg), not used here
Aircraft.Specs.Power.SpecEnergy.Batt = .25;
Aircraft.Settings.PowerOpt = 0;

Aircraft.Specs.Power.LamUps.SLS = 1;
Aircraft.Specs.Power.LamUps.Tko = 1;
Aircraft.Specs.Power.LamUps.Clb = 1;
Aircraft.Specs.Power.LamUps.Crs = 0;
Aircraft.Specs.Power.LamUps.Des = 0;
Aircraft.Specs.Power.LamUps.Lnd = 0;

% downstream power splits
Aircraft.Specs.Power.LamDwn.SLS = 0.1;
Aircraft.Specs.Power.LamDwn.Tko = 0.1;
Aircraft.Specs.Power.LamDwn.Clb = 0.05;
Aircraft.Specs.Power.LamDwn.Crs = 0;
Aircraft.Specs.Power.LamDwn.Des = 0;
Aircraft.Specs.Power.LamDwn.Lnd = 0;


% settings
Aircraft.Settings.PowerStrat = -1;

% battery cells in series and parallel 
Aircraft.Specs.Power.Battery.ParCells = 100;
Aircraft.Specs.Power.Battery.SerCells = 62;

% initial battery SOC
Aircraft.Specs.Power.Battery.BegSOC = 100;



Aircraft_HEAideal = Main(Aircraft, @MissionProfilesPkg.A320);