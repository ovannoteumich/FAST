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

MetalProperties.RefUnits.Density = 'kg/m3';
MetalProperties.RefUnits.K = 'W/(mK)'; % heat transfer coeff @ 0 celsius

% Aluminum
MetalProperties.Aluminum.Name = "Aluminum";
MetalProperties.Aluminum.Density = 2710;
MetalProperties.Aluminum.K = 236; 

% Copper
MetalProperties.Copper.Name = "Copper";
MetalProperties.Copper.Density = 8960;
MetalProperties.Copper.K = 401; 

% Steel 304
MetalProperties.Steel_304.Name = "Steel_304";
MetalProperties.Steel_304.Density = 7930;
MetalProperties.Steel_304.K = 16.2;


%% Fluids

FluidProperties.RefUnits.Density = 'kg/m3';
FluidProperties.RefUnits.SpecificHeat = 'J/(kgK)'; % specific heat capacity @ 0 celsius
FluidProperties.RefUnits.VaporTemp = 'C'; % at 1 atmosphere
FluidProperties.RefUnits.VaporHeat = 'J/kg'; % at vapor temp
FluidProperties.RefUnits.K = 'W/(mK)'; % thermal conductivity
FluidProperties.RefUnits.Mu = 'kg/(ms)'; % dynamic viscosity


% Water
FluidProperties.Water.Name = "Water";
FluidProperties.Water.Density = 1000;
FluidProperties.Water.SpecificHeat = 4184;
FluidProperties.Water.VaporTemp = 100;
FluidProperties.Water.VaporHeat = 2.2564e6;
FluidProperties.Water.K = 0.6; % Varies based on temperature
FluidProperties.Water.Mu = 0.0010005; % Dynamic viscosity

% Ethylene Glycol 30% by weight
FluidProperties.EthyleneGlycol_30.Name = "EthyleneGlycol_30";
FluidProperties.EthyleneGlycol_30.Density = 1054;
FluidProperties.EthyleneGlycol_30.SpecificHeat = 3764;
FluidProperties.EthyleneGlycol_30.VaporTemp = 104;
FluidProperties.EthyleneGlycol_30.VaporHeat = ...
    (8e5 * (0.3 / 62.07 ) + 2.2564e6 * (0.7 / 18.015)) / ((0.3 / 62.07 ) + (0.7 / 18.015)); % simple linear interpolation
FluidProperties.EthyleneGlycol_30.K = ...
    (0.258 * (0.3 / 62.07 ) + 0.6 * (0.7 / 18.015)) / ((0.3 / 62.07 ) + (0.7 / 18.015)); % simple linear interpolation
FluidProperties.EthyleneGlycol_30.Mu = exp(0.3 * log(0.0010005 * 15.5) + 0.7 * log(0.0010005));

% Ethylene Glycol 60% by weight
FluidProperties.EthyleneGlycol_60.Name = "EthyleneGlycol_60";
FluidProperties.EthyleneGlycol_60.Density = 1108;
FluidProperties.EthyleneGlycol_60.SpecificHeat = 3214;
FluidProperties.EthyleneGlycol_60.VaporTemp = 111;
FluidProperties.EthyleneGlycol_60.VaporHeat = ...
    (8e5 * (0.6 / 62.07 ) + 2.2564e6 * (0.7 / 18.015)) / ((0.4 / 62.07 ) + (0.7 / 18.015)); % simple linear interpolation
FluidProperties.EthyleneGlycol_60.K = ...
    (0.258 * (0.6 / 62.07 ) + 0.6 * (0.7 / 18.015)) / ((0.4 / 62.07 ) + (0.7 / 18.015)); % simple linear interpolation
FluidProperties.EthyleneGlycol_60.Mu = exp(0.6 * log(0.0010005 * 15.5) + 0.4 * log(0.0010005));

% Ethylene Glycol 100% by weight
FluidProperties.EthyleneGlycol_100.Name = "EthyleneGlycol_100";
FluidProperties.EthyleneGlycol_100.Density = 1180; % Approx
FluidProperties.EthyleneGlycol_100.SpecificHeat = 2281;
FluidProperties.EthyleneGlycol_100.VaporTemp = 197;
FluidProperties.EthyleneGlycol_100.VaporHeat = 8e5;
FluidProperties.EthyleneGlycol_100.K = 0.258;  
FluidProperties.EthyleneGlycol_100.Mu = 0.0010005 * 15.5; % at 40 celsius. 


% Air
FluidProperties.Air.Name = "Air";
FluidProperties.Air.Density = 1.225;
FluidProperties.Air.SpecificHeat = 1005;


%% Return Outputs

save('+ThermalPkg/+MaterialsPkg/Material_DB.mat','FluidProperties','MetalProperties')






end