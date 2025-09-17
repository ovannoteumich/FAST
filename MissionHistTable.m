function [History] = MissionHistTable(Aircraft)
%
% [History] = MissionHistTable(Aircraft)
% originally written by ???
% modified by Paul Mokotoff, prmoko@umich.edu
% last updated: 11 mar 2024
%
% After an aircraft flies a mission, record its mission history in a table.
%
% INPUTS:
%     Aircraft - structure with the "Aircraft.Mission.History.SI"
%                sub-structure filled in.
%                size/type/units: 1-by-1 / struct / []
%
% OUTPUTS:
%     History  - table with the mission history from
%                "Aircraft.Mission.History.SI" filled in.
%                size/type/units: 1-by-1 / table / []
%


%% SHORTHANDS TO ACCESS MISSION HISTORY %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% setup shorthands to each sub-structure
Performance = Aircraft.Mission.History.SI.Performance;
Propulsion  = Aircraft.Mission.History.SI.Propulsion ;
Weight      = Aircraft.Mission.History.SI.Weight     ;
Power       = Aircraft.Mission.History.SI.Power      ;
Energy      = Aircraft.Mission.History.SI.Energy     ;
Segment     = Aircraft.Mission.History.Segment       ;


%% CREATE A (LARGE) TABLE %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% convert the time to minutes (as a time array)
Time = minutes(Performance.Time ./ 60);

% setup a table
MyTable = table(Time                      , ... % time flown (min)
                Segment                   , ... % segment
                Performance.Dist ./ 1000  , ... % distance flown
                Performance.TAS           , ... % true airspeed
                Performance.EAS           , ... % equivalent airspeed
                Performance.RC            , ... % rate of climb
                Performance.Alt           , ... % altitude
                Performance.Acc           , ... % acceleration
                Performance.FPA           , ... % flight path angle
                Performance.Mach          , ... % mach number
                Performance.Rho           , ... % density
                Performance.Ps            , ... % specific excess shaft power
                Propulsion.TSFC           , ... % TSFC
                Propulsion.MDotFuel       , ... % fuel flow
                Weight.CurWeight          , ... % aircraft weight
                Weight.Fburn              , ... % fuel burn
                Power.Tav       ./ 1.0e+03, ... % thrust available
                Power.Treq      ./ 1.0e+03, ... % thrust required
                Power.TV        ./ 1.0e+06, ... % thrust power
                Power.Req       ./ 1.0e+06, ... % required power
                Power.Pav       ./ 1.0e+06, ... % available power for each component
                Power.Preq      ./ 1.0e+06, ... % required power for each component
                Power.SOC                 , ... % state of charge
                Energy.KE       ./ 1.0e+06, ... % kinetic energy
                Energy.PE       ./ 1.0e+06, ... % potential energy
                Energy.E_ES     ./ 1.0e+06, ... % energy expended
                Energy.Eleft_ES ./ 1.0e+06);    % energy remaining
            
% setup the variable names
MyTable.Properties.VariableNames = string(["Time (min)", ...
                                           "Segment", ...
                                           "Distance (km)", ...
                                           "TAS (m/s)", ...
                                           "EAS (m/s)", ...
                                           "R/C (m/s)", ...
                                           "Altitude (m)", ...
                                           "Acceleration (m/s^2)", ...
                                           "FPA (deg.)", ...
                                           "Mach", ...
                                           "Density (kg/m^3)", ...
                                           "Specific Excess Power (m/s)", ...
                                           "SFC (kg/Ns)", ...
                                           "Fuel Flow (kg/s)", ...
                                           "Weight (kg)", ...
                                           "Fuel Burn (kg)", ...
                                           "Thrust Available (kN)", ...
                                           "Thrust Required (kN)", ...
                                           "Thrust Power (MW)", ...
                                           "Required Power (MW)", ...
                                           "Power Available (MW)", ...
                                           "Power Required (MW)", ...
                                           "State of Charge (%)", ...
                                           "Kinetic Energy (MJ)", ...
                                           "Potential Energy (MJ)", ...
                                           "Energy Expended (MJ)", ...
                                           "Energy Remaining (MJ)"]);

% convert to a timetable
History = table2timetable(MyTable);


%% CREATE STACKED PLOTS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%

stackedplot(History, ["Distance (km)", "Mach", "Fuel Burn (kg)", "State of Charge (%)", "Power Available (MW)", "Power Required (MW)"], "LineWidth", 2);
grid on
return
% plot parts of the performance history
figure;
stackedplot(History, ["Distance (m)", "TAS (m/s)", "Altitude (m)"]);
title("AC Performance");

% plot parts of the propulsion history
figure;
stackedplot(History, ["Available Thrust (kN)",  "Required Thrust (kN)"]);
title("AC Thrust");

% plot parts of the weight history
figure;
stackedplot(History, ["Weight (kg)", "Fuel Burn (kg)"]);
title("AC Weight");

% plot parts of the power history
figure;
stackedplot(History, ["Available Power (MW)", "Required Power (MW)", "Output Power (MW)"]);
title("AC Power");

% plot parts of the energy history
figure;
stackedplot(History, "Energy Expended (MJ)");
title("AC Energy");

% ----------------------------------------------------------

end