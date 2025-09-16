function [] = InitializeComponents()
%
% [] = InitializeComponents()
% written by Max Arnson, marnson@umich.edu
% last updated 28 Jul 2025
%
% Initialize a database of materials for the ThermalPkg.
% 
% INPUTS:
%       None
%
% OUTPUTS:
%       None (prints a database to a mat file)

% references
% https://www.engineeringtoolbox.com/ethylene-glycol-d_146.html
% https://www.engineeringtoolbox.com/water-liquid-gas-thermal-conductivity-temperature-pressure-d_2012.html
% https://www.engineeringtoolbox.com/water-properties-d_1573.html
% https://www.engineeringtoolbox.com/thermal-conductivity-metals-d_858.html


%% Metals

Metals.RefUnits.Density = 'kg/m3';
Metals.RefUnits.K = 'W/(mK)'; % heat transfer coeff @ 0 celsius

% Aluminum
Metals.Aluminum.Density = 2710;
Metals.Aluminum.K = 236; 

% Copper
Metals.Copper.Density = 8960;
Metals.Copper.K = 401; 

% Steel 304
Metals.Steel_304.Density = 7930;
Metals.Steel_304.K = 16.2;


%% Fluids

Fluids.RefUnits.Density = 'kg/m3';
Fluids.RefUnits.SpecificHeat = 'J/(kgK)'; % specific heat capacity @ 0 celsius
Fluids.RefUnits.VaporTemp = 'C'; % at 1 atmosphere
Fluids.RefUnits.VaporHeat = 'J/kg'; % at vapor temp
Fluids.RefUnits.K = 'W/(mK)'; % thermal conductivity
Fluids.RefUnits.Mu = 'kg/(ms)'; % dynamic viscosity


% Water
Fluids.Water.Density = 1000;
Fluids.Water.SpecificHeat = 4184;
Fluids.Water.VaporTemp = 100;
Fluids.Water.VaporHeat = 2.2564e6;
Fluids.Water.K = 0.6; % Varies based on temperature
Fluids.Water.Mu = 0.0010005; % Dynamic viscosity

% Ethylene Glycol 30% by weight
Fluids.EthyleneGlycol_30.Density = 1054;
Fluids.EthyleneGlycol_30.SpecificHeat = 3764;
Fluids.EthyleneGlycol_30.VaporTemp = 104;
Fluids.EthyleneGlycol_30.VaporHeat = ...
    (8e5 * (0.3 / 62.07 ) + 2.2564e6 * (0.7 / 18.015)) / ((0.3 / 62.07 ) + (0.7 / 18.015)); % simple linear interpolation
Fluids.EthyleneGlycol_30.K = ...
    (0.258 * (0.3 / 62.07 ) + 0.6 * (0.7 / 18.015)) / ((0.3 / 62.07 ) + (0.7 / 18.015)); % simple linear interpolation
Fluids.EthyleneGlycol_30.Mu = exp(0.3 * log(0.0010005 * 15.5) + 0.7 * log(0.0010005));

% Ethylene Glycol 60% by weight
Fluids.EthyleneGlycol_60.Density = 1108;
Fluids.EthyleneGlycol_60.SpecificHeat = 3214;
Fluids.EthyleneGlycol_60.VaporTemp = 111;
Fluids.EthyleneGlycol_60.VaporHeat = ...
    (8e5 * (0.6 / 62.07 ) + 2.2564e6 * (0.7 / 18.015)) / ((0.4 / 62.07 ) + (0.7 / 18.015)); % simple linear interpolation
Fluids.EthyleneGlycol_60.K = ...
    (0.258 * (0.6 / 62.07 ) + 0.6 * (0.7 / 18.015)) / ((0.4 / 62.07 ) + (0.7 / 18.015)); % simple linear interpolation
Fluids.EthyleneGlycol_60.Mu = exp(0.6 * log(0.0010005 * 15.5) + 0.4 * log(0.0010005));

% Ethylene Glycol 100% by weight
Fluids.EthyleneGlycol_100.Density = 1180; % Approx
Fluids.EthyleneGlycol_100.SpecificHeat = 2281;
Fluids.EthyleneGlycol_100.VaporTemp = 197;
Fluids.EthyleneGlycol_100.VaporHeat = 8e5;
Fluids.EthyleneGlycol_100.K = 0.258;  
Fluids.EthyleneGlycol_100.Mu = 0.0010005 * 15.5; % at 40 celsius. 


% Air
Fluids.Air.Density = 1.225;
Fluids.Air.SpecificHeat = 1005;


%% Return Outputs

save('+ThermalPkg/+MaterialsPkg/Material_DB.mat','Fluids','Metals')






end