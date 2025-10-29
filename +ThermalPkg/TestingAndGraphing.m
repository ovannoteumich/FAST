clear;clc; close all

% Set a propulsion architecture
% 0 is battery, 1 is fuel
PropArch.SrcType = [1];
% 0 is EM, 1 is eng, 2 is prop, 3 is generator
PropArch.TrnType = [0 0 2 2 3];

% Create Thermal Architectures from propulsive
[ArchCells] = ThermalPkg.ThermalFromProp(PropArch);

% Test a chosen architecture
testno = 13;
ThermalSystem = ArchCells.("Arch_" + testno);

% Visualize our current architecture
ThermalPkg.DigraphThermal(ThermalSystem)

% Assign a Working Fluid to each loop
load('+ThermalPkg\+MaterialsPkg\Material_DB.mat')
ThermalSystem.WorkingFluid = FluidProperties.EthyleneGlycol_30;


% Pull In from propulsion system
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
ThermalSystem.Settings.MaxTemperature.Motor = 96 + 273;
ThermalSystem.Settings.MaxTemperature.Generator = 95 + 273;









% Initialize Mass Flow to Something
ThermalSystem.Loops.MassFlow = ones(ThermalSystem.Loops.NumLoops,1);

% Set Thermal Tolerance
EPS06 = 1e-6;

% Assign Maximum Temperatures
ThermalSystem = ThermalPkg.AssignMaxTemps(ThermalSystem);

% Run an initial thermal analysis to start the loop
ThermalSystem = ThermalPkg.ThermalAnalysis(ThermalSystem);

% Do not size pump loops, gets done separately
NPumpLoops = sum(ThermalSystem.Arch(end-3:end-2,:),'all');

for jj = 1:ThermalSystem.Loops.NumLoops-NPumpLoops
    
    %  Reset large error each time
    Err = 1;

    while abs(Err) > EPS06

    % Components for the Coolant loop jj
    [Cols,~] = find(ThermalSystem.Loops.LoopIDs == jj);

    CurrentTemps = ThermalSystem.Analysis.TempsOut(Cols);
    MaxTemps = ThermalSystem.Analysis.MaxTemps(Cols);

    [LowestDiff,LDI] = min(MaxTemps - CurrentTemps);

    % Calculate Error
    Err = (LowestDiff)./MaxTemps(LDI);

    % Scale mass flow in the coolant loop we are interested in with a
    % simple fixed point scaling
    ThermalSystem.Loops.MassFlow(jj) = (1 - Err) * ThermalSystem.Loops.MassFlow(jj);
    
    % Rerun thermal analysis
    ThermalSystem = ThermalPkg.ThermalAnalysis(ThermalSystem);


    end

    

    

end

% By construction, the fuel heat pump gets added to the loop and then the
% ambient, so its easy to check which ones need to get sized afterward









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







