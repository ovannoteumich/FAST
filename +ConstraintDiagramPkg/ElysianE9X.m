function [] = ElysianE9X()
%
% [] = ElysianE9X()
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 15 sep 2025
%
% create a constraint diagram for a battery electric aircraft
% representative of the elysian E9.
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
Aircraft.Specs.TLAR.EIS = 2035;

% aircraft class
Aircraft.Specs.TLAR.Class = "Turboprop";

% aircraft regulations
Aircraft.Specs.TLAR.CFRPart = 25;

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% performance parameters     %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% design range
Aircraft.Specs.Performance.Range = 1000;

% altitudes
Aircraft.Specs.Performance.Alts.Crs = 7600;
Aircraft.Specs.Performance.Alts.Srv = 8000;
Aircraft.Specs.Performance.Alts.Div = 4000;

% stall speed
Aircraft.Specs.Performance.Vels.Stl = sqrt(2 * 509.6840 * 9.81 / 2.5 / 1.225);
Aircraft.Specs.Performance.Vels.App = UnitConversionPkg.ConvVel(145, "kts", "m/s");

% cruise mach number
Aircraft.Specs.Performance.Vels.Crs = 0.6;
Aircraft.Specs.Performance.Vels.Div = 0.4;

% runway lengths and obstacle clearances
Aircraft.Specs.Performance.TOFL    = 2000;
Aircraft.Specs.Performance.LFL     = 2000;
Aircraft.Specs.Performance.ObstLen = UnitConversionPkg.ConvLength(1000, "ft", "m");

% multiplicative factors for OEI conditions
Aircraft.Specs.Performance.TempInc = 1.25;
Aircraft.Specs.Performance.MaxCont = 1 / 0.94;

% design specific excess power loss ???
Aircraft.Specs.Performance.PsLoss = 0;

% landing weight as a fraction of MTOW
Aircraft.Specs.Performance.Wland_MTOW = 1;

% requirement type (0 = Roskam, 1 = Mattingly, 2 = de Vries et al.)
Aircraft.Specs.TLAR.ReqType = 2;

% prescribe an extra AEO climb gradient
Aircraft.Specs.Performance.ExtraGrad = 0.08;

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% aerodynamic parameters     %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% wing loading
Aircraft.Specs.Aero.W_S.SLS = 509.6840;

% wing properties
Aircraft.Specs.Aero.S  = 76000 / 509.6840;
Aircraft.Specs.Aero.AR = 12;

% lift coefficients ??? crs
Aircraft.Specs.Aero.CL.Crs = 1.0;
Aircraft.Specs.Aero.CL.Tko = 2.5;
Aircraft.Specs.Aero.CL.Lnd = 3.1;

% parasite drag coefficients ??? pred
Aircraft.Specs.Aero.CD0.Tko = 0.0618;
Aircraft.Specs.Aero.CD0.Crs = 0.0168;
Aircraft.Specs.Aero.CD0.Lnd = 0.1168;

% Oswald efficiency factors ??? pred
Aircraft.Specs.Aero.e.Crs = 0.8039;
Aircraft.Specs.Aero.e.Tko = 0.7565;
Aircraft.Specs.Aero.e.Lnd = 0.7093;

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% weights                    %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MTOW
Aircraft.Specs.Weight.MTOW = 76000;

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% propulsion system          %
% specifications             %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% power-weight ratio (kW/kg)
Aircraft.Specs.Power.P_W.SLS = 0.1568;

% number of engines
Aircraft.Specs.Propulsion.NumEngines = 4;


%% RUN THE CONSTRAINT ANALYSIS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% determine which constraints to use (0 = 14 CFR 25; 1 = novel)
Aircraft.Settings.ConstraintType = 0;

% create a constraint diagram
ConstraintDiagramPkg.ConstraintDiagram(Aircraft);

% add the existing sizing point
hold on
scatter(Aircraft.Specs.Aero.W_S.SLS * 9.81 / 1000, 1 / (Aircraft.Specs.Power.P_W.SLS / 9.81 * 1000), 48, "o", "MarkerEdgeColor", "red", "MarkerFaceColor", "red");


end