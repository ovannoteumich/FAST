function [] = ConstraintDiagram(InputAircraft)
%
% ConstraintDiagram.m
% written by Paul Mokotoff, prmoko@umich.edu
% adapted from code used in AEROSP 481 as a GSI
% last updated: 23 feb 2024
%
% create a constraint diagram (T/W-W/S for turbofans or P/W-W/S for
% turboprops/pistons).
%
% inputs : InputAircraft - function describing the aircraft configuration
% outputs: none
%


%% PRE-PROCESSING %%
%%%%%%%%%%%%%%%%%%%%

% close all figures
close all

% load the aircraft
Aircraft = InputAircraft;

% check if the directories exist
if (isfield(Aircraft.Settings, "Dir"))
    
    % check if the sizing directory is known
    if (~isfield(Aircraft.Settings.Dir, "Size"))
        
        % remember the sizing directory
        Aircraft.Settings.Dir.Size = pwd;
        
    end
    
else
    
    % remember the sizing directory
    Aircraft.Settings.Dir.Size = pwd;
    
end

% use regressions/projections to obtain more knowledge about the aircraft
Aircraft = MissionSegsPkg.SpecProcessing(Aircraft);


%% GET INFO ABOUT THE AIRCRAFT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the aircraft class
aclass = Aircraft.Specs.TLAR.Class;

% assume a wing-loading and thrust/power-loading to start
if      (strcmpi(aclass, "Turbofan" ) == 1)
    
    % get a thrust-loading to center the vertical axis about
    VertCent = Aircraft.Specs.Propulsion.T_W.SLS;
    
    % axis label should be t/w
    VertLabel = "Thrust-Weight Ratio (N/N)";
    
elseif ((strcmpi(aclass, "Turboprop") == 1) || ...
        (strcmpi(aclass, "Piston"   ) == 1) )
    
    % get a power-loading to center the vertical axis about
    VertCent = Aircraft.Specs.Power.P_W.SLS;
    
    % axis label should be p/w
    VertLabel = "Power-Weight Ratio (W/kg)";
    
else
    
    % throw error
    error("ERROR - ConstraintDiagram: invalid aircraft class.");
    
end

% get the wing-loading to center the horizontal axis
HoriCent = Aircraft.Specs.Aero.W_S.SLS;

% label the horizontal axis
HoriLabel = "Wing Loading (kg/m^2)";

% center the grids (+/- 100 for horizontal, +/- 150 for vertical)
HoriRange = linspace(max( 30, HoriCent - 100), min(1000, HoriCent +  60), 100);
VertRange = linspace(max( 10, VertCent - 150), min(1000, VertCent + 150), 100);

% create a grid of values
[HoriGrid, VertGrid] = meshgrid(HoriRange, VertRange);


%% ESTABLISH CONSTRAINTS WITH FARS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FARs are based on the aircraft class
if     (strcmpi(aclass, "Turbofan" ) == 1)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                            %
    % use FAR part 25 for all    %
    % turbofan aircraft          %
    %                            %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % takeoff field length
    
    % landing field length
    
    % takeoff climb: FAR 25.111
    
    % transition climb: FAR 25.121
    
    % second segment climb: FAR 25.121
    
    % enroute climb: FAR 25.121
    
    % balked landing climb (AEO): FAR 25.119
    
    % balked landing climb (OEI): FAR 25.121
    
    % service ceiling
    
    % cruise
    
    % there are 10 total constraints
    ncon = 10;
    
elseif ((strcmpi(aclass, "Turboprop") == 1) || ...
        (strcmpi(aclass, "Piston"   ) == 1) )
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                            %
    % use FAR part 23 for all    %
    % turboprop and piston       %
    % aircraft                   %
    %                            %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
    % takeoff climb
    g04 = ConstraintDiagramPkg.PropTkoClb(HoriGrid, VertGrid, Aircraft);
    
    % label the takeoff climb constraint
    L04 = sprintf("Initial Climb");
    
    % balked landing
    g02 = ConstraintDiagramPkg.PropLndClb(HoriGrid, VertGrid, Aircraft);
    
    % label the landing climb constraint
    L02 = sprintf("Balked Landing");
    
    % takeoff field length: FAR 23.2115
    g03 = ConstraintDiagramPkg.PropTko( HoriGrid, VertGrid, Aircraft);
    
    % label the takeoff field length constraint
    L03 = sprintf("Takeoff Field Length");
    
    % landing field length: FAR 23.2130
    g01 = ConstraintDiagramPkg.PropLnd( HoriGrid, VertGrid, Aircraft);
    
    % label the landing field length constraint
    L01 = sprintf("Landing\nField Length");
    
    % cruise
    g05 = ConstraintDiagramPkg.PropCruise(HoriGrid, VertGrid, Aircraft);
    
    % label the cruise constraint
    L05 = sprintf("Cruise");
    
    % service ceiling
    g06 = ConstraintDiagramPkg.PropCeil(HoriGrid, VertGrid, Aircraft);
    
    % label the takeoff field length constraint
    L06 = sprintf("Service Ceiling");
    
    % there are 6 total constraints
    ncon = 6;
    
else
    
    % throw error
    error("ERROR - ConstraintDiagram: invalid aircraft class.");
    
end


%% PLOT THE CONSTRAINTS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%

% create figure and maximize
figure;
set(gcf, "Position", get(0, "Screensize"));

% allow multiple contours to be plotted
hold on

% assume all points are feasible
set(gca, "Color", [0.0, 0.7, 0.1]);

% shade the infeasible region white using a colormap (0-1, not 0-256)
colormap([1.0, 1.0, 1.0]);

% memory for text positions
TextPos = zeros(ncon, 2);

% shade the infeasible region
for icon = 1:ncon
    
    % constraint name
    ConName = sprintf("g%02d", icon);
    
    % shade the infeasible region for the given constraint
    FilledContour = contourf(HoriGrid, VertGrid, eval(ConName), [0, Inf]);
    
    % get a position on the plot to leave text
    TextPos(icon, 1) = FilledContour(1, 16 * icon) + 1;
    TextPos(icon, 2) = FilledContour(2, 16 * icon) - 6;
   
end

% plot the constraint contours
for icon = 1:ncon
    
    % constraint name
    ConName = sprintf("g%02d", icon);
    
    % plot constraint contour
    contour(HoriGrid, VertGrid, eval(ConName), [0, 0], 'k-');
    
end

% add labels
for icon = 1:ncon
    
    % label name
    LabName = sprintf("L%02d", icon);
    
    % place the text
    text(TextPos(icon, 1), TextPos(icon, 2), eval(LabName), "FontSize", 14);
    
end

% turn on the hold
hold on

% add a point for the existing MQ-9 Reaper
scatter(235, 159.7, 48, "o", ...
        "MarkerFaceColor", "black", "MarkerEdgeColor", "black");
    
% add a point for the selected design point
scatter(235, 165, 48, "*", ...
        "MarkerFaceColor", "red", "MarkerEdgeColor", "red");
    
% add text for the above points
text(215, 163, "Actual MQ-9 \rightarrow", "FontSize", 14);
text(233, 176, "\it \bf \downarrow Selected Design Point", "FontSize", 14);

% add title
title("MQ-9 Reaper Constraint Diagram");

% add axis labels
xlabel(HoriLabel);
ylabel(VertLabel);

% add axis limits
xlim([HoriRange(1), HoriRange(end)]);
ylim([VertRange(1), VertRange(end)]);

% increase font size
set(gca, "FontSize", 18);

% ----------------------------------------------------------

end