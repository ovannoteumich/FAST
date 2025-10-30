function [ThermalSystem] = AssignPumpLoops(ThermalSystem)




% Check for Fuel Heat Pump, if it exists append it to the end
if any(ThermalSystem.Arch(:,end-3))


    MDotPump = ThermalPkg.ComponentsPkg.PumpMassFlow("FuelPump",ThermalSystem);
    ColNum = find(ThermalSystem.Loops.LoopIDs(end-3,:) ~=0);
    LoopID = ThermalSystem.Loops.LoopIDs(end-3,ColNum);
    ThermalSystem.Loops.MassFlow(LoopID) = MDotPump;
end


% Check for ambient Heat Pump, if it exists append it to the end
if any(ThermalSystem.Arch(:,end-2))
    MDotPump = ThermalPkg.ComponentsPkg.PumpMassFlow("AmbPump",ThermalSystem);
    ColNum = find(ThermalSystem.Loops.LoopIDs(end-2,:) ~=0);
    LoopID = ThermalSystem.Loops.LoopIDs(end-2,ColNum);
    ThermalSystem.Loops.MassFlow(LoopID) = MDotPump;

end



end
