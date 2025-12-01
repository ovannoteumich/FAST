%% arch 1
clear; clc; close all;

% Custom architecture for simple trade study
PropArch.SrcType = [1];
% 0 is EM, 1 is eng, 2 is prop, 3 is generator
PropArch.TrnType = [0 0 2 2];

% Create Thermal Architectures from propulsive
[ArchCells] = ThermalPkg.ArchitecturePkg.ThermalFromProp(PropArch);

% Test a chosen architecture
testno = 4;
ThermalSystemP = ArchCells.("Arch_" + testno);

% Visualize our current architecture
figure(1)

CustomNames = {'Heat Source';'Heat Pump B';'Heat Pump A';'Sink B';'Sink A'};


simplegraph = digraph(ThermalSystemP.Arch,CustomNames);

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


% ---------------------------------------
% Active System Setup
% ---------------------------------------

% Custom architecture for simple trade study
PropArch.SrcType = [1];
% 0 is EM, 1 is eng, 2 is prop, 3 is generator
PropArch.TrnType = [0 0 2 2];

% Create Thermal Architectures from propulsive
[ArchCells] = ThermalPkg.ArchitecturePkg.ThermalFromProp(PropArch);

% Test a chosen architecture
testno = 2;
ThermalSystemA = ArchCells.("Arch_" + testno);

% Visualize our current architecture
figure(2)


simplegraph = digraph(ThermalSystemA.Arch,CustomNames);

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


% ---------------------------------------
% Trade Studies
% ---------------------------------------


load('+ThermalPkg\+MaterialsPkg\Material_DB.mat')
ThermalSystemP.WorkingFluid = FluidProperties.EthyleneGlycol_30;
ThermalSystemA.WorkingFluid = FluidProperties.EthyleneGlycol_30;


% Pull In from propulsion system (need this or a specified heat generation)

ThermalSystemP.Propulsion.Efficiency = ...
    0 * ones(length(ThermalSystemP.CompNames),1); % Fake numbers for now
ThermalSystemA.Propulsion.Efficiency = ...
    0 * ones(length(ThermalSystemP.CompNames),1); % Fake numbers for now




% Temp settings, design variables or from environments
Settings.Coolant.FuelPumpReturn = 200;
Settings.Coolant.FuelPumpSink = 273 + 150;
Settings.Coolant.AmbientPumpReturn = 273 - 10;
Settings.Coolant.AmbientPumpSink = 273 + 150;
Settings.Coolant.Fuel = 250;
Settings.Coolant.Ambient = 273 + 20;
Settings.MaxTemperature.Battery = 40 + 273;
Settings.MaxTemperature.Motor = 273 + 95;
Settings.MaxTemperature.Generator = 95 + 273;

ThermalSystemA.Settings = Settings;
ThermalSystemP.Settings = Settings;

powers = linspace(0.0001,1,2);

temps = -40:1:20;


for tt = 1:length(temps) 
passivemass = zeros(1,length(powers));
activemass = zeros(2,length(powers));


ThermalSystemA.Settings.Coolant.Ambient = 273 + temps(tt);
ThermalSystemP.Settings.Coolant.Ambient = 273 + temps(tt);

% Run loops to calculate for various powers
for ii = 1:length(powers)
    ThermalSystemP.Propulsion.MaxPower = ...
        powers(ii)*1e6 * ones(length(ThermalSystemP.CompNames),1); % Fake numbers for now
    % Size the mass flow internal to the connections between the components
    ThermalSystemP = ThermalPkg.MassFlowSizing(ThermalSystemP);
    passivemass(ii) = ThermalSystemP.Loops.MassFlow;

    ThermalSystemA.Propulsion.MaxPower = ...
        powers(ii) *1e6* ones(length(ThermalSystemA.CompNames),1); % Fake numbers for now
    % Size the mass flow internal to the connections between the components
    ThermalSystemA = ThermalPkg.MassFlowSizing(ThermalSystemA);
    activemass(:,ii) = ThermalSystemA.Loops.MassFlow;

end

passiveslope(tt) = (passivemass(end) - passivemass(1))/(powers(end) - powers(1));
activeslope1(tt) = (activemass(1,end) - activemass(1,1))/(powers(end) - powers(1));
activeslope2(tt) = (activemass(2,end) - activemass(2,1))/(powers(end) - powers(1));

end


% Inspect some outputs
% Mass = ThermalSystemP.Loops.MassFlow
RegalBlue      = [0,     0.251, 0.478]; % Darker Blue
Astral         = [0.180, 0.459, 0.714]; % Medium Blue
Cornflower     = [0.580, 0.745, 0.894]; % Light Blue
AlgaeGreen     = [0.475, 0.855, 0.624]; % Light Green
JungleGreen    = [0.169, 0.655, 0.459]; % Dark Green
GuardsmanRed   = [0.753, 0,     0    ]; % Red (Warm Accent)
Jaffa          = [0.930, 0.490, 0.192]; % Orange (Warm Accent)
Corn           = [0.918, 0.722, 0    ]; % Yellow (Warm Accent)
Midnight       = [0,     0.086, 0.165]; % Very Dark (Nearly Black) Blue
SilverChalice  = [0.686, 0.671, 0.671]; % Gray
BlueRibbon     = [0.086, 0.404, 0.945]; % Rich Blue (Cool Accent)
DodgerBlue     = [0.235, 0.553, 0.984]; % Medium Rich Blue (Cool Accent)
Malibu         = [0.365, 0.777, 0.996]; % Lighter Blue (Cool Accent)
AquaMarine     = [0.377, 0.980, 0.863]; % Cyan (Cool Accent)
ElectricViolet = [0.624, 0.067, 0.757]; % Purple (Cool Accent)


figure(3)
plot(temps,activeslope1,'linewidth',2,'color',RegalBlue)
hold on
plot(temps,activeslope2,'linewidth',2,'color',JungleGreen)
plot(temps,passiveslope,'linewidth',2,'color',GuardsmanRed)
grid on

ylabel({"Loop Mass Flow per Heat Production","(kg/s/MW)"})
xlabel("Sink Temperature (^\circC)")
legend('Active: Source-Pump','Active: Pump-Sink','Passive','location','northwest')

ax = gca;
ax.FontName = 'times';
ax.FontSize = 16;

set(gcf,'Position',[100 100 810 500])





