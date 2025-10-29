function [ThermalSystem] = HeatSourceSwitch(ind,ThermalSystem)

% Get Number of Components
NComp = length(ThermalSystem.CompNames);

% Only sources add heat to the system
if ind < NComp-3

        Comp = ThermalSystem.CompNames{ind};

        % This is necessary as the labeling scheme might call them batt1 or
        % 'motor group' or something, so we want to be explicit here
        if startsWith(Comp,"Batt",'IgnoreCase',true)
            Component.Name = "Battery";
        elseif startsWith(Comp,"Mot",'IgnoreCase',true)
            Component.Name = "Motor";
        elseif startsWith(Comp,"Gen",'IgnoreCase',true)
            Component.Name = "Generator";
        else
            error("Invalid Propulsion Component")
        end

        % Set Component power, efficiency, and max temp based on thermal
        % system inputs
        Component.MaxPower = ThermalSystem.Propulsion.MaxPower(ind);
        Component.Eta = ThermalSystem.Propulsion.Efficiency(ind);
        Component.MaxTemp = ThermalSystem.Settings.MaxTemperature.(Component.Name);

        % Update component temperature
        [ThermalSystem] = ThermalPkg.ComponentsPkg.HeatSource(...
            ind,...
            ThermalSystem, ...
            Component);


end





end

