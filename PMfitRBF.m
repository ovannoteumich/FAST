function PMfitRBF()
% Radial basis function (RBF) fit and plot
% Written for AEROSP 740 - Complex Systems Design & Integration @ U-M
% interpolator written by Dr. G. Cinar - ideas.engin.umich.edu
% code modified by Paul Mokotoff
% Created: January 2024. Last modified: 23 jan 2026

% initial cleanup
clc, close all

% set seed for reproducibility
rng(16);


%% SELECT HYPERPARAMETERS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% select the shape parameter
r0 = 1;

% select the basis type, either: 'Multi-Quadratic', 'Gaussian', or
% 'Thin Plate Spline'
BasisType = 'Multi-Quadratic';


%% DEVELOP THE RBF %%
%%%%%%%%%%%%%%%%%%%%%

% load the data table
MyTable = readtable("FFFFullDOEComplete.xlsx");

% get the number of entries
n = height(MyTable);

% convert to an array
MyData = table2array(MyTable);

% create a random permutation of training/validation data
Perm = randperm(n);

% split the data: 80% training, 20% validation
isplit = round(0.8 * n);

% get the training and validation indices
itrain = Perm <= isplit;
ivalid = Perm >  isplit;

% get the training and validation data
TrainX  = MyData(itrain, 1:end-2);
ValidX  = MyData(ivalid, 1:end-2);

% get the training and validation responses (only using fuel
% for this example, but could use MTOW too for another fit)
TrainY1 = MyData(itrain,   end-1);
TrainY2 = MyData(itrain,   end  );
ValidY1 = MyData(ivalid,   end-1);
ValidY2 = MyData(ivalid,   end  );

% fit an RBF        
RBF = RBFInterpolator(TrainX, TrainY1, BasisType, r0);


%% EVALUATE THE FIT %%
%%%%%%%%%%%%%%%%%%%%%%

% evaluate the RBF and compare to the training/validation data
Fit1Train = RBF(TrainX);
Fit1Valid = RBF(ValidX);

% get the min/max of the fits (for axis limits)
MinFitTrain = min(Fit1Train) - 50;
MaxFitTrain = max(Fit1Train) + 50;
MinFitValid = min(Fit1Valid) - 50;
MaxFitValid = max(Fit1Valid) + 50;

% compute the residuals
Resid1Train = Fit1Train - TrainY1;
Resid1Valid = Fit1Valid - ValidY1;

% get the largest residual
MaxResidTrain = max(abs(Resid1Train));
MaxResidValid = max(abs(Resid1Valid));

% compute the percent error
Error1Train = 100 .* Resid1Train ./ TrainY1;
Error1Valid = 100 .* Resid1Valid ./ ValidY1;

% get the maximum error for the bounds
ErrBnds = max(max(abs(Error1Train)), max(abs(Error1Valid)));


%% PLOT ACTUAL-BY-PREDICTED: TRAINING DATA %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create a figure
figure(1);

% create a scatter plot
scatter(Fit1Train, TrainY1, 18, "o", ...
    "MarkerEdgeColor", "black", "MarkerFaceColor", "black");

% format plot
title(sprintf("Training: %s, r0 = %d", BasisType, r0));
xlabel("Predicted Fuel");
ylabel("Actual Fuel");
axis([MinFitTrain, MaxFitTrain, MinFitTrain, MaxFitTrain]);
axis square
grid on
set(gca, "FontSize", 18);

% % maximize the figure
% set(gcf, 'Position', get(0, 'Screensize'));
% 
% % save the figure
% saveas(gcf, sprintf("TrainABP-%s-%d.svg", BasisType, r0));


%% PLOT ACTUAL-BY-PREDICTED: VALIDATION DATA %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create a figure
figure(2);

% create a scatter plot
scatter(Fit1Valid, ValidY1, 18, "o", ...
    "MarkerEdgeColor", "black", "MarkerFaceColor", "black");

% format plot
title(sprintf("Validation: %s, r0 = %d", BasisType, r0));
xlabel("Predicted Fuel");
ylabel("Actual Fuel");
axis([MinFitValid, MaxFitValid, MinFitValid, MaxFitValid]);
axis square
grid on
set(gca, "FontSize", 18);

% % maximize the figure
% set(gcf, 'Position', get(0, 'Screensize'));
% 
% % save the figure
% saveas(gcf, sprintf("ValidABP-%s-%d.svg", BasisType, r0));


%% PLOT RESIDUAL-BY-PREDICTED %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create a figure
figure(3);

% add a title
sgtitle(sprintf("%s, r0 = %d", BasisType, r0));
set(gca, "FontSize", 18);

% scatter plot of the training data
subplot(2, 1, 1);
scatter(Fit1Train, Resid1Train, 18, "o", ...
    "MarkerEdgeColor", "black", "MarkerFaceColor", "black");

% format plot
title("Training Data");
xlabel("Predicted Fuel");
ylabel("Residual");
axis([MinFitTrain, MaxFitTrain, MaxResidTrain * [-1.1, +1.1]]);
grid on

% scatter plot of the validation data
subplot(2, 1, 2);
scatter(Fit1Valid, Resid1Valid, 18, "o", ...
    "MarkerEdgeColor", "black", "MarkerFaceColor", "black");

% format plot
title("Validation Data");
xlabel("Predicted Fuel");
ylabel("Residual");
axis([MinFitValid, MaxFitValid, MaxResidValid * [-1.1, +1.1]]);
grid on

% % maximize the figure
% set(gcf, 'Position', get(0, 'Screensize'));
% 
% % save the figure
% saveas(gcf, sprintf("RBP-%s-%d.svg", BasisType, r0));


%% PLOT ERROR DISTRIBUTIONS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create a figure
figure(4);

% add a title
sgtitle(sprintf("%s, r0 = %d", BasisType, r0));
set(gca, "FontSize", 18);

% histogram of the training data
subplot(1, 2, 1);
histogram(Error1Train, "Orientation", "horizontal");

% histogram of the validation data
subplot(1, 2, 2);
histogram(Error1Valid, "Orientation", "horizontal");

% % maximize the figure
% set(gcf, 'Position', get(0, 'Screensize'));
% 
% % save the figure
% saveas(gcf, sprintf("Error-%s-%d.svg", BasisType, r0));

% ----------------------------------------------------------
       
end

% ----------------------------------------------------------
% ----------------------------------------------------------
% ----------------------------------------------------------

function rbf = RBFInterpolator(xTrain, yTrain, basisType, r0)

% create RBF interpolator function using the chosen basis function
switch basisType
    case 'Multi-Quadratic'
        phi = @(r) sqrt((r./r0).^2 + 1);
    case 'Gaussian'
        phi = @(r) exp(-(r./r0).^2);
    case 'Thin Plate Spline'
        phi = @(r) (r./r0).^2 .* log(r./r0 + eps);  % Add eps to avoid log(0)
    otherwise
        error('Unknown basis function type.');
end

% calculate the RBF coefficients
distances = pdist2(xTrain, xTrain);

% compute the value of the basis functions
A = phi(distances);

% compute the RBF coefficients
lambda = pinv(A) * yTrain;  % use pseudoinverse for more stability

% define the interpolator function
rbf = @(X) phi(pdist2(X, xTrain)) * lambda;  % Ensure X is a column vector

end