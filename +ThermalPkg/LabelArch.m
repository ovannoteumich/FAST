function [LabeledArch] = LabelArch(Arch)
% Labels a thermal architecture into a cell array for easy tracking

% Instantiate Key
Key = [];

% Build number of sources
for ii = 1:size(Arch,1)-4
    Key = [Key, "SRC " + ii];
end

% Append pumps and sinks
Key = cellstr([Key, ["RezPump","AmbPump","Rez","Amb"]]);

% Instantiate Cell Array with more dimensions for labels
LabeledArch = cell(size(Arch) + [1 1]);

% Corner label shows components
LabeledArch(1,1) = {"Component"};

% Label Rows and Columns with component key
LabeledArch(2:end,1) = Key';
LabeledArch(1,2:end) = Key;

% Add architecture (1s and 0s)
LabeledArch(2:end,2:end) = num2cell(Arch);


end