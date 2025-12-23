function [] = RegionalTurbopropPlots()
%
% [] = RegionalTurbopropPlots()
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 23 dec 2025
%
% create the necessary mission profile plots for each configuration:
%     a) (distributed) turboelectric - altitude profile
%     b  hybrid turboelectric - altitude and SOC profiles
%
% INPUTS:
%     none
%
% OUTPUTS:
%     none
%

% initial cleanup
clc, close all


%% LOAD THE DATA %%
%%%%%%%%%%%%%%%%%%%

% load the .mat file
ACData = load("SizedRegionalTurboprops.mat");

% get each configuration
 TE = ACData.TE ;
HTE = ACData.HTE;
DTE = ACData.DTE;


%% ACCESS PERFORMANCE/POWER DATA %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% shorthand for accessing performance data
PerfTE  =  TE.Mission.History.SI.Performance;
PerfHTE = HTE.Mission.History.SI.Performance;
PerfDTE = DTE.Mission.History.SI.Performance;

% get the time and convert to minutes from seconds
TimeTE  =  PerfTE.Time ./ 60;
TimeHTE = PerfHTE.Time ./ 60;
TimeDTE = PerfDTE.Time ./ 60;

% get the altitude for each aircraft
AltTE  =  PerfTE.Alt;
AltHTE = PerfHTE.Alt;
AltDTE = PerfDTE.Alt;

% get the hybrid turboelectric's SOC
SOC = HTE.Mission.History.SI.Power.SOC(:, 2);


%% ACCESS WEIGHT DATA %%
%%%%%%%%%%%%%%%%%%%%%%%%

% shorthand for accessing weight data
WtTE  =  TE.Specs.Weight;
WtHTE = HTE.Specs.Weight;
WtDTE = DTE.Specs.Weight;

% get the weights
WeightTE  = [WtTE.Crew;  WtTE.Payload;  WtTE.Airframe;  WtTE.Engines; ...
             WtTE.EG;    WtTE.EM;       WtTE.Fuel;     WtTE.Batt];

WeightHTE = [WtHTE.Crew; WtHTE.Payload; WtHTE.Airframe; WtHTE.Engines; ...
             WtHTE.EG;   WtHTE.EM;      WtHTE.Fuel;    WtHTE.Batt];

WeightDTE = [WtDTE.Crew; WtDTE.Payload; WtDTE.Airframe; WtDTE.Engines; ...
             WtDTE.EG;   WtDTE.EM;      WtDTE.Fuel;    WtDTE.Batt];


%% WEIGHT BREAKDOWN - BAR PLOT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create a figure
figure;

% assemble the weights into one array
Weight = [WeightTE, WeightHTE, WeightDTE]';

% plot the weight breakdown
b = bar(Weight, "stacked");

% title the plot
ylabel("Weight (kg)");

% add labels
set(gca, "xticklabels", ["TE", "HTE", "DTE"]);

% add a legend
legend("Crew", "Payload", "Airframe", "Engine", "EG", "EM", "Fuel", "Battery", "Location", "eastoutside");

% add colors
b(1).FaceColor = repmat([1.0000, 1.0000, 1.0000], 1, 1);
b(2).FaceColor = repmat([0.0000, 0.4470, 0.7410], 1, 1);
b(3).FaceColor = repmat([0.8500, 0.3250, 0.0980], 1, 1);
b(4).FaceColor = repmat([0.9290, 0.6940, 0.1250], 1, 1);
b(5).FaceColor = repmat([0.4940, 0.1840, 0.5560], 1, 1);
b(6).FaceColor = repmat([0.4660, 0.6740, 0.1880], 1, 1);
b(7).FaceColor = repmat([0.3010, 0.7450, 0.9330], 1, 1);
b(8).FaceColor = repmat([0.6350, 0.0780, 0.1840], 1, 1);
b(1).EdgeColor = repmat([0.0000, 0.0000, 0.0000], 1, 1);
b(2).EdgeColor = repmat([0.0000, 0.4470, 0.7410], 1, 1);
b(3).EdgeColor = repmat([0.8500, 0.3250, 0.0980], 1, 1);
b(4).EdgeColor = repmat([0.9290, 0.6940, 0.1250], 1, 1);
b(5).EdgeColor = repmat([0.4940, 0.1840, 0.5560], 1, 1);
b(6).EdgeColor = repmat([0.4660, 0.6740, 0.1880], 1, 1);
b(7).EdgeColor = repmat([0.3010, 0.7450, 0.9330], 1, 1);
b(8).EdgeColor = repmat([0.6350, 0.0780, 0.1840], 1, 1);

% add a grid
grid on

% loop over each element in the bar plot
for k = 1:numel(b)
    
    % get the position of the bar
    xpos = b(k).XEndPoints;
    ypos = b(k).YEndPoints;

    % get the bar height
    ydata = b(k).YData;

    % get the bottom of the bar
    ybot = ypos - ydata;

    % loop through each bar
    for i = 1:numel(xpos)
        
        % label placement for "large" bars
        if (ydata(i) > 500)
            
            % place the label in the middle of the bar
            text(xpos(i), ybot(i) + ydata(i) / 2, sprintf("%.0f kg", ydata(i)), ...
                "HorizontalAlignment", "center", "VerticalAlignment", "middle", ...
                "FontSize", 10);
            
        elseif (ydata(i) > 0)
            
            % place the label above the bar
            text(xpos(i), ypos(i), sprintf("%.0f kg", ydata(i)), ...
                "HorizontalAlignment", "center", "VerticalAlignment", "bottom", ...
                "FontSize", 10);
                
        end
    end
end

% increase the font size
set(gca, "FontSize", 18);


%% MISSION PROFILE - TE %%
%%%%%%%%%%%%%%%%%%%%%%%%%%

% create a figure
figure;

% plot altitude against time for the TE configuration
plot(TimeTE, AltTE, "-", "LineWidth", 2);

% format plot
xlabel("Flight Time (min.)");
ylabel("Altitude (m)");
title("TE Configuration");
grid on

% change font size
set(gca, "FontSize", 18);


%% MISSION PROFILE - HTE %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create a figure
figure;

% plot altitude against time for the HTE configuration
plot(TimeHTE, AltHTE, "-", "LineWidth", 2);

% format plot
xlabel("Flight Time (min.)");
ylabel("Altitude (m)");
title("HTE Configuration");
grid on

% change font size
set(gca, "FontSize", 18);


%% MISSION PROFILE - DTE %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create a figure
figure;

% plot altitude against time for the TE configuration
plot(TimeDTE, AltDTE, "-", "LineWidth", 2);

% format plot
xlabel("Flight Time (min.)");
ylabel("Altitude (m)");
title("DTE Configuration");
grid on

% change font size
set(gca, "FontSize", 18);


%% SOC PROFILE - HTE %%
%%%%%%%%%%%%%%%%%%%%%%%

% create a figure
figure;

% plot SOC against time for the HTE configuration
plot(TimeHTE, SOC, "-", "LineWidth", 2);

% format plot
xlabel("Flight Time (min.)");
ylabel("SOC (%)");
grid on

% change font size
set(gca, "FontSize", 18);

% ----------------------------------------------------------

end