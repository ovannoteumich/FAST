function [] = HEA_DesignStudies(RunCases)
% function to perform hybridization studies on A30neo

%% check inputs and setup

if nargin<1
    % run cases if no input
    RunCases = 1;
end

% skip all initial sizing if just loading aircraft
if RunCases == 1
%% Size conventional aircraft

Aircraft = AircraftSpecsPkg.A320neo;
Aircraft.Specs.Propulsion.PropArch.Type = "PHE";
Aircraft.Specs.Propulsion.PropArch.TrnType = [];
Aircraft.Settings.PowerStrat = -1;

% gravimetric specific energy of battery (kWh/kg), not used here
Aircraft.Specs.Power.SpecEnergy.Batt = .25;
Aircraft.Settings.PowerOpt = 0;

% battery cells in series and parallel 
Aircraft.Specs.Power.Battery.ParCells = 100;
Aircraft.Specs.Power.Battery.SerCells = 62;

% initial battery SOC
Aircraft.Specs.Power.Battery.BegSOC = 100;

AircraftOG = Main(Aircraft, @MissionProfilesPkg.A320);

%% off-design run of conventional on shorter mission

Aircraft2 = AircraftOG;
Aircraft2.Specs.Weight.Payload = Aircraft2.Specs.Weight.Payload + 500; %500 kg of reserve fuel so dont have to fly reserve mission
Aircraft2.Specs.Performance.Range = UnitConversionPkg.ConvLength(800, "naut mi", "m");
Aircraft2.Settings.Analysis.Type = -1;

Aircraft2.Specs.Power.LamUps = rmfield(Aircraft2.Specs.Power.LamUps, 'Miss');
Aircraft2.Specs.Power.LamDwn = rmfield(Aircraft2.Specs.Power.LamDwn, 'Miss');
Aircraft2 = Main(Aircraft2, @MissionProfilesPkg.NarrowBodyMission);

%% Set up hybridization and add EMs

Aircraft = Aircraft2;
Aircraft.Settings.Analysis.Type = -1;

% add in EMs and weight
Aircraft.Specs.Weight.EM = 400;
Aircraft.Specs.Weight.OEW = Aircraft.Specs.Weight.OEW + Aircraft.Specs.Weight.EM;
Aircraft.Specs.Power.P_W.EM = 10*1000;

Aircraft.Specs.Propulsion.SLSPower(:,[3,4]) = [200,200]*10*1000;
Aircraft.Specs.Propulsion.SLSPower(:,[5,6]) = Aircraft.Specs.Propulsion.SLSPower(:,[5,6]) + Aircraft.Specs.Propulsion.SLSPower(:,[3,4]).*.99;% add EM to SLS power
Aircraft.Specs.Propulsion.SLSThrust(:,[3,4]) = Aircraft.Specs.Propulsion.SLSPower(:,[3,4])/Aircraft.Specs.Performance.Vels.Tko;
Aircraft.Specs.Propulsion.SLSThrust(:,[5,6]) = Aircraft.Specs.Propulsion.SLSThrust(:,[5,6]) + Aircraft.Specs.Propulsion.SLSThrust(:,[3,4]);
Aircraft.Specs.Power.LamUps = [];
Aircraft.Specs.Power.LamDwn = [];

AircraftStruct = Aircraft;
end

%% Sizing Iteration

% set up iteration variables
n = 35;
n1 = 1;
lams_tko=0;
%lams_tko = linspace(0,.5,n1);
lams_clb = linspace(0,.35,n);

%designate space for results
fburn = zeros(n,n1);
batt = zeros(n,n1);
crate = zeros(n,n1);
SOC = zeros(n,n1);
Energy = zeros(n,n1);
pass = zeros(n*n1,1);
i=0;

% create results folder if not one already
folderName = 'A320neo_hybrid2';

if ~exist(folderName, 'dir')
    mkdir(folderName);
end

