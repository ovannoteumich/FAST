function [ThermalSystem] = LabelArch(Arch,HeatSrcTypes,PropArch)
% Labels a thermal architecture into a cell array for easy tracking

% Instantiate Key
Key = [];

% Start Battery counter at 1
battcounter = 1;

% Build number of sources
for ii = 1:size(Arch,1)-4

    switch HeatSrcTypes(ii)
        case 0 % batt
            compname = "Batt " + battcounter;
            battcounter = battcounter + 1;
        case 2 % Mot
            compname = "Motor Group";
        case 5 % gen
            compname = "Generator Group";
    end
    Key = [Key, compname]; %#ok<AGROW> 
end

% Append pumps and sinks
Key = cellstr([Key, ["Fuel Chill","Air Chill","Fuel","Amb Air"]]);

% Instantiate Cell Array with more dimensions for labels
LabeledArch = cell(size(Arch) + [1 1]);

% Corner label shows components
LabeledArch(1,1) = {"Component"};

% Label Rows and Columns with component key
LabeledArch(2:end,1) = Key';
LabeledArch(1,2:end) = Key;

% Add architecture (1s and 0s)
LabeledArch(2:end,2:end) = num2cell(Arch);

% Set Outputs
ThermalSystem.Labeled = LabeledArch;
ThermalSystem.CompNames = Key(:);
ThermalSystem.Arch = Arch;
ThermalSystem.Propulsion = PropArch;


end