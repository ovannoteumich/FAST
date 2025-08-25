clear; clc; close all
load("EngineWeightsPkg/IDEAS_DB.mat")

engines = fieldnames(TurbofanEngines);

N = length(engines);

Weights = nan(N,6);

for ii = 1:N
    % total, fan, core, remaining, true
    [Weights(ii,1),Weights(ii,2),Weights(ii,3),Weights(ii,4)] = ...
        EngineWeightsPkg.WatersWeight(TurbofanEngines.(engines{ii}));
    Weights(ii,5) = TurbofanEngines.(engines{ii}).DryWeight;
    Weights(ii,6) = EngineWeightsPkg.DrelaWeight(TurbofanEngines.(engines{ii}));
end



% remove NaNs
ind = [];
for jj = 1:N
    if sum(isnan(Weights(jj,:))) > 0
        ind = [ind,jj];
    end
end
Weights(ind,:) = [];
engines(ind) = [];



pred = Weights(:,1);
true = Weights(:,5);

ErrW = (pred - true) ./ true * 100;
ErrD = (Weights(:,6) - true) ./ true * 100;

subplot(1,2,1)
scatter(true,ErrW)
grid on
xlabel('Actual Engine Weight (kg)')
ylabel('Error (%)')
hold on
plot([0 1e4],[0 0],'k--')
ylim([-90 10])
title("Waters Method")

summary = [mean(ErrW);median(ErrW);std(ErrW);skewness(ErrW);kurtosis(ErrW); max(abs(ErrW)); length(ErrW)];
sumnames = ["Mean"; "Median";"Std Dev";"Skewness";"Kurtosis"; "Max Error"; "Sample Size"];
ErrorTable = table(sumnames,summary,'VariableNames',["Error Metric","Value"])

subplot(1,2,2)
scatter(true,ErrD)
grid on
xlabel('Actual Engine Weight (kg)')
ylabel('Error (%)')
hold on
plot([0 1e4],[0 0],'k--')
% ylim([-90 10])
title("Drela Method")

summary = [mean(ErrD);median(ErrD);std(ErrD);skewness(ErrD);kurtosis(ErrD); max(abs(ErrD)); length(ErrD)];
sumnames = ["Mean"; "Median";"Std Dev";"Skewness";"Kurtosis"; "Max Error"; "Sample Size"];
ErrorTable = table(sumnames,summary,'VariableNames',["Error Metric","Value"])



