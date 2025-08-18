
clear; clc; clear;

%% Create Suffixes
N = 5;
w1 = 1:1:N;
w2 = 1:1:N;
w3 = 1:1:N;
w4 = 1:1:N;
suffixes = cell(1,5^4);
counter = 1;


[W1, W2, W3, W4] = ndgrid(w1,w2,w3,w4);


for ii = 1:N
    for jj = 1:N
        for kk = 1:N
            for ll = 1:N
                Weights = [W1(ii,jj,kk,ll), W2(ii,jj,kk,ll), W3(ii,jj,kk,ll), W4(ii,jj,kk,ll)];
                Weights = num2str(Weights);
                Weights = strrep(Weights,' ','');
                suffixes{counter} = Weights; 
                counter = counter+1;
            end
        end
    end
end

%% Read in files

results = zeros(7,length(suffixes));

for ii = 1:length(suffixes)
    foo = "+EngineWeightsPkg/Results4D/" + suffixes(ii) + ".mat";
    load(foo)
    results(:,ii) = summary;
end
    

