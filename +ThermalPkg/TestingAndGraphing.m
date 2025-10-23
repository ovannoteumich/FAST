clear;clc; close all
% Inputs

% Generatre Architectures with 2 heat groups
NoHeatGroups = 4;
[Arches] = ThermalPkg.ThermalFromProp(NoHeatGroups);

% 1,20,17 are good architecture options for 2 heatGroups
testno = 150;
CurArch = cell2mat(Arches.("Arch_" + testno)(2:end,2:end));


% Temp settings, design variables or from environments
AmbTemp = 160;
RezTemp = 150;
RezPSetting = 250; % temp pump cools to
AmbPSetting = 200; %temp pump cools to
TempSettings = [RezPSetting AmbPSetting RezTemp AmbTemp]';

% Find which srcs are connected to what temps to give inlet temps
CompSums = sum(CurArch);
NComps = length(CompSums);

% Initialize components which are first in the loops by the temp of their
% destination
FirstInLoopInds = find(CompSums(1:NComps-4) == 0);
global TempsIn TempsOut MassesIn MassesOut
TempsIn = -ones(NComps,1);
TempsOut = -ones(NComps,1);

% Set input temperatures of components which receive coolant from after
% heat has been dumped
for ii = FirstInLoopInds

    % Call local function to do this for each source
    SnkInd = TraceUpstream(CurArch,ii);

    % Adjust index because the Tempsettings dont include non sink comps
    TempsIn(ii) = TempSettings(SnkInd - (NComps - 4));
end


% If there is an ambient sink, set temp out to the ambient temperature
if any(CurArch(:,end))
    TempsOut(end) = AmbTemp;
end

% If there is a reservoir sink, set temp out to the reservoir temperature
if any(CurArch(:,end-1))
    TempsOut(end-1) = RezTemp;
end

% If there is an ambient pump, set pump output and ambient input
if CurArch(end-2,end)
    TempsIn(end) = AmbPSetting;
    TempsOut(end-2) = AmbPSetting;
end

% Set input to reservoir as the reservoir pump setting
if CurArch(end-3,end-1)
    TempsIn(end-1) = RezPSetting;
    TempsOut(end-3) = RezPSetting;
end

% Assign unknown temps
for ii = NComps-1:NComps
    sendbackward(ii,CurArch)
end





graphinds = randi(length(fieldnames(Arches)),[1,4]);

for ii = graphinds(:)'
    DigraphThermal(Arches,ii)
end

% DigraphThermal(Arches,testno)
TempsIn
TempsOut

% --------------------------------------------------------------
%% FUNCTIONS
% --------------------------------------------------------------

% Sends power forward in the architecture
function sendforward(ind,arch)
% takes in a component index and an architecture

% read in the global state vector
global Temps

% Find where the connection sends the coolant to
SendingTo = find(arch(ind,:) == 1);

% if it doesnt send anywhere, return out of the function
if isempty(SendingTo)
    return
end

% otherwise, update the temperature matrix with the heat source
Temps(SendingTo) = ThermalPkg.ToyHeatSource(Temps(ind), "l");

% then continue sending the coolant onward
sendforward(SendingTo,arch)


end

function sendbackward(ind,arch)
% takes in a component index and an architecture

% read in the global state vector
global TempsIn TempsOut

% Find where the connection sends the coolant to
ReceivingFrom = find(arch(:,ind) == 1);

% if it doesnt send anywhere, return out of the function
if isempty(ReceivingFrom)
    TempsOut = ThermalPkg.ToyHeatSource(ind,TempsIn,TempsOut);
    return
end


for ii = ReceivingFrom(:)'
    % then continue sending the coolant onward
    sendbackward(ii,arch)
end



TempsIn(ind) = sum(TempsOut(ReceivingFrom))./length(ReceivingFrom);

TempsOut = ThermalPkg.ToyHeatSource(ind,TempsIn,TempsOut);




end


% This function finds which sink or pump temp each component should be
% initialized to by following the upstream matrix to the end
function [SettingInd] = TraceUpstream(Arch,SInd)

% Pull in arch size
NComp = size(Arch,1);

% This will trace the upstream connections
Tracer = zeros(NComp,1);

% Follow the index of interest
Tracer(SInd) = 1;

% Want to iterate for 1 more than the total number of components to ensure
% convergence
for ii = 1:NComp+1

    % Step forward, track the connection
    Tracer2 = (Arch')*Tracer;

    % Only update if the new value is greater than zero
    for jj = 1:NComp
        if Tracer2(jj) > 1e-5
            Tracer(jj) = Tracer2(jj);
        end
    end
end

% Only interested in final connections, get rid of sinks
Tracer(1:end-4) = 0;

% Find sinks that are in the path
SNKInds = find(Tracer == 1);

% Only interested in the first sink it encounters because thats the
% temperature the component will receive
SettingInd = SNKInds(1);

end


% This is a simple graphing function which makes a nice visual based on the
% architecture structure and an index or node.
function DigraphThermal(Arches,node)

% Set fig num to node num to mathc
fig = figure(node);
set(fig, 'Units', 'pixels', 'Position', [200, 200, 800, 600]);  % 800×600 pixels

% Read architecture names
Archnames = fieldnames(Arches);

% Extract component names and numerical values from cell array
CompNames = Arches.(Archnames{node})(1,2:end);
NumericalArch = cell2mat(Arches.(Archnames{node})(2:end,2:end));

% Extract Size
NComps = size(NumericalArch,1);

% Add reverse connections too
Up = NumericalArch;

% Initialize DownMatrix
Down = zeros(size(Up));

% Find where sinks should point back to sources
CompSums = sum(Up);
FirstInLoopInds = find(CompSums(1:NComps-4) == 0);

% Loop through and add those down connections
for ii = FirstInLoopInds(:)'
    SnkInd = TraceUpstream(Up,ii);
    Down(SnkInd,ii) = 1;
end

% Check Rez Pump Connections
if Up(end-3,end-1)
    Down(end-1,end-3) = 1;
end

% Check Amb Pump Connections
if Up(end-2,end)
    Down(end,end-2) = 1;
end


subplot(1,2,2)
% Digraph needs the binary arch index and the names of all the sources
graphout = digraph(Up + Down,CompNames);

% Plot the digraph
p = plot(graphout);
p.EdgeColor = [0.918, 0.722, 0]; % Corn
p.NodeColor = [0 0 0]; % Black Nodes
p.LineWidth = 1.2;

% Text formatting
p.MarkerSize = 6;                  % Larger node markers
p.NodeLabelColor = [0 0 0];        % Black text
title({"Architecture " + node,"With Cooling Flow"})
hold on

% Color Downstream connections blue for the cooling
for ii = 1:NComps
    for jj = 1:NComps
        if Down(ii,jj)
            highlight(p,ii,jj,'EdgeColor','b')
        end
    end
end

% Color Rez Pump Connections
if Up(end-3,end-1)
    highlight(p,NComps-3,NComps-1,'EdgeColor','r')
end

% Color Amb Pump Connections
if Up(end-2,end)
    highlight(p,NComps-2,NComps,'EdgeColor','r')
end


% Also show simplified version
subplot(1,2,1)
simplegraph = digraph(Up,CompNames);

% Plot the digraph
p2 = plot(simplegraph);
p2.EdgeColor = [0, 0, 0]; % Corn
p2.NodeColor = [0 0 0]; % Black Nodes
p2.LineWidth = 1.2;

% Text formatting
p2.MarkerSize = 6;                  % Larger node markers
p2.NodeLabelColor = [0 0 0];        % Black text
title({"Architecture " + node})
hold on


end







