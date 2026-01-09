function [] = MonteCarlo()
%
% [] = MonteCarlo()
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 09 jan 2026
%
% vary multiple technological parameters and identify the expected fuel
% burn and MTOW.
%
% INPUTS:
%     none
%
% OUTPUTS:
%     none
%

% initial cleanup
clc, close all

% seed the random number generator for repeatable outcomes
rng(16);


%% VARY TECHNOLOGICAL PARAMETERS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% number of samples to collect
n = [10, 100, 500, 1000, 1500, 2000];

% get the maximum number of samples
nsamp = max(n);

% select random number between 0 and 1 (unif. distributed)
x = rand(4, nsamp);

% vary the distributed propulsion L/D benefit (%)
% lower bound = 2, nominal value = 4, upper bound = 6
LDMult = 4 + 2 .* x(1, :);

% vary the battery specific energy (kWh/kg)
% lower bound = 0.240, nominal value = 0.360, upper bound = 0.480
BSE = 0.360 + 0.12 .* x(2, :);

% vary the electric motor power-to-weight ratio (kW/kg)
% lower bound = 3, nominal value = 5, upper bound = 7
P_Wem = 5 + 2 .* x(3, :);

% vary the electric generator power-to-weight ratio (kW/kg)
% lower bound = 3, nominal value = 5, upper bound = 7
P_Weg = 5 + 2 .* x(4, :);


%% RUN MONTE CARLO %%
%%%%%%%%%%%%%%%%%%%%%

% allocate memory for fuel burn and MTOW
Fuel = zeros(nsamp, 1);
MTOW = zeros(nsamp, 1);

% run a monte-carlo simulation
parfor isamp = 1:nsamp

    try
        % get the aircraft
        Aircraft = AircraftSpecsPkg.RegionalTurboprop(3);

        % update the L/D benefit
        Aircraft.Specs.Aero.L_D.Crs = 24.00 * (1 + LDMult(isamp) / 100);
        Aircraft.Specs.Aero.L_D.Clb = 19.20 * (1 + LDMult(isamp) / 100);
        Aircraft.Specs.Aero.L_D.Des = 19.20 * (1 + LDMult(isamp) / 100);

        % update the battery specific energy
        Aircraft.Specs.Power.SpecEnergy.Batt = BSE(isamp);

        % update the electric generator and motor power-to-weight ratios
        Aircraft.Specs.Power.P_W.EM = P_Wem(isamp);
        Aircraft.Specs.Power.P_W.EG = P_Weg(isamp);

        % size the aircraft
        OutAC = Main(Aircraft, @MissionProfilesPkg.RegionalTurbopropMission);

        % get the fuel burn and MTOW
        Fuel(isamp) = OutAC.Specs.Weight.Fuel;
        MTOW(isamp) = OutAC.Specs.Weight.MTOW;

    catch

        Fuel(isamp) = NaN;
        MTOW(isamp) = NaN;

    end    
end

% remove NaNs
Fuel(isnan(Fuel)) = [];
MTOW(isnan(MTOW)) = [];

% get the maximum number samples available
maxn = length(Fuel);

% save the results
save("MonteCarloSized.mat", "Fuel", "MTOW");


%% POST-PROCESSING %%
%%%%%%%%%%%%%%%%%%%%%

% number of sets to test
nset = length(n);

% loop through all sets
for iset = 1:nset

    % get the number of samples
    msamp = min(n(iset), maxn);
    
    % compute the expected values
    EFuel = sum(Fuel(1:msamp)) / msamp;
    EMTOW = sum(MTOW(1:msamp)) / msamp;

    % compute the standard deviation
    STDFuel = std(Fuel(1:msamp));
    STDMTOW = std(MTOW(1:msamp));

    % compute the confidence interval ranges
    % (use a z-score of 1.96 for a 95% confidence interval)
    CIRangeFuel = 1.96 * STDFuel / sqrt(msamp);
    CIRangeMTOW = 1.96 * STDMTOW / sqrt(msamp);
    
    % compute the bounds of the confidence intervals
    BoundsFuel = EFuel + [-CIRangeFuel, +CIRangeFuel];
    BoundsMTOW = EMTOW + [-CIRangeMTOW, +CIRangeMTOW];

    % create a figure
    figure;
    
    % plot histogram of fuel burn
    histogram(Fuel(1:msamp));
    
    % format the plot
    title(sprintf("%d Samples, Expected Fuel Burn = %.2f kg", n(iset), EFuel));
    xlabel("Fuel Burn (kg)");
    ylabel("Count");
    set(gca, "FontSize", 18);
    
    % create a figure
    figure;
    
    % plot histogram of MTOW
    histogram(MTOW(1:msamp));
    
    % format the plot
    title(sprintf("%d Samples, Expected MTOW = %.2f kg", n(iset), EMTOW));
    xlabel("MTOW (kg)");
    ylabel("Count");
    set(gca, "FontSize", 18);
    
    % create a figure
    figure;
    
    % add a hold
    hold on
    
    % scatterplot of fuel burn and MTOW
    s1 = scatter(Fuel(1:msamp), MTOW(1:msamp), 18, "o", "MarkerEdgeColor", "black", "MarkerFaceColor", "black");
    
    % plot a box of the data within the confidence intervals
    p1 = plot([BoundsFuel(1), BoundsFuel(2), BoundsFuel(2), BoundsFuel(1), BoundsFuel(1)], ...
        [BoundsMTOW(1), BoundsMTOW(1), BoundsMTOW(2), BoundsMTOW(2), BoundsMTOW(1)], ...
        "--", "LineWidth", 2, "Color", "blue");
    
    % format the plot
    title(sprintf("%d Samples", n(iset)));
    xlabel(sprintf("Fuel Burn (kg, +/- %.2f)", CIRangeFuel));
    ylabel(sprintf("MTOW (kg, +/- %.2f)", CIRangeMTOW));
    grid on
    set(gca, "FontSize", 18);
    legend([s1, p1], "Data", "95% CI");
    
end

% ----------------------------------------------------------

end