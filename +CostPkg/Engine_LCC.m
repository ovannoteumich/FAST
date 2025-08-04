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

%% Engine Cost Values %%
%%%%%%%%%%%%%%%%%%%%%%%%

% initial aquisition cost
icost = 12e6;

% base yar labor cost (per hour)
labor_cost = 170;

% labor cost increase rate (%)
r_labor = 0.027;

%% LLPs

% cost
LLPcost = 4.1e6;

% interest rate per year
rLLP = 0.06;

% number of flight cycles until replacement
LLPcycle = 20000;
