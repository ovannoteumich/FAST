function [] = InitializeEngines()


load("EngineWeightsPkg/IDEAS_DB.mat")
TurbofanEngines = EngineWeightsPkg.DBProcessing(TurbofanEngines);

save(fullfile("+EngineWeightsPkg", "IDEAS_DB.mat"),'TurbofanEngines')

end

