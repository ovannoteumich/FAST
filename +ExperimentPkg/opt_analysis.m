% Create the first subplot
font = 12;
ax1 = subplot(4, 1, 1);
% Plot alt and TAS v time
plot(Aircraft.Mission.History.SI.Performance.Time, Aircraft.Mission.History.SI.Performance.Alt, "-k", 'LineWidth', 2);
ylabel("Alt (m)");
hold on;
yyaxis right;
plot(Aircraft.Mission.History.SI.Performance.Time, Aircraft.Mission.History.SI.Performance.TAS, "-b", 'LineWidth', 2);
ylabel("TAS (m/s)");
ax1.YColor = 'k'; 
yyaxis right; 
ax1.YColor = 'b'; 
set(ax1, "FontSize", font);

% Create the second subplot
ax2 = subplot(4, 1, 2);
hold on;
plot(Aircraft.Mission.History.SI.Performance.Time, Aircraft.Mission.History.SI.Power.LamUps(:,2), 'LineWidth', 1.5);
plot(Optttt.Mission.History.SI.Performance.Time, Optttt.Mission.History.SI.Power.LamUps(:,2), 'LineWidth', 1.5);
ylabel("GT PC (%)");
%legend("Cost", "Fuel kg", "Fuel E")
legend("OG HEA", "Opt HEA", 'FontSize', font);
set(ax2, "FontSize", font);

% Create the third subplot
ax3 = subplot(4, 1, 3);
hold on;
plot(Aircraft.Mission.History.SI.Performance.Time, Aircraft.Mission.History.SI.Power.LamUps(:,3), 'LineWidth', 1.5);
plot(Optttt.Mission.History.SI.Performance.Time, Optttt.Mission.History.SI.Power.LamUps(:,3), 'LineWidth', 1.5);
ylabel("EM PC (%)");
%legend("Case 1", "Case 2", "Case 3", 'FontSize', font);
set(ax3, "FontSize", font);

% Create the fourth subplot
ax4 = subplot(4, 1, 4);
hold on;
plot(Aircraft.Mission.History.SI.Performance.Time, Aircraft.Mission.History.SI.Power.SOC(:,2), 'LineWidth', 1.5);
plot(Optttt.Mission.History.SI.Performance.Time, Optttt.Mission.History.SI.Power.SOC(:,2), 'LineWidth', 1.5);
ylabel("SOC (%)");
xlabel("Time (hr)");
%legend("Case 1", "Case 2", "Case 3", 'FontSize', font);
set(ax4, "FontSize", font);

% Link the x-axes of all subplots explicitly
linkaxes([ax1, ax2, ax3, ax4], 'x');