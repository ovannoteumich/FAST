function [Aircraft] = NarrowBodyMission(Aircraft)
%
% [Aircraft] = A320(Aircraft)
% written by Max Arnson, marnson@umich.edu
% 
% last updated: 1 Aug 2025, Emma Cassidy
%
% define an A320(Neo) design mission
% (see below).
%
% mission 1: Range/3 nmi climb and cruise  
% mission 2: Range/3 nmi climb and cruise
% mission 3: Range/3 nmi climb and cruise and descent
% mission 4: hold for desginated time, then taxi
%             |          |                   |
%             |          | _________         |
%             | _________|/         \        |
%        _____|/         |           \       |
%       /     |          |            \      | 
%      /      |          |             \     |
%     /       |          |              \    | 
%    /        |          |               \___|_____
% __/         |          |                   |     \__
%      1            2                3            4
%
% INPUTS:
%     Aircraft - aircraft structure (without a mission profile).
%                size/type/units: 1-by-1 / struct / []
%
% OUTPUTS:
%     Aircraft - aircraft structure (with    a mission profile).
%                size/type/units: 1-by-1 / struct / []
%


%% DEFINE THE MISSION TARGETS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get aircraft range
Range = Aircraft.Specs.Performance.Range;

% holding time in air
holdT = 30;
%taxiT = 20;
%holdT = Aicraft.Specs.Perfromace.HoldTime;


% define the targets (in m or min)
Ranges = [Range/3; Range/3; Range/3];
Mission.Target.Valu = [Ranges; holdT; NaN];

% define the target types ("Dist" or "Time")
Mission.Target.Type = ["Dist"; "Dist"; "Dist"; "Time"; NaN];


%% DEFINE THE MISSION SEGMENTS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% define the segments
Mission.Segs = ["DetailedTakeoff"; "Climb"; "Climb"; "Cruise";
    "Climb"; "Cruise"; 
    "Climb"; "Cruise"; "Descent"; 
    %"Cruise"; "Descent"; "Landing"];
    "Cruise"; "Descent"; "Landing"; "EWheelTaxi"];


% define the mission id (segments in same mission must be consecutive)
Mission.ID   = [ 1; 1; 1; 1;
    2; 2;
    3; 3; 3;
    4; 4; 4; 5;];

% define the starting/ending altitudes (in m)
Mission.AltBeg = UnitConversionPkg.ConvLength([ 0; 0; 10000; 35000;
    35000; 37000;
    37000; 39000; 39000;
    1500; 1500; 0; 0;],'ft','m');

Mission.AltEnd = UnitConversionPkg.ConvLength([ 0; 10000; 35000; 35000;
    37000; 37000;
    39000; 39000; 1500;
    1500; 0; 0; 0;],'ft','m');

% define the climb rate (in m/s)
Mission.ClbRate = [ NaN; NaN; NaN; NaN;
    NaN; NaN;
    NaN; NaN; NaN;
    NaN; NaN; NaN; NaN];

% define the starting/ending speeds
Mission.VelBeg  = [ 0; UnitConversionPkg.ConvVel(150,'kts','m/s'); UnitConversionPkg.ConvVel(250,'kts','m/s'); 0.78;
    0.78; 0.78;
    0.78; 0.78; 0.78;
    0.3; 0.3; UnitConversionPkg.ConvVel(150,'kts','m/s'); 0;];

Mission.VelEnd  = [UnitConversionPkg.ConvVel(150,'kts','m/s'); UnitConversionPkg.ConvVel(250,'kts','m/s'); 0.78; 0.78;
    0.78; 0.78;
    0.78; 0.78; 0.3;
    0.3; UnitConversionPkg.ConvVel(150,'kts','m/s'); 0; 10];

% define the speed types
Mission.TypeBeg = [ "TAS"; "TAS"; "TAS"; "Mach";
    "Mach"; "Mach";
    "Mach"; "Mach"; "Mach";
    "Mach"; "Mach"; "TAS"; "TAS";];

Mission.TypeEnd = [ "TAS"; "TAS"; "Mach"; "Mach";
    "Mach"; "Mach";
    "Mach"; "Mach"; "Mach";
    "Mach"; "TAS"; "TAS"; "TAS"];

Mission.TaxiTime = 20;
Mission.MainMissEnd = 82;
Mission.TkoRoll = 1600; %m;
%% REMEMBER THE MISSION PROFILE %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% save the information
Aircraft.Mission.Profile = Mission;

% ----------------------------------------------------------

end