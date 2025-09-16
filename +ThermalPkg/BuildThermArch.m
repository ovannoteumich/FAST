% function [] = BuildThermArch()
clear;clc;
% Inputs


% would pull these from FAST
% Simple PHE from Paul's Paper; hardcoded for testing
PropSrcType = [1; 0];
PropTrnType = [1; 0; 2];
PropTrnType = PropTrnType + 2;



% 0 is batt, 2 is motor, 5 is generator
HeatSrc = [PropSrcType(PropSrcType == 0); PropTrnType(PropTrnType == 2); PropTrnType(PropTrnType == 5)];

% Group by type
HeatGroups = unique(HeatSrc);

% always 2 sinks, internal reservoir and ambient, and each can have a pump
UpStreamStem = zeros(length(HeatGroups) + 2 + 2);
UpStreamStem(end-3 ,end-1) = 1; % Connect Sink to its pump
UpStreamStem(end-2 ,end) = 1; % Connect Sink to its pump


items = num2str(1:length(HeatGroups));
items = items(items~= ' ');
items = num2cell(items);
LoopsUnordered = ThermalPkg.Partitions(items);


UpStreamStruct = ThermalPkg.BuildUpStreams(LoopsUnordered,UpStreamStem)

Key = ["Batt","Mot","RezPump","AmbPump","Rez","Amb"]'


%  always using upstream matrix






% end

