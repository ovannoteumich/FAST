function [ThermalSystem] = AssignMaxTemps(ThermalSystem)


NSrcs = length(ThermalSystem.CompNames)-4;
MaxTemps = zeros(NSrcs,1);

for ind = 1:NSrcs
Comp = ThermalSystem.CompNames{ind};

        % This is necessary as the labeling scheme might call them batt1 or
        % 'motor group' or something
        if startsWith(Comp,"Batt",'IgnoreCase',true)
            FullName = "Battery";

        elseif startsWith(Comp,"Mot",'IgnoreCase',true)
            FullName = "Motor";

        elseif startsWith(Comp,"Gen",'IgnoreCase',true)
            % Motors and Generators are the same

            FullName = "Generator";
        else
            error("Invalid Propulsion Component")
        end

        MaxTemps(ind) = ThermalSystem.Settings.MaxTemperature.(FullName);

end

ThermalSystem.Analysis.MaxTemps = MaxTemps;
end

