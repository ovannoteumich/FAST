clear;clc; close all

% Generatre Architectures with some heat groups
NoHeatGroups = 3;
[ArchCells] = ThermalPkg.ThermalFromProp(NoHeatGroups);

% Test a Current point, extract component names and the arch matrix
testno = 150;
ThermalSystem.Arch = cell2mat(ArchCells.("Arch_" + testno)(2:end,2:end));
ThermalSystem.CompNames = ArchCells.("Arch_" + testno)(2:end,1);

% Visualize our current architecture
ThermalPkg.DigraphThermal(ThermalSystem)

% Temp settings, design variables or from environments
ThermalSystem.ReservoirPumpReturnSetting = 321;
ThermalSystem.ReservoirPumpSinkSetting = 450;
ThermalSystem.AmbientPumpReturnSetting = 300;
ThermalSystem.AmbientPumpSinkSetting = 600;
ThermalSystem.ReservoirSetting = 250;
ThermalSystem.AmbientSetting = 220;

% Run the thermal analysis
ThermalOut = ThermalPkg.ThermalAnalysis(ThermalSystem);

% Look at temp table
NiceTable = ThermalOut.Labeled;


%% Show growth
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







