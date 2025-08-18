%%
clear; clc; close all;
load("EngineWeightsPkg/IDEAS_DB.mat")

tic
EngineWeightsPkg.Regression4D(TurbofanEngines,[1 1 5 2])
toc

%%
clear; clc;
load("EngineWeightsPkg/IDEAS_DB.mat")

N = 5;
w1 = 1:1:N;
w2 = 1:1:N;
w3 = 1:1:N;
w4 = 1:1:N;


[W1, W2, W3, W4] = ndgrid(w1,w2,w3,w4);


for ii = 1:N
    for jj = 1:N
        for kk = 1:N
            for ll = 1:N
                Weights = [W1(ii,jj,kk,ll), W2(ii,jj,kk,ll), W3(ii,jj,kk,ll), W4(ii,jj,kk,ll)];
                EngineWeightsPkg.Regression4D(TurbofanEngines,Weights)
            end
        end
    end
end

