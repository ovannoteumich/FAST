clear; clc; close all
load("EngineWeightsPkg/IDEAS_DB.mat")

engines = fieldnames(TurbofanEngines);

N = length(engines);

Weights = nan(N,5);

for ii = 1:N
    % total, fan, core, remaining, true
    [Weights(ii,1),Weights(ii,2),Weights(ii,3),Weights(ii,4)] = ...
        EngineWeightsPkg.WatersWeight(TurbofanEngines.(engines{ii}));
    Weights(ii,5) = TurbofanEngines.(engines{ii}).DryWeight;
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

Err = (pred - true) ./ true * 100;

scatter(true,Err)
grid on
xlabel('Actual Engine Weight (kg)')
ylabel('Error (%)')
hold on
plot([0 1e4],[0 0],'k--')
ylim([-90 10])

summary = [mean(Err);median(Err);std(Err);skewness(Err);kurtosis(Err); max(abs(Err)); length(Err)];
sumnames = ["Mean"; "Median";"Std Dev";"Skewness";"Kurtosis"; "Max Error"; "Sample Size"];
ErrorTable = table(sumnames,summary,'VariableNames',["Error Metric","Value"])




