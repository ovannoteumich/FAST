function [Err, Pred, True] = RunReg(TempStruct,IO_Space,IO_Vals,Weights)

% Call the regression
 [Pred,~] = EngineWeightsPkg.RegressionFunctions.NLGPR(TempStruct,IO_Space,IO_Vals(1:end-1),'Weights',Weights); % previously run for Power, coreflow, and hp100
% [Pred,~] = EngineWeightsPkg.RegressionFunctions.NLGPR(TempStruct,IO_Space,IO_Vals(1:end-1));

% Process the outputs
True = IO_Vals(end);
Err = (Pred - True) ./ True .* 100;

end