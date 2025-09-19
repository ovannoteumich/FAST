clear; clc; close all;

load("DatabasePkg/IDEAS_DB.mat")

Target = cell(1,6);
trials = logspace(1,6,6);

for ii = 1:length(trials)

    Target{ii} = rand(trials(ii),4);

end


times = zeros(1,length(trials));

for jj = 1:length(trials)
tic 
timetest(Target{jj},TurbofanAC)
times(jj) = toc
end






function [] = timetest(Target,TurbofanAC)

IOspace = {{"Specs", "Aero"      , "S"            }, ...
    {"Specs", "Propulsion", "Thrust", "SLS"}, ...
    {"Specs", "TLAR"      , "EIS"          }, ...
    {"Specs", "Weight"    , "MTOW"         }, ...
    {"Specs", "Weight"    , "Airframe"     }}   ;

Prior = RegressionPkg.PriorCalculation(TurbofanAC,IOspace);
OEWWeights = [1 1 0.2 1];
[RegressionParams.OEW.DataMatrix,    RegressionParams.OEW.HyperParams,     RegressionParams.OEW.InverseTerm] =...
    RegressionPkg.RegProcessing(TurbofanAC,IOspace,Prior, OEWWeights);


WframeNew = RegressionPkg.NLGPR(TurbofanAC, IOspace, Target, 'Preprocessing',RegressionParams.OEW);

end


