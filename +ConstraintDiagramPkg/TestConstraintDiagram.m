function [] = TestConstraintDiagram()
%
% [] = TestConstraintDiagram()
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 21 aug 2025
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

% design specific excess power loss
Aircraft.Specs.Performance.PsLoss = 0.7689;

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


%% RUN THE CONSTRAINT ANALYSIS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% determine which constraints to use (0 = 14 CFR 25; 1 = novel)
Aircraft.Settings.ConstraintType = 1;

% create a constraint diagram
ConstraintDiagramPkg.ConstraintDiagram(Aircraft);


end