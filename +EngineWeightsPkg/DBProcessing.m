%% Loop Function
function [Engines] = DBProcessing(Engines)

% loop through all fields in the engine structure
names = fieldnames(Engines);
for ii = 1:length(names)


    % For each one, run the calculation from below
    Engines.(names{ii}) = CalcEngVals(Engines.(names{ii}));

end

end


%% Calculation Function
function [Eng] = CalcEngVals(Eng)

% Calculate core airflow using sls airflow and BPR
Eng.CoreFlow = Eng.Airflow_SLS / Eng.BPR;

% From Power_To_Thrust, gives Newtons to watts ******
Eng.Power_SLS = Eng.Thrust_SLS * 187;


end


% ******** the scaling factor will not change the results of Testing.m
% because all training data are scaled the same. This will however affect the
% regression's ability to predict values that are outside of the training
% data such as engines designed with pycycle. we should tune this value as
% it will affect how heavy the predictions are in the absolute

