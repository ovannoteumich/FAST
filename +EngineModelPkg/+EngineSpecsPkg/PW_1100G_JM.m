function [Engine] = PW_1100G_JM()
%
% [Engine] = PW_1100G_JM()
% Written By: Emma Cassidy, emmasmit@umich.edu
% Last Updated: 7/10/25
%
% Engine specification function for use with the EngineModelPkg
%
% INPUTS:
%
% [None]
%
%
% OUTPUTS:
%
% Engine = struct storing the information specified by the user for this
%           specific engine
%       size: 1x1 struct
%
%
% Information
% -----------
%
% Type = Turbofan
% Applicable Aircraft = Airbus A320neo 

%% Design Point Values

% Design point Mach Number 
% If SLS, enter 0.05
Engine.Mach = 0.05;

% Design point Altitude [m]
% If SLS, enter 0
Engine.Alt = 0;

% Overall Pressure Ratio 
Engine.OPR = 50;

% Fan Pressure Ratio
% Estimated value based on PW GTF design
Engine.FPR = 1.65;

% Bypass Ratio
% Published BPR for PW1100G-JM is ~12.2
Engine.BPR = 12.2;

% Combustion Temperature [K]
Engine.Tt4Max = 1950;

% Temperature Limits [K]
Engine.TempLimit.Val = NaN;
Engine.TempLimit.Type = NaN;

% Design point thrust [N]
% Max rated takeoff thrust for PW1133G (24,240 lbf)
Engine.DesignThrust = 120430;

%% Architecture

% Number of Spools
Engine.NoSpools = 2;

% Spool RPMs
% approximated from idle rpms
Engine.RPMs = [10500, 19000];

% Gear Ratio
Engine.FanGearRatio = 3.0625;

% Fan Boosters
% Typically false for geared turbofans
Engine.FanBoosters = false;

%% Airflows

% Passenger Bleeds
Engine.CoreFlow.PaxBleed = 0.03;

% Air leakage
Engine.CoreFlow.Leakage = 0.01;

% Core Cooling Flow
Engine.CoreFlow.Cooling = 0.0;

%% Sizing Limits

% Maximum iterations allowed in the engine sizing loop
Engine.MaxIter = 300;

%% Efficiencies

% Polytropic component efficiencies (modern values for GTF)
Engine.EtaPoly.Inlet = 0.99;
Engine.EtaPoly.Diffusers = 0.99;
Engine.EtaPoly.Fan = 0.99;
Engine.EtaPoly.Compressors = 0.96;
Engine.EtaPoly.BypassNozzle = 0.99;
Engine.EtaPoly.Combustor = 0.995;
Engine.EtaPoly.Turbines = 0.985;
Engine.EtaPoly.CoreNozzle = 0.99;
Engine.EtaPoly.Nozzles = 0.99;
Engine.EtaPoly.Mixing = 1;

%% Offdesign coefficient of BADA equation 
% currently same as Leap_1A26 because of similar thrust 
Engine.Cff3    =  0.4006;
Engine.Cff2    = -0.4323;
Engine.Cff1    =  0.9946;
Engine.Cffch   =  6.1*10^-7;
Engine.HEcoeff =  1;

end