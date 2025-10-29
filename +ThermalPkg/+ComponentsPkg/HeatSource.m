function [ThermalSystem] = HeatSource(ind,ThermalSystem,Component)

% Read in Input temperature
InputTemp = ThermalSystem.Analysis.TempsIn(ind);

 

% Find mass flow rate through this component
LoopCol = ThermalSystem.Loops.LoopIDs(ind,:) ~= 0;
LoopInd = ThermalSystem.Loops.LoopIDs(ind,LoopCol);
MDot = ThermalSystem.Loops.MassFlow(LoopInd);


% Heat Added is simply motor inefficiency
q = Component.MaxPower*(1 - Component.Eta);

% set delta T at maximum allowable temperature
delT = q / MDot / Cp;

% output temperature rise
ThermalSystem.Analysis.TempsOut(ind) = InputTemp + delT;


end

