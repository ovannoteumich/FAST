function [TempsOut] = HeatSourceSwitch(ThermalSystem,ind,TempsIn,TempsOut)

NComp = length(TempsIn);


switch ind
    case NComp % Ambient Sink
        % Do nothing, output temperature already set
    case NComp-1 % Reservoir Sink
        % Do nothing, output temperature already set
    case NComp-2 % Ambient Pump
        DeltaT = 0;
    case NComp-3 % Reservoir Pump
        DeltaT = 0;
    otherwise % Heat Source

        Comp = ThermalSystem.CompNames{ind};

        if startsWith(Comp,"Batt",'IgnoreCase',true)

        elseif startsWith(Comp,"Mot",'IgnoreCase',true)

        elseif startsWith(Comp,"Gen",'IgnoreCase',true)
            
        else
            error("Invalid Propulsion Component")
        end

        TempsOut(ind) = TempsIn(ind) + 40;
end





end

