clear;clc; close all
% Inputs

% Generatre Architectures with 2 heat groups
NoHeatGroups = 2;
[Arches] = ThermalPkg.ThermalFromProp(NoHeatGroups);

% 1,20,17 are good architecture options for 2 heatGroups
testno = 1;
DigraphThermal(Arches,testno)
CurArch = cell2mat(Arches.("Arch_" + testno)(2:end,2:end));


% Temp settings, design variables or from environments
AmbTemp = 300;
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
global Temps
Temps = -ones(NComps,1);

% Set initial temperatures of components which receive coolant from after
% heat has been dumped
for ii = FirstInLoopInds

    % Call local function to do this for each source
    SnkInd = TraceUpstream(CurArch,ii);

    % Adjust index because the Tempsettings dont include non sink comps
    Temps(ii) = TempSettings(SnkInd - (NComps - 4));
end


% With temps initialized, we need to add temp changes in coolant according
% to architecture.

% Assign input temps to
for ii = FirstInLoopInds
    sendforward(ii,CurArch)
end


if CurArch(end-2,end)
    Temps(end) = AmbPSetting;
end

if CurArch(end-3,end-1)
    Temps(end-1) = RezPSetting;
end


Temps



function sendforward(ind,arch)
global Temps

SendingTo = find(arch(ind,:) == 1);
if isempty(SendingTo)
    return
end
Temps(SendingTo) = ThermalPkg.ToyHeatSource(Temps(ind), "l");
sendforward(SendingTo,arch)



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

figure(node)
Archnames = fieldnames(Arches);

% Digraph needs the binary arch index and the names of all the sources
graphout = digraph(cell2mat(Arches.(Archnames{node})(2:end,2:end)),Arches.(Archnames{node})(1,2:end));

% Plot the digraph
p = plot(graphout);
p.EdgeColor = [0.753, 0, 0]; % Guardsman Red
p.NodeColor = [0 0 0]; % Black Nodes
p.LineWidth = 1.2;

% Text formatting
p.MarkerSize = 6;                  % Larger node markers
p.NodeLabelColor = [0 0 0];        % Black text
title("Architecture " + node)
end







