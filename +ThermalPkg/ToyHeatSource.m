function [OutputTemp] = ToyHeatSource(InputTemp,type)


switch type
    case "l"
        DeltaT= 40;
    case "m"
        DeltaT= 3;
    case "s"
        DeltaT= 2;
end

OutputTemp = InputTemp + DeltaT;



end

