
function [MuPost,Sig2Post] =...
BuildRegression(DataMatrix,Prior,Target,HyperParams,InverseTerm)


PS = size(DataMatrix,1);

Kbarstar = zeros(1,PS);
for ii = 1:PS
    Kbarstar(ii) = RegressionFunctions.SquareExKernel(DataMatrix(ii,1:end-1),Target,HyperParams);
end

MuPost = Prior + Kbarstar*InverseTerm*(DataMatrix(:,end) - Prior);

Sig2Post = RegressionFunctions.SquareExKernel(Target,Target,HyperParams)...
    - Kbarstar*InverseTerm*Kbarstar';
end
