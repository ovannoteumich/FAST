clear; clc; close all;

%% Arch 1 and 2
Settings.Coolant.FuelPumpReturn = 200;
Settings.Coolant.FuelPumpSink = 273 + 150;
Settings.Coolant.AmbientPumpReturn = 273 - 10;
Settings.Coolant.AmbientPumpSink = 273 + 140;
Settings.Coolant.Fuel = 250;
Settings.Coolant.Ambient = 273 - 10;

ThermalSystem.Settings = Settings;

load('+ThermalPkg\+MaterialsPkg\Material_DB.mat')
ThermalSystem.WorkingFluid = FluidProperties.EthyleneGlycol_30;

ThermalSystem.Arch =  [
        0,	0,	0,	1,	0,	0
        0,	0,	0,	0,	1,	0
        0,	0,	0,	0,	0,	0
        0,	0,	0,	0,	0,	1
        0,	0,	0,	0,	0,	0
        0,	0,	0,	0,	0,	0
        ];

ThermalSystem.Loops.LoopIDs =  [
        0,	0,	0,	1,	0,	0
        0,	0,	0,	0,	2,	0
        0,	0,	0,	0,	0,	0
        0,	0,	0,	0,	0,	3
        0,	0,	0,	0,	0,	0
        0,	0,	0,	0,	0,	0
        ];

ThermalSystem.Loops.NumLoops = 3;

ThermalSystem.CompNames = {'Motor','Motor2','C','D','E','F'};

ThermalSystem.Loops.MassFlow = [2, 4, 6];

ThermalSystem.Propulsion.Efficiency = ...
    0 * ones(length(ThermalSystem.CompNames),1); % Fake numbers for now
ThermalSystem.Propulsion.Efficiency = ...
    0 * ones(length(ThermalSystem.CompNames),1); % Fake numbers for now


ThermalSystem.Propulsion.MaxPower = [1e6 1e4];
ThermalSystem.Settings.MaxTemperature.Motor = 100;


ThermalSystem = ThermalPkg.ThermalAnalysis(ThermalSystem);

% ThermalSystem.Analysis.TempsOut


%% Complex Arch (Leviathan)
clear; clc; close all;


ThermalSystem.Arch =[
        0,	1,	0,	0,	0,	0, 0, 0, 0, 0, 0, 0, 0
        0,	0,	1,	0,	0,	0, 0, 0, 0, 0, 0, 0, 0
        0,	0,	0,	0,	0,	0, 0, 0, 0, 0, 1, 0, 0
        0,	0,	0,	0,	1,	0, 0, 0, 0, 0, 0, 0, 0
        0,	0,	0,	0,	0,	0, 0, 0, 0, 0, 1, 0, 0
        0,	0,	0,	0,	0,	0, 1, 0, 0, 0, 0, 0, 0
        0,	0,	0,	0,	0,	0, 0, 1, 0, 0, 0, 0, 0
        0,	0,	0,	0,	0,	0, 0, 0, 1, 0, 0, 0, 0
        0,	0,	0,	0,	0,	0, 0, 0, 0, 1, 0, 0, 0
        0,	0,	0,	0,	0,	0, 0, 0, 0, 0, 0, 1, 0
        0,	0,	0,	0,	0,	0, 0, 0, 0, 0, 0, 0, 1
        0,	0,	0,	0,	0,	0, 0, 0, 0, 0, 0, 0, 0
        0,	0,	0,	0,	0,	0, 0, 0, 0, 0, 0, 0, 0
        ];


ThermalSystem.Loops.LoopIDs =  [
        0,	1,	0,	0,	0,	0, 0, 0, 0, 0, 0, 0, 0
        0,	0,	1,	0,	0,	0, 0, 0, 0, 0, 0, 0, 0
        0,	0,	0,	0,	0,	0, 0, 0, 0, 0, 1, 0, 0
        0,	0,	0,	0,	2,	0, 0, 0, 0, 0, 0, 0, 0
        0,	0,	0,	0,	0,	0, 0, 0, 0, 0, 2, 0, 0
        0,	0,	0,	0,	0,	0, 3, 0, 0, 0, 0, 0, 0
        0,	0,	0,	0,	0,	0, 0, 3, 0, 0, 0, 0, 0
        0,	0,	0,	0,	0,	0, 0, 0, 3, 0, 0, 0, 0
        0,	0,	0,	0,	0,	0, 0, 0, 0, 3, 0, 0, 0
        0,	0,	0,	0,	0,	0, 0, 0, 0, 0, 0, 4, 0
        0,	0,	0,	0,	0,	0, 0, 0, 0, 0, 0, 0, 5
        0,	0,	0,	0,	0,	0, 0, 0, 0, 0, 0, 0, 0
        0,	0,	0,	0,	0,	0, 0, 0, 0, 0, 0, 0, 0
        ];

ThermalSystem.Loops.MassFlow = [2, 4, 6, 8 ,10];

ThermalSystem.Propulsion.MaxPower = [2e6, 1e6, 1e6, 2e6, 5e5, 6e5, 7e5, 8e5, 9e5];


Settings.Coolant.FuelPumpReturn = 200;
Settings.Coolant.FuelPumpSink = 273 + 150;
Settings.Coolant.AmbientPumpReturn = 273 - 40;
Settings.Coolant.AmbientPumpSink = 273 + 140;
Settings.Coolant.Fuel = 250;
Settings.Coolant.Ambient = 273 - 10;

ThermalSystem.Settings = Settings;

load('+ThermalPkg\+MaterialsPkg\Material_DB.mat')
ThermalSystem.WorkingFluid = FluidProperties.EthyleneGlycol_30;

ThermalSystem.Settings.MaxTemperature.Motor = 100;

ThermalSystem.CompNames = {'Motor','Motor2','Motor3','Motor4','Motor5','Motor6','Motor7','Motor8','Motor9','C','D','E','F'};


ThermalSystem.Propulsion.Efficiency = ...
    0 * ones(length(ThermalSystem.CompNames),1); % Fake numbers for now
ThermalSystem.Propulsion.Efficiency = ...
    0 * ones(length(ThermalSystem.CompNames),1); % Fake numbers for now

ThermalSystem.Loops.NumLoops = 5;


ThermalSystem = ThermalPkg.ThermalAnalysis(ThermalSystem);














