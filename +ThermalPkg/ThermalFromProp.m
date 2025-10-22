function [Arches] = ThermalFromProp(NoHeatGroups)


% % need to move props so they dont coincide with sources
% % shift by 2
% PropTrnType = PropTrnType + 2;
% 
% % 0 is batt, 2 is motor, 5 is generator
% HeatSrc = [PropSrcType(PropSrcType == 0); PropTrnType(PropTrnType == 2); PropTrnType(PropTrnType == 5)];
% 
% % Group by type
% HeatGroups = unique(HeatSrc);

% Add extra(s) for testing
% HeatGroups(end+1) = 3;
% HeatGroups(end+1) = 4;
% HeatGroups(end+1) = 5;
% HeatGroups(end+1) = 6;

% Turn heatgroups into strings
items = num2str(1:NoHeatGroups);
items = items(items~= ' ');
items = num2cell(items);

% Find all combos of the loops
LoopsUnordered = ThermalPkg.Partitions(items);

% Generate basic loop architectures (no heatsinks or pumps yet)
SinklessArches = ThermalPkg.OrderComponents(LoopsUnordered,zeros(NoHeatGroups));

% Attach sinks and pumps to the architectures
Arches = ThermalPkg.AttachSinks(SinklessArches);

Archnames = fieldnames(Arches);

% Label all the architectures with the component key
for ii = 1:length(Archnames)
    Arches.(Archnames{ii}) = ThermalPkg.LabelArch(Arches.(Archnames{ii}));
end

end

