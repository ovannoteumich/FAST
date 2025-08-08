clear; clc; close all;

% Load databases
load('+DatabasePkg\IDEAS_DB.mat')

% Process engines using the processing function in this folder to add
% additional fields
TurbofanEngines = EngineWeightsPkg.DBProcessing(TurbofanEngines);


names = fieldnames(TurbofanEngines);
N = length(names);

% Initialize
Err  = zeros(N,1);
Pred = zeros(N,1);
True = zeros(N,1);


for ii = 1:N

    CurrentEngine = TurbofanEngines.(names{ii}); 
    TempStruct = rmfield(TurbofanEngines, names{ii});

    IO_Space = {["Power_SLS"],["CoreFlow"],["HP100"],["DryWeight"]};
    IO_Vals = [CurrentEngine.Power_SLS, CurrentEngine.CoreFlow,...
        CurrentEngine.HP100, CurrentEngine.DryWeight];
    [Err(ii), Pred(ii), True(ii)] = RunReg(TempStruct,IO_Space,IO_Vals);

end

% Clean Up
ind = find(~isnan(Err));
Err = Err(ind);
Pred = Pred(ind);
True = True(ind);

save('+EngineWeightsPkg/EngineWeightVals.mat','Err','Pred','True')

%% Plotting
clear; clc; close all;
load('+EngineWeightsPkg/EngineWeightVals.mat')

figure(1)

subplot(1,2,1)
scatter(True,Pred,'bo')
hold on
plot([0 8000],[0 8000],'k--')
xlabel("Actual Weight (kg)")
ylabel("Predicted Weight (kg)")
grid on


subplot(1,2,2)
scatter(True,Err,'ro')
hold on
plot([0 8000],[0 0],'k--')
xlabel("Actual Weight (kg)")
ylabel("Error (%)")
grid on

mean(Err)
std(Err)



%% Function of repetetive stuff
function [Err, Pred, True] = RunReg(TempStruct,IO_Space,IO_Vals)

  
    [Pred,~] = RegressionPkg.NLGPR(TempStruct,IO_Space,IO_Vals(1:end-1));
    True = IO_Vals(end);
    Err = (Pred - True) ./ True .* 100;

end