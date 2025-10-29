function [Arches] = ThermalFromProp(PropArch)

% Read in Transmitter and source types
Trns = PropArch.TrnType;
Srcs = PropArch.SrcType;

% need to move props so they dont coincide with sources
% shift by 2
Trns = Trns + 2;

% Extract batteries
SrcHeatSrcs = Srcs(Srcs == 0);

% 0 is batt, 2 is motor, 5 is generator
TrnHeatSrcs = [Trns(Trns == 2), Trns(Trns == 5)];

% Concatenate Group motors and generators, but keep all batteries
HeatGroupTypes = [SrcHeatSrcs,unique(TrnHeatSrcs)];
NumHeatGroups = length(HeatGroupTypes);

% Turn heatgroups into strings
items = num2str(1:NumHeatGroups);
items = items(items~= ' ');
items = num2cell(items);

% Find all combos of the loops
LoopsUnordered = ThermalPkg.Partitions(items);

% Generate basic loop architectures (no heatsinks or pumps yet)
SinklessArches = ThermalPkg.OrderComponents(LoopsUnordered,zeros(NumHeatGroups));

% Attach sinks and pumps to the architectures
Arches = ThermalPkg.AttachSinks(SinklessArches);

Archnames = fieldnames(Arches);

% Label all the architectures with the component key
for ii = 1:length(Archnames)
    Arches.(Archnames{ii}) = ThermalPkg.LabelArch(Arches.(Archnames{ii}),...
        HeatGroupTypes,PropArch);

    % Assign Loop numbers for each component
    Arches.(Archnames{ii}) = ThermalPkg.AssignLoopNumbers(Arches.(Archnames{ii}));

end


end

