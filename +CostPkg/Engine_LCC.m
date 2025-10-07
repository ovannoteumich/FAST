function [] = Engine_LCC(Aircraft)
%
% [] = Life_Cycle_COst(Preq, Time, SOCBeg, Parallel, Series)
% originally written by Emma Cassidy, emmasmit@umich.edu
% 
% last updated: 31 July 2025
%
% 
%
%

%% Life Cycle Overview %%
%%%%%%%%%%%%%%%%%%%%%%%%%

% aircraft life span (years)
span = 25;

% year into service
eis = 2025;

% aircraft base case
range = 800; %nmi
time = 2; %hrs

% MRO break down (Flight Equivalent Cycles)
SV1_FEC = 1e4; % intitial check, oiling, and repairs
SV2_FEC = 2e4; % full engine teardown, LLPs replacements

%% Engine Cost Values %%
%%%%%%%%%%%%%%%%%%%%%%%%

% initial aquisition cost
Initial_Cost = Aircraft.Specs.Cost.Engine;

% flight energy costs
JetFuelkwh_Cost = Aircraft.Specs.Cost.AvgFuel_kwh;
Electkwh_Cost   = Aircraft.Specs.Cost.AvgFuel_kwh;

% energy inflation rate
r_JetFuel = 0.005;
r_Elect   = 0.039;

% base yar labor cost (per hour)
labor_cost = 170;

% labor cost increase rate (%)
r_labor = 0.027;


%% Initial Cost

%% MRO Comparison



end
