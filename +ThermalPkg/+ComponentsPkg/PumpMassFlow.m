function [MDotSink] = PumpMassFlow(Component,ThermalSystem)


if Component == "FuelPump"
    ind = NComps -3;
    ReturnTemp = ThermalSystem.Settings.Coolant.FuelPumpReturn;
    SinkTemp = ThermalSystem.Settings.Coolant.FuelPumpSink;
end

if Component == "AmbPump"
    ind = NComps - 2;
    ReturnTemp = ThermalSystem.Settings.Coolant.AmbientPumpReturn;
    SinkTemp = ThermalSystem.Settings.Coolant.AmbientPumpSink;
end




% Read in working fluid specific heat
Cp = ThermalSystem.WorkingFluid.SpecificHeat;

DelTReturn = ThermalSystem.Analysis.TempsIn(ind) ...
    - ThermalSystem.Settings.Coolant.FuelPumpReturn;

% To size the mass flow through a pumped coolant loop, the amount of heat
% needing to be removed is calculated

Q = MDotReturn * Cp * DelTReturn;


MDotSink = Q / Cp / DelTSink;





end

