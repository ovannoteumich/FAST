function [] = TestConstraintDiagram()
%
% [] = TestConstraintDiagram()
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 15 aug 2025
%
% create a constraint diagram for an Airbus A320neo, replicating the one
% previously made in AEROSP 481 as a GSI.
%
% INPUTS:
%     none
%
% OUTPUTS:
%     none
%

% initial cleanup
clc, close all


%% DEFINE THE AIRCRAFT'S PARAMETERS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% top-level aircraft         %
% requirements               %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% entry-into-service year
Aircraft.Specs.TLAR.EIS = 1993;

% aircraft class
Aircraft.Specs.TLAR.Class = "Turbofan";

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% performance parameters     %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% design range
Aircraft.Specs.Performance.Range = UnitConversionPkg.ConvLength(2500, "naut mi", "m");

% altitudes
Aircraft.Specs.Performance.Alts.Crs = UnitConversionPkg.ConvLength(35000, "ft", "m"); % approx 4,000 ft less than A320 absolute ceiling
Aircraft.Specs.Performance.Alts.Srv = UnitConversionPkg.ConvLength(37000, "ft", "m"); % approx 2,000 ft less than A320 absolute ceiling

% cruise mach number
Aircraft.Specs.Performance.Vels.Crs = 0.82;

% runway lengths and obstacle clearances
Aircraft.Specs.Performance.TOFL    = UnitConversionPkg.ConvLength(8000, "ft", "m");
Aircraft.Specs.Performance.LFL     = UnitConversionPkg.ConvLength(8000, "ft", "m");
Aircraft.Specs.Performance.ObstLen = UnitConversionPkg.ConvLength(1000, "ft", "m");

% multiplicative factors for OEI conditions
Aircraft.Specs.Performance.TempInc = 1.25;
Aircraft.Specs.Performance.MaxCont = 1 / 0.94;

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% aerodynamic parameters     %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% wing loading
Aircraft.Specs.Aero.W_S.SLS = 584.1679;

% wing properties
Aircraft.Specs.Aero.S  = 1317.5 * UnitConversionPkg.ConvLength(1, "ft", "m") ^ 2;
Aircraft.Specs.Aero.AR = 10;

% lift coefficients
Aircraft.Specs.Aero.CL.Crs = 0.9;
Aircraft.Specs.Aero.CL.Tko = 2.0;
Aircraft.Specs.Aero.CL.Lnd = 2.6;

% parasite drag coefficients
Aircraft.Specs.Aero.CD0.Tko = 0.0646;
Aircraft.Specs.Aero.CD0.Crs = 0.0196;
Aircraft.Specs.Aero.CD0.Lnd = 0.1196;

% lift-to-drag ratios
Aircraft.Specs.Aero.L_D.Clb = 14;
Aircraft.Specs.Aero.L_D.Crs = 20;
Aircraft.Specs.Aero.L_D.Des = 14;

% Oswald efficiency factors
Aircraft.Specs.Aero.e.Crs = 0.80;
Aircraft.Specs.Aero.e.Tko = 0.75;
Aircraft.Specs.Aero.e.Lnd = 0.70;

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% weights                    %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MTOW
Aircraft.Specs.Weight.MTOW = UnitConversionPkg.ConvMass(174172, "lbm", "kg");

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% propulsion system          %
% specifications             %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% thrust-weight ratio
Aircraft.Specs.Propulsion.T_W.SLS = 0.3059;

% number of engines
Aircraft.Specs.Propulsion.NumEngines = 2;

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% extra parameters that are  %
% likely not needed          %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % crewmembers
% TLAR.Crew.Pilot = 8;%2;
% TLAR.Crew.Cabin = 0;%4;
% 
% % passengers (payload)
% TLAR.Payload.First = 0;% 24;
% TLAR.Payload.Coach = 0;%126;
% 
% % approximate weight of passengers and bags given in metabook (lbm)
% TLAR.Payload.PaxWeight = 180;
% TLAR.Payload.BagWeight =  60;

% % cargo to be carried (lbm)
% TLAR.Payload.Cargo = 430000;%0;

% Aircraft.valus.rhoWing =    10  ; % lb / ft^2
% % assume skin-friction coefficient
% Aircraft.Specs.Aero.CF = 0.0026;
% % assume airline and route factors
% Cost.Params.AF =  0.80; % an "average" airline
% Cost.Params.RF =  5.25; % for domestic routes
% 
% % assume a block time for max range flight (about cross-country)
% Cost.Params.BlockTime = 5.75;%6; % hr
% 
% EIS = TLAR.EIS;
% 
% % cost of jet-grade fuel
% Cost.Params.Fuel  =  3.22 * CostPkg.ComputeCEF(2023, EIS); % $ / gal
% 
% % unit price of oil per gallon (base year 2022)
% Cost.Params.Oil   = 84.95 * CostPkg.ComputeCEF(2022, EIS); % $ / gal
% 
% % cost of labor (base year 2021)
% Cost.Params.Labor = 34.31 * CostPkg.ComputeCEF(2021, EIS); % $ / hr

% % assume engine thrust and weight (same as GE F138%Trent XWB-97 engine)
% Prop.UnitThrust = 59000;%27000; % lb
% 
% % assume a SFC same as GE F138%CFM56-5B4 engine (1/s)
% Prop.SFC = 1.6e-04;%1.667e-04;
% % Wght.Engin = 9790; % lb

% % assume a loiter time (min)
% Aircraft.Specs.Performance.Loiter = 45;


%% RUN THE CONSTRAINT ANALYSIS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create a T/W-W/S diagram
ConstraintDiagramPkg.ConstraintDiagram(Aircraft);


end