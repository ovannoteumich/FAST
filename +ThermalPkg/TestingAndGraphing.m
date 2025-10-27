clear;clc; close all

% Set a propulsion architecture
% 0 is battery, 1 is fuel
PropArch.SrcType = [0 1];
% 0 is EM, 1 is eng, 2 is prop, 3 is generator
PropArch.TrnType = [0 0 2 2 3];

% Create Thermal Architectures from propulsive
[ArchCells] = ThermalPkg.ThermalFromProp(PropArch);

% Test a chosen architecture
testno = 151;
ThermalSystem = ArchCells.("Arch_" + testno);

% Assign a Working Fluid to each loop
load('+ThermalPkg\+MaterialsPkg\Material_DB.mat')

...

% Visualize our current architecture
ThermalPkg.DigraphThermal(ThermalSystem)

% Temp settings, design variables or from environments
ThermalSystem.TemperatureSettings.FuelPumpReturn = 321;
ThermalSystem.TemperatureSettings.FuelPumpSink = 450;
ThermalSystem.TemperatureSettings.AmbientPumpReturn = 300;
ThermalSystem.TemperatureSettings.AmbientPumpSink = 600;
ThermalSystem.TemperatureSettings.Fuel = 250;
ThermalSystem.TemperatureSettings.Ambient = 220;

% Run the thermal analysis
ThermalSystem = ThermalPkg.ThermalAnalysis(ThermalSystem);

% Look at temp table
NiceTable = ThermalSystem.Analysis.Labeled;
NiceTable %#ok<NOPTS> 


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







