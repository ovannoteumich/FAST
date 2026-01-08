function [Aircraft] = RegionalTurbopropMission(Aircraft)
%
% [Aircraft] = RegionalTurbopropMission(Aircraft)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 23 dec 2025
%
% fixed mission profile for a 90-passenger regional turboprop. the mission
% is divided into three parts:
% 
% part 1: fly 750 km (design mission)            | part 2:      | part 3: 
%                                                | 150 km       | 30 min 
%                                                | diversion    | loiter
%                                                |              |
%                                                |              |
%           _____________________________        |              |   
%          /                             \       |              |
%      ___/                               \___   |    __________|___
%     /                                       \  |  _/          |   \_
%    /                                         \_|_/            |     \
% __/                                            |              |      \__
%
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

% get the design range
Range = Aircraft.Specs.Performance.Range;

% define the targets (in m or min)
Mission.Target.Valu = [Range; 150e+3; 30];

% define the target types ("Dist" or "Time")
Mission.Target.Type = ["Dist"; "Dist"; "Time"];


%% DEFINE ADDITIONAL ALTITUDES/AIRSPEEDS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% takeoff and cruise altitudes (for design and diversion missions) (m)
AltTko =    0;
AltCrs = 7600;
AltDiv = 3500;

% lower altitude for constant EAS climb/descent segments (m)
AltClb = 900;

% takeoff and diversion speeds
VelTko = 63   ; % m/s TAS
VelDiv =  0.40; % Mach

% cruise speed (Mach)
VelCrs = Aircraft.Specs.Performance.Vels.Crs;

% define an approach speed (m/s TAS, approximately 30% faster than takeoff
% speed)
VelApr = 82;

% define a constant climb/descent speed (m/s, EAS)
VelClb = 90;
VelDes = 90;

% define the speed types
TAS  = "TAS" ;
EAS  = "EAS" ;
Mach = "Mach";


%% DEFINE THE MISSION SEGMENTS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% define the segments and its corresponding mission ID
Mission.Segs    = ["Takeoff"; "Climb"; "Climb"; "Climb"; "Cruise"; "Descent"; "Descent"; "Climb"; "Climb"; "Cruise"; "Cruise"; "Descent"; "Descent"; "Descent"; "Landing"];
Mission.ID      = [        1;       1;       1;       1;        1;         1;         1;       2;       2;        2;        3;         3;         3;         3;         3];

% define the starting/ending altitudes (in m)
Mission.AltBeg  = [   AltTko;  AltTko;  AltClb;  AltCrs;   AltCrs;    AltCrs;    AltCrs;  AltClb;  AltDiv;   AltDiv;   AltDiv;    AltDiv;    AltDiv;    AltClb;    AltTko];
Mission.AltEnd  = [   AltTko;  AltClb;  AltCrs;  AltCrs;   AltCrs;    AltCrs;    AltClb;  AltDiv;  AltDiv;   AltDiv;   AltDiv;    AltDiv;    AltClb;    AltTko;    AltTko];

% define the starting/ending speeds (in m/s or mach)
Mission.VelBeg  = [        0;  VelTko;  VelClb;  VelClb;   VelCrs;    VelCrs;    VelDes;  VelClb;  VelClb;   VelDiv;   VelDiv;    VelDiv;    VelDes;    VelDes;    VelApr];
Mission.VelEnd  = [   VelTko;  VelClb;  VelClb;  VelCrs;   VelCrs;    VelDes;    VelDes;  VelClb;  VelDiv;   VelDiv;   VelDiv;    VelDes;    VelDes;    VelApr;         0];

% define the speed types (either "TAS", "EAS", or "Mach")
Mission.TypeBeg = [      TAS;     TAS;     EAS;     EAS;     Mach;      Mach;       EAS;     EAS;     EAS;     Mach;     Mach;      Mach;       EAS;       EAS;       TAS];
Mission.TypeEnd = [      TAS;     EAS;     EAS;    Mach;     Mach;       EAS;       EAS;     EAS;    Mach;     Mach;     Mach;       EAS;       EAS;       TAS;       TAS];

% climb rates are unrestricted and only limited by the maximum rate of
% climb defined in the aircraft specification file ... define as NaN here
Mission.ClbRate = NaN(length(Mission.ID), 1);


%% REMEMBER THE MISSION PROFILE %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% save the information
Aircraft.Mission.Profile = Mission;

% ----------------------------------------------------------

end