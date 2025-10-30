clear;clc; close all

% Set a propulsion architecture
% 0 is battery, 1 is fuel
PropArch.SrcType = [1];
% 0 is EM, 1 is eng, 2 is prop, 3 is generator
PropArch.TrnType = [0 0 2 2 3];

% Create Thermal Architectures from propulsive
[ArchCells] = ThermalPkg.ArchitecturePkg.ThermalFromProp(PropArch);

% Test a chosen architecture
testno = 22;
ThermalSystem = ArchCells.("Arch_" + testno);

% Visualize our current architecture
ThermalPkg.DigraphThermal(ThermalSystem)

% Assign a Working Fluid to each loop
load('+ThermalPkg\+MaterialsPkg\Material_DB.mat')
ThermalSystem.WorkingFluid = FluidProperties.EthyleneGlycol_30;


% Pull In from propulsion system (need this or a specified heat generation)
ThermalSystem.Propulsion.MaxPower = ...
    1e6 * ones(length(ThermalSystem.CompNames),1); % Fake numbers for now

ThermalSystem.Propulsion.Efficiency = ...
    0.96 * ones(length(ThermalSystem.CompNames),1); % Fake numbers for now




% Temp settings, design variables or from environments
ThermalSystem.Settings.Coolant.FuelPumpReturn = 200;
ThermalSystem.Settings.Coolant.FuelPumpSink = 500;
ThermalSystem.Settings.Coolant.AmbientPumpReturn = 150;
ThermalSystem.Settings.Coolant.AmbientPumpSink = 600;
ThermalSystem.Settings.Coolant.Fuel = 250;
ThermalSystem.Settings.Coolant.Ambient = 220;

ThermalSystem.Settings.MaxTemperature.Battery = 40 + 273;
ThermalSystem.Settings.MaxTemperature.Motor = 120 + 273;
ThermalSystem.Settings.MaxTemperature.Generator = 95 + 273;



% Size the mass flow internal to the connections between the components
ThermalSystem = ThermalPkg.MassFlowSizing(ThermalSystem);




% Inspect some outputs
Mass = ThermalSystem.Loops.MassFlow

Tab = ThermalSystem.Analysis.Labeled


%% Show growth with a semi-logarithmic graph
clear; close all; clc;

NoHeatGroups = 1:1:2; % to 6 normally
archcount = zeros(size(NoHeatGroups));

for ii = NoHeatGroups
    [ArchCells] = ThermalPkg.ThermalFromProp(NoHeatGroups(ii));
    archcount(ii) = length(fieldnames(ArchCells));
end

figure
semilogy(NoHeatGroups,archcount,'b')
hold on
scatter(NoHeatGroups,archcount,'b','filled')
grid on

xlabel('Number of Heat Producing Groups')
ylabel('Number of Candidate TMS Architectures')







