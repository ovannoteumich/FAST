function [TempsOut] = ToyHeatSource(ind,TempsIn,TempsOut)

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
        TempsOut(ind) = TempsIn(ind) + 40;
end





end

