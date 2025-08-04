function [DOC] = EnergyCost_perAirport(Aircraft, Origin)
%
%
% Inputs:
%    Aircraft - aircraft model
%    Origin - origin airport code (where refueling and recharging take
%    place)
%
%--------------------------------------------------------------------------

% get the number of points in each segment
TkoPts = Aircraft.Settings.TkoPoints;
ClbPts = Aircraft.Settings.ClbPoints;
CrsPts = Aircraft.Settings.CrsPoints;
DesPts = Aircraft.Settings.DesPoints;

% number of points in the main mission
npt = TkoPts + 3 * (ClbPts - 1) + CrsPts - 1 + 3 * (DesPts - 1);

% check number of energy sources
Fuel = find(Aircraft.Specs.Propulsion.PropArch.ESType == 1);
Batt = find(Aircraft.Specs.Propulsion.PropArch.ESType == 0);

fuelE = 0;
battE = 0;

if ~isempty(Fuel)
    fuelE = Aircraft.Mission.History.SI.Energy.E_ES(:,Fuel);
end

if ~isempty(Batt)
    battE = Aircraft.Mission.History.SI.Energy.E_ES(:,Batt);
end

% load fuel/energy pricing table
priceTable = readtable('\+ExperimentPkg\Energy_CostbyAirport.xlsx');

end