
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

% Add extra(s) for testing
HeatGroups(end+1) = 3;
% HeatGroups(end+1) = 4;
% HeatGroups(end+1) = 5;

% Turn heatgroups into strings
items = num2str(1:length(HeatGroups));
items = items(items~= ' ');
items = num2cell(items);

% Find all combos of the loops
LoopsUnordered = ThermalPkg.Partitions(items);


SinklessArches = ThermalPkg.OrderComponents(LoopsUnordered,zeros(length(HeatGroups)));

Arches = ThermalPkg.AttachSinks(SinklessArches);


LabelArch(Arches.Arch_3)

function [LabeledArch] = LabelArch(Arch)

Key = [];

for ii = 1:size(Arch,1)-4

    Key = [Key, "SRC " + ii];

end

Key = cellstr([Key, ["RezPump","AmbPump","Rez","Amb"]]);

LabeledArch = cell(size(Arch) + [1 1]);

LabeledArch(1,1) = {"Component"};

LabeledArch(2:end,1) = Key';
LabeledArch(1,2:end) = Key;

LabeledArch(2:end,2:end) = num2cell(Arch);


end