% iterate over power splits for sizing HEA
for itko = 1:n1
    for iclb = 1:n
        i=i+1;
        
         MyMat = sprintf("HEAclb_%d.mat", i);
        
        % check if cases must be run
        if (RunCases == 1)
            Aircraft = AircraftStruct;
            %Aircraft = ans;
            
            Aircraft.Specs.Power.LamUps.SLS = lams_tko(itko);

            Aircraft.Specs.Power.LamUps.Tko = lams_tko(itko);
     

            if lams_clb(iclb)==0
                Aircraft.Specs.Power.LamUps.Clb = 0;
            else
                Aircraft.Specs.Power.LamUps.Clb = 1;
            end
            
            Aircraft.Specs.Power.LamUps.Crs = 0;
            Aircraft.Specs.Power.LamUps.Des = 0;
            Aircraft.Specs.Power.LamUps.Lnd = 0;

            Aircraft.Specs.Power.LamDwn.Tko = 0;
            Aircraft.Specs.Power.LamDwn.SLS = lams_clb(iclb);
            Aircraft.Specs.Power.LamDwn.Clb = lams_clb(iclb);
            Aircraft.Specs.Power.LamDwn.Crs = 0;
            Aircraft.Specs.Power.LamDwn.Des = 0;
            Aircraft.Specs.Power.LamDwn.Lnd = 0;
            
            % settings
            Aircraft.Settings.PowerStrat = -1;
            Aircraft.Settings.PowerOpt = 0;
            Aircraft.Settings.PrintOut = 0;
            % -1 = prioritize downstream, go from fan back to energy sources
            
            Aircraft = Main(Aircraft, @MissionProfilesPkg.NarrowBodyMission);
                
            % save the aircraft
            save(fullfile(folderName, MyMat), "Aircraft");
            
        else
            
                % get the .mat file
            foo = load(fullfile(folderName, MyMat));
            
            % get the sized aircraft
            Aircraft = foo.Aircraft;
        
        end 

        pass(i) = Aircraft.Settings.Converged;

        

        
        fburn(iclb,itko) = Aircraft.Specs.Weight.Fuel;
        batt(iclb,itko) = Aircraft.Specs.Weight.Batt;
        SOC(iclb, itko) = Aircraft.Mission.History.SI.Power.SOC(end,2);
        Energy(iclb, itko) = Aircraft.Mission.History.SI.Energy.E_ES(end,2);
        %crate(iclb, itko) = max(Aircraft.Mission.History.SI.Power.C_rate(:,2));
    end
end

