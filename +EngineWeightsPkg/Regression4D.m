% This script adds some new parameters to the database and then runs the
% regression, removing one aircraft at a time to avoid biasing the
% posterior prediction. The second section plots the resultant error
% distribution and makes a data table
function [] = Regression4D(TurbofanEngines,Weights)

% Load databases
% load('+EngineWeightsPkg/IDEAS_DB.mat')

% Process engines using the processing function in this folder to add
% additional fields
TurbofanEngines = EngineWeightsPkg.DBProcessing(TurbofanEngines);

% Get engine field names
names = fieldnames(TurbofanEngines);
N = length(names);

% Initialize
Err  = nan(N,1);
Pred = nan(N,1);
True = nan(N,1);

% Loop through each engine and run the regression while excluding the current engine from the training set
for ii = 1:N

    % Identify and exclude the current engine from the training set
    CurrentEngine = TurbofanEngines.(names{ii});
    TempStruct = rmfield(TurbofanEngines, names{ii});

    % set the inputs and output space: SLS Power, Core Mass Flow, High Pressure Turbine RPM at 100%, Dry Weight
    IO_Space = {{"Power_SLS"},{"CoreFlow"},{"HP100"},{"GearStages"},{"DryWeight"}};

    Nio = length(IO_Space);
    IO_Vals = zeros(1,Nio);

    for jj = 1:Nio
        IO_Vals(jj) = CurrentEngine.(IO_Space{jj}{1});
    end

    if any(isnan(IO_Vals))
        continue % dont bother running regression if no IO vals
    end

    % Run the regression function
    [Err(ii), Pred(ii), True(ii)] = EngineWeightsPkg.RunReg(TempStruct,IO_Space,IO_Vals,Weights);

end

% Clean Up the outputs
ind = find(~isnan(Err));
Err = Err(ind);
Pred = Pred(ind);
True = True(ind);

% Save to a mat file
% save('EngineWeightVals.mat','Err','Pred','True')

% Plotting

% Load the saved values
% load('EngineWeightVals.mat')

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

% Make a table of summary metrics
summary = [mean(Err);median(Err);std(Err);skewness(Err);kurtosis(Err); max(abs(Err)); length(Err)];
sumnames = ["Mean"; "Median";"Std Dev";"Skewness";"Kurtosis"; "Max Error"; "Sample Size"];
ErrorTable = table(sumnames,summary,'VariableNames',["Error Metric","Value"])

foo = "+EngineWeightsPkg/Results4D/" + num2str(Weights);
foo = strrep(foo,' ','');

save(foo,'summary')

end





