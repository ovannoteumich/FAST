
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

% Add an extra for testing
HeatGroups(end+1) = 3;

% Turn heatgroups into strings
items = num2str(1:length(HeatGroups));
items = items(items~= ' ');
items = num2cell(items);

% Find all combos of the loops
LoopsUnordered = ThermalPkg.Partitions(items);


SinklessArches = ThermalPkg.BuildUpStreams(LoopsUnordered,zeros(length(HeatGroups)))

Key = ["Batt","Mot","RezPump","AmbPump","Rez","Amb"]'


%  always using upstream matrix






% end