%{
    
    % remember the weights
    MTOW( isplit) = SizedERJ.Specs.Weight.MTOW   ;
    OEW(  isplit) = SizedERJ.Specs.Weight.OEW    ;
    Wfuel(isplit) = SizedERJ.Specs.Weight.Fuel   ;
    Wbatt(isplit) = SizedERJ.Specs.Weight.Batt   ;
    Wem(  isplit) = SizedERJ.Specs.Weight.EM     ;
    Weng( isplit) = SizedERJ.Specs.Weight.Engines;
    
    % remember the thrust results
    TSLS(isplit)            = SizedERJ.Specs.Propulsion.Thrust.SLS            ;
    TSLS_per_engine(isplit) = SizedERJ.Specs.Propulsion.SLSThrust(1)          ;
    TTOC(isplit)            = SizedERJ.Mission.History.SI.Power.Tout_PS(37, 1);
    
    % remember SFCs at specific points in the mission
    SFCs(isplit, 1) = SizedERJ.Mission.History.SI.Propulsion.TSFC(  2, 1); %TkoSFC
    SFCs(isplit, 2) = SizedERJ.Mission.History.SI.Propulsion.TSFC_EMT(  2, 1); %TkoSFC_EMT
    SFCs(isplit, 3) = SizedERJ.Mission.History.SI.Propulsion.TSFC( 37, 1); %TOCSFC
    SFCs(isplit, 4) = SizedERJ.Mission.History.SI.Propulsion.TSFC( 39, 1); %Beginning_of_CruiseSFC
    SFCs(isplit, 5) = SizedERJ.Mission.History.SI.Propulsion.TSFC( 45, 1); %TODSFC
    SFCs(isplit, 6) = SizedERJ.Mission.History.SI.Propulsion.TSFC(100, 1); %BegSFC
    SFCs(isplit, 7) = SizedERJ.Mission.History.SI.Propulsion.TSFC(117, 1); %EndSFC
    



%% POST-PROCESS %%
%%%%%%%%%%%%%%%%%%

% convert the SFCs
SFCs = UnitConversionPkg.ConvTSFC(SFCs, "SI", "Imp");

% retrieve the important SFCs for plotting
TkoSFC       = SFCs([1, 6, 8, 11], 1)';
TkoSFC_EMT   = SFCs([1, 6, 8, 11], 2)';
TOCSFC       = SFCs([1, 6, 8, 11], 3)';
BegCruiseSFC = SFCs([1, 6, 8, 11], 4)';
TODSFC       = SFCs([1, 6, 8, 11], 5)';
BegSFC       = SFCs([1, 6, 8, 11], 6)';
EndSFC       = SFCs([1, 6, 8, 11], 7)';

% compute the percent difference in MTOW, OEW, and fuel
PercDiffMTOW      = 100 .* ( MTOW(2:end) -  MTOW(1)) ./  MTOW(1);
PercDiffOEW       = 100 .* (  OEW(2:end) -   OEW(1)) ./   OEW(1);
PercDiffWfuel     = 100 .* (Wfuel(2:end) - Wfuel(1)) ./ Wfuel(1);
PercDiffWeng      = 100 .* ( Weng(2:end) -  Weng(1)) ./  Weng(1);
PercDiffTSLS      = 100 .* ( TSLS(2:end) -  TSLS(1)) ./  TSLS(1);
PercDiffTTOC      = 100 .* ( TTOC(2:end) -  TTOC(1)) ./  TTOC(1);
PercDiffSLSThrust = 100 .* ( TSLS_per_engine(2:end) - TSLS_per_engine(1)) ./ TSLS_per_engine(1); 

% plot the MTOW results
figure;
yyaxis left
plot(LambdaTko, MTOW, "-o", "LineWidth", 2);
ylabel("MTOW (kg)");
yyaxis right
plot(LambdaTko(2:end), PercDiffMTOW, "-o", "LineWidth", 2);
ylabel("Percent Difference (%)");

% format plot
title("Electrified Aircraft - MTOW");
xlabel("Power Split (%)");
set(gca, "FontSize", 18);
grid on

% plot the fuel burn results
figure;
yyaxis left
plot(LambdaTko, Wfuel, "-o", "LineWidth", 2);
ylabel("Block Fuel (kg)");
yyaxis right
plot(LambdaTko(2:end), PercDiffWfuel, "-o", "LineWidth", 2);
ylabel("Percent Difference (%)");

% format plot
title("Electrified Aircraft - Block Fuel");
xlabel("Power Split (%)");
set(gca, "FontSize", 18);
grid on

% plot the OEW results
figure;
yyaxis left
plot(LambdaTko, OEW, "-o", "LineWidth", 2);
ylabel("OEW (kg)");
yyaxis right
plot(LambdaTko(2:end), PercDiffOEW, "-o", "LineWidth", 2);
ylabel("Percent Difference (%)");

% format plot
title("Electrified Aircraft - OEW");
xlabel("Power Split (%)");
set(gca, "FontSize", 18);
grid on

% plot the engine weight results
figure;
yyaxis left
plot(LambdaTko, Weng, "-o", "LineWidth", 2);
ylabel("Engine Weight (kg)");
yyaxis right
plot(LambdaTko(2:end), PercDiffWeng, "-o", "LineWidth", 2);
ylabel("Percent Difference (%)");

% format plot
title("Electrified Aircraft - Engine Weight");
xlabel("Power Split (%)");
set(gca, "FontSize", 18);
grid on

% plot the battery and electric motor weight results
figure;
yyaxis left
plot(LambdaTko, Wbatt, "-o", "LineWidth", 2);
ylabel("Battery Weight (kg)");
yyaxis right
plot(LambdaTko, Wem, "-o", "LineWidth", 2);
ylabel("Electric Motor Weight (kg)");

% format plot
title("Electrified Aircraft - Electrical Components");
xlabel("Power Split (%)");
set(gca, "FontSize", 18);
grid on

% plot the SLS thrust results
figure;
yyaxis left
plot(LambdaTko, TSLS ./ 1000, "-o", "LineWidth", 2);
ylabel("SLS Thrust (kN)");
yyaxis right
plot(LambdaTko(2:end), PercDiffTSLS, "-o", "LineWidth", 2);
ylabel("Percent Difference (%)");

% format plot
title("Electrified Aircraft - SLS Thrust");
xlabel("Power Split (%)");
set(gca, "FontSize", 18);
grid on

% plot the TOC thrust results
figure;
yyaxis left
plot(LambdaTko, TTOC ./ 1000, "-o", "LineWidth", 2);
ylabel("Top of Climb Thrust (kN)");
yyaxis right
plot(LambdaTko(2:end), PercDiffTTOC, "-o", "LineWidth", 2);
ylabel("Percent Difference (%)");

% format plot
title("Electrified Aircraft - Top of Climb Thrust");
xlabel("Power Split (%)");
set(gca, "FontSize", 18);
grid on

% ratio of TOC thrust to SLS thrust
figure;
yyaxis left
plot(LambdaTko, TTOC ./ TSLS, "-o", "LineWidth", 2);
ylabel("T_{TOC} / T_{SLS}");
yyaxis right
plot(LambdaTko(2:end), 100 .* (TTOC(2:end) ./ TSLS(2:end) - TTOC(1) / TSLS(1)) / (TTOC(1) / TSLS(1)), "-o", "LineWidth", 2);
ylabel("Percent Difference (%)");

% format plot
title("Electrified Aircraft - Ratio of Top of Climb to SLS Thrust");
xlabel("Power Split (%)");
set(gca, "FontSize", 18);
grid on

% plot the important SFCs
figure;
hold on;
b = bar([TkoSFC; TkoSFC_EMT; TOCSFC; BegCruiseSFC; TODSFC; BegSFC; EndSFC]);

% add labels to the bars
for i = 1:4
    x = b(i).XEndPoints;
    y = b(i).YEndPoints;
    L = string(round(b(i).YData, 3));
    text(x, y, L, "HorizontalAlignment", "center", "VerticalAlignment", "bottom");
end

% format plot
title("Electrified Aircraft - In-Flight SFCs");
xlabel("Flight Phase");
ylabel("SFC (lbm/lbf/hr)");
grid on
legend("Conventional", "5% PHE", "7% PHE", "10% PHE");
xticks(1:7);
xticklabels(["Takeoff", "Takeoff with EM thrust", "Top of Climb", "Beginning of Cruise", "Top of Descent", "Start of Reserve", "End of Reserve"]);
set(gca, "FontSize", 18);
ylim([0, 0.9]);

% plot the fuel burn results
figure;
yyaxis left
plot(LambdaTko, TSLS_per_engine, "-o", "LineWidth", 2);
ylabel("SLS Thrust per engine");
yyaxis right
plot(LambdaTko(2:end), PercDiffSLSThrust, "-o", "LineWidth", 2);
ylabel("Percent Difference (%)");

% format plot
title("Electrified Aircraft - SLS Thrust per engine");
xlabel("Power Split (%)");
set(gca, "FontSize", 18);
grid on
%}
% ----------------------------------------------------------
 

