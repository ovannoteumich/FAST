%% arch 1
clear; clc; close all;

% Custom architecture for simple trade study
PropArch.SrcType = [1];
% 0 is EM, 1 is eng, 2 is prop, 3 is generator
PropArch.TrnType = [0 0 2 2 3];

% Create Thermal Architectures from propulsive
[ArchCells] = ThermalPkg.ArchitecturePkg.ThermalFromProp(PropArch);

% Test a chosen architecture
testno = 7;
ThermalSystem = ArchCells.("Arch_" + testno);

% Visualize our current architecture
figure(1)

CustomNames = {'Heat Source 1';'Heat Source 2';'Heat Pump A';'Heat Pump B';'Sink A';'Sink B'};


simplegraph = digraph(ThermalSystem.Arch,CustomNames);

% Plot the digraph
p2 = plot(simplegraph);
p2.EdgeColor = [0, 0, 0]; % Corn
p2.NodeColor = [0 0 0]; % Black Nodes
p2.LineWidth = 1.2;

% Text formatting
p2.MarkerSize = 6;                  % Larger node markers
p2.NodeLabelColor = [0 0 0];        % Black text
hold on
ax = gca;
ax.FontName = 'times';
ax.Visible = 'off';

%% arch 2
clear; clc; close all;

% Custom architecture for simple trade study
PropArch.SrcType = [1];
% 0 is EM, 1 is eng, 2 is prop, 3 is generator
PropArch.TrnType = [0 0 2 2 3];

% Create Thermal Architectures from propulsive
[ArchCells] = ThermalPkg.ArchitecturePkg.ThermalFromProp(PropArch);

% Test a chosen architecture
testno = 13;
ThermalSystem = ArchCells.("Arch_" + testno);

% Visualize our current architecture
figure(2)
CustomNames = {'Heat Source 1';'Heat Source 2';'Heat Pump A';'Heat Pump B';'Sink A';'Sink B'};


simplegraph = digraph(ThermalSystem.Arch,CustomNames);

% Plot the digraph
p2 = plot(simplegraph);
p2.EdgeColor = [0, 0, 0]; % Corn
p2.NodeColor = [0 0 0]; % Black Nodes
p2.LineWidth = 1.2;

% Text formatting
p2.MarkerSize = 6;                  % Larger node markers
p2.NodeLabelColor = [0 0 0];        % Black text
hold on
ax = gca;
ax.FontName = 'times';
ax.Visible = 'off';




