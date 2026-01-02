function [] = MonteCarlo()
%
% [] = MonteCarlo()
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 02 jan 2026
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

% seed the random number generator for repeatable outcomes
rng(16);


%% VARY TECHNOLOGICAL PARAMETERS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% maximum number of samples
n = 5;

% select random number between 0 and 1 (normally distributed)
x = randn(4, n);

% vary the distributed propulsion L/D benefit
% mean = 4, standard deviation = 1
LDMult = 1 .* x(1, :) + 4;

% vary the battery specific energy (kWh/kg)
% mean = 0.360, standard deviation = 0.1
BSE = 0.1 .* x(2, :) + 0.360;

% vary the electric motor power-to-weight ratio (kW/kg)
% mean = 5, standard deviation = 1.0
P_Wem = 1.0 .* x(3, :) + 5;

% vary the electric generator power-to-weight ratio (kW/kg)
% mean = 5, standard deviation = 2.0
P_Weg = 2.0 .* x(4, :) + 5;


%% RUN MONTE CARLO %%
%%%%%%%%%%%%%%%%%%%%%

% allocate memory for fuel burn and MTOW
Fuel = zeros(n, 1);
MTOW = zeros(n, 1);

% run a monte-carlo simulation
for i = 1:n
    
    % get the aircraft
    Aircraft = AircraftSpecsPkg.RegionalTurboprop(3);
    
    % update the L/D benefit
    Aircraft.Specs.Aero.L_D.Crs = 24.00 * (1 + LDMult(i) / 100);
    Aircraft.Specs.Aero.L_D.Clb = 19.20 * (1 + LDMult(i) / 100);
    Aircraft.Specs.Aero.L_D.Des = 19.20 * (1 + LDMult(i) / 100);

    % update the battery specific energy
    Aircraft.Specs.Power.SpecEnergy.Batt = BSE(i);
    
    % update the electric generator and motor power-to-weight ratios
    Aircraft.Specs.Power.P_W.EM = P_Wem(i);
    Aircraft.Specs.Power.P_W.EG = P_Weg(i);
    
    % size the aircraft
    OutAC = Main(Aircraft, @MissionProfilesPkg.RegionalTurbopropMission);
    
    % get the fuel burn and MTOW
    Fuel(i) = OutAC.Specs.Weight.Fuel;
    MTOW(i) = OutAC.Specs.Weight.MTOW;
    
end

% compute the expected values
EFuel = sum(Fuel) / n;
EMTOW = sum(MTOW) / n;

% compute the standard deviation
STDFuel = std(Fuel);
STDMTOW = std(MTOW);

% compute the confidence interval ranges
% (use a z-score of 1.96 for a 95% confidence interval)
CIRangeFuel = 1.96 * STDFuel / sqrt(n);
CIRangeMTOW = 1.96 * STDMTOW / sqrt(n);

% compute the bounds of the confidence intervals
BoundsFuel = EFuel + [-CIRangeFuel, +CIRangeFuel];
BoundsMTOW = EMTOW + [-CIRangeMTOW, +CIRangeMTOW];


%% POST-PROCESSING %%
%%%%%%%%%%%%%%%%%%%%%

% create a figure
figure;

% plot histogram of fuel burn
histogram(Fuel);

% format the plot
title(sprintf("%d Samples, Expected Fuel Burn = %.2f kg", n, EFuel));
xlabel("Fuel Burn (kg)");
ylabel("Count");
set(gca, "FontSize", 18);

% create a figure
figure;

% plot histogram of MTOW
histogram(MTOW);

% format the plot
title(sprintf("%d Samples, Expected MTOW = %.2f kg", n, EMTOW));
xlabel("MTOW (kg)");
ylabel("Count");
set(gca, "FontSize", 18);

% create a figure
figure;

% add a hold
hold on

% scatterplot of fuel burn and MTOW
s1 = scatter(Fuel, MTOW, 18, "o", "MarkerEdgeColor", "black", "MarkerFaceColor", "black");

% plot a box of the data within the confidence intervals
p1 = plot([BoundsFuel(1), BoundsFuel(2), BoundsFuel(2), BoundsFuel(1), BoundsFuel(1)], ...
          [BoundsMTOW(1), BoundsMTOW(1), BoundsMTOW(2), BoundsMTOW(2), BoundsMTOW(1)], ...
          "--", "LineWidth", 2, "Color", "blue");

% format the plot
title(sprintf("%d Samples", n));
xlabel("Fuel Burn (kg)");
ylabel("MTOW (kg)");
grid on
set(gca, "FontSize", 18);
legend([s1, p1], "Data", "95% CI");

% ----------------------------------------------------------

end