figure;
plot(lams_clb, fburn)
xlabel("Climb Power Code")
ylabel("Fuel Burn(kg)")
hold on
yyaxis right
plot(lams_clb, batt)
ylabel("Battery Weight (kg)")

figure;
plot(lams_clb, fburn)
xlabel("Climb Power Code")
ylabel("Fuel Burn(kg)")
hold on
yyaxis right
plot(lams_clb, Energy./1e8)
ylabel("Battery Energy (MJ)")

%{
figure(2);
plot(lams_clb, SOC)
xlabel("Climb Power Code")
ylabel("SOC")
hold on
yyaxis right
plot(lams_clb, crate)
ylabel("crate")

[X,Y]= meshgrid(lams_tko, lams_clb);
figure(1);
hold on;
contourf(X, Y, fburn); % Points inside with color
xlabel('Tko EM Power Code (%)');
ylabel('Clb Power Split (%)');
title('HEA Fuel Weight (kg) Colormap');
grid on;
hold off;

figure(2);
hold on;
contourf(X, Y, batt); % Points inside with color
xlabel('Tko EM Power Code (%)');
ylabel('Clb Power Split (%)');
title('HEA Battery Weight (kg) Colormap');
grid on;
hold off;

figure(3);
hold on;
contourf(X, Y, SOC); % Points inside with color
xlabel('Tko EM Power Code (%)');
ylabel('Clb Power Split (%)');
title('Final SOC Val (%) Colormap');
grid on;
hold off;
%}
end