function [] = ConstraintDiagram(Aircraft)
%
% ConstraintDiagram.m
% written by Paul Mokotoff, prmoko@umich.edu
% adapted from code used in AEROSP 481 as a GSI
% last updated: 15 sep 2025
%
% create a constraint diagram (T/W-W/S for turbofans or P/W-W/S for
% turboprops/pistons) according to 14 CFR 23/25.
%
% INPUTS:
%     Aircraft - data structure of the aircraft to be analyzed.
%                size/type/units: 1-by-1 / struct / []
%
% OUTPUTS:
%     none
%


%% GET INFO ABOUT THE AIRCRAFT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the aircraft class
aclass = Aircraft.Specs.TLAR.Class;

% get the certification basis
CFRPart = Aircraft.Specs.TLAR.CFRPart;

% assume a wing-loading and thrust/power-loading to start
if      (strcmpi(aclass, "Turbofan" ) == 1)
    
    % get a thrust-loading to center the vertical axis about
    VertCent = Aircraft.Specs.Propulsion.T_W.SLS;
    
    % create a vertical range
    Vrange = linspace(max(0.10, VertCent - 0.20), min(0.80, VertCent + 0.20), 500);
    
    % axis label should be t/w
    VertLabel = "Thrust-Weight Ratio (N/N)";
    
elseif ((strcmpi(aclass, "Turboprop") == 1) || ...
        (strcmpi(aclass, "Piston"   ) == 1) )
        
    % get the power-weight ratio and convert to W/kg from kW/kg
    VertCent = Aircraft.Specs.Power.P_W.SLS .* 1000;
    
    % check which requirements are being used
    if (CFRPart == 25)
        
        % convert from W/kg to W/N
        VertCent = VertCent / 9.81;
        
        % convert from W/N to N/W
        VertCent = 1 / VertCent;
                
        % create a vertical range
        Vrange = linspace(max(0.01, VertCent - 0.25), min(0.2, VertCent + 0.15), 500);
        
        % define the axis label
        VertLabel = "Power Loading (N/W)";
        
        % re-invert to W/N and convert to N/N
        Vrange = 1 ./ Vrange .* 0.0167;
                        
    elseif (CFRPart == 23)
                
        % create a vertical range
        Vrange = linspace(max( 10, VertCent - 150), min(1000, VertCent + 150), 500);
        
        % axis label should be p/w
        VertLabel = "Power-Weight Ratio (W/kg)";
        
    else
        
        % throw an error
        error("ERROR - ConstraintDiagram: only 14 CFR Part 23 or 25 allowed, indicated by 23 or 25, respectively.");
        
    end
            
else
    
    % throw error
    error("ERROR - ConstraintDiagram: invalid aircraft class.");
    
end

% get the wing-loading to center the horizontal axis
HoriCent = Aircraft.Specs.Aero.W_S.SLS;

% label the horizontal axis
HoriLabel = "Wing Loading (kg/m^2)";

% center the grids (+/- 100 for horizontal, +/- 150 for vertical)
Hrange = linspace(max( 0, HoriCent - 1000), max(1000, HoriCent + 1000), 500);

% create a grid of values
[Hgrid, Vgrid] = meshgrid(Hrange, Vrange);


%% ESTABLISH CONSTRAINTS WITH FARS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% select the appropriate FARs
if (CFRPart == 25)
    
    % takeoff field length
    g01 = ConstraintDiagramPkg.JetTOFL(Hgrid, Vgrid, Aircraft);
    
    % add a label
    L01 = "TOFL";
    
    % landing field length
    g02 = ConstraintDiagramPkg.JetLFL(Hgrid, Vgrid, Aircraft);
    
    % add a label
    L02 = "LFL";
    
    % takeoff climb: FAR 25.111
    g03 = ConstraintDiagramPkg.Jet25_111(Hgrid, Vgrid, Aircraft);
    
    % add a label
    L03 = "25.111";
    
    % balked landing climb (AEO): FAR 25.119
    g04 = ConstraintDiagramPkg.Jet25_119(Hgrid, Vgrid, Aircraft);
    
    % add a label
    L04 = "25.119";
    
    % transition climb: FAR 25.121(a)
    g05 = ConstraintDiagramPkg.Jet25_121a(Hgrid, Vgrid, Aircraft);
    
    % add a label
    L05 = "25.121a";
    
    % second segment climb: FAR 25.121(b)
    g06 = ConstraintDiagramPkg.Jet25_121b(Hgrid, Vgrid, Aircraft);
    
    % add a label
    L06 = "25.121b";
    
    % enroute climb: FAR 25.121(c)
    g07 = ConstraintDiagramPkg.Jet25_121c(Hgrid, Vgrid, Aircraft);
    
    % add a label
    L07 = "25.121c";
        
    % balked landing climb (OEI): FAR 25.121(d)
    g08 = ConstraintDiagramPkg.Jet25_121d(Hgrid, Vgrid, Aircraft);
    
    % add a label
    L08 = "25.121d";
        
    % service ceiling
    g09 = ConstraintDiagramPkg.JetCeil(Hgrid, Vgrid, Aircraft);
    
    % add a label
    L09 = "Srv. Ceil.";
    
    % cruise
    g10 = ConstraintDiagramPkg.JetCrs(Hgrid, Vgrid, Aircraft);
    
    % add a label
    L10 = "Cruise";
    
    % there are 10 total constraints
    ncon = 10;
    
    % check for turboprop or piston aircraft
    if (strcmpi(aclass, "Turboprop") || strcmpi(aclass, "Piston"))
        
        % convert from N/N to W/N
        Vrange = Vrange ./ 0.0167;
        Vgrid  = Vgrid  ./ 0.0167;
        
        % invert to N/W
        Vrange = 1 ./ Vrange;
        Vgrid  = 1 ./ Vgrid ;
        
        % convert the horizontal grid and range to kN/m^2
        Hgrid  = Hgrid  .* 9.81 ./ 1000;
        Hrange = Hrange .* 9.81 ./ 1000;
                
    end
        
elseif (CFRPart == 23)
            
    % takeoff climb
    g04 = ConstraintDiagramPkg.PropTkoClb(Hgrid, Vgrid, Aircraft);
    
    % label the takeoff climb constraint
    L04 = sprintf("Initial Climb");
    
    % balked landing
    g02 = ConstraintDiagramPkg.PropLndClb(Hgrid, Vgrid, Aircraft);
    
    % label the landing climb constraint
    L02 = sprintf("Balked Landing");
    
    % takeoff field length: FAR 23.2115
    g03 = ConstraintDiagramPkg.PropTko(Hgrid, Vgrid, Aircraft);
    
    % label the takeoff field length constraint
    L03 = sprintf("Takeoff Field Length");
    
    % landing field length: FAR 23.2130
    g01 = ConstraintDiagramPkg.PropLnd(Hgrid, Vgrid, Aircraft);
    
    % label the landing field length constraint
    L01 = sprintf("Landing\nField Length");
    
    % cruise
    g05 = ConstraintDiagramPkg.PropCruise(Hgrid, Vgrid, Aircraft);
    
    % label the cruise constraint
    L05 = sprintf("Cruise");
    
    % service ceiling
    g06 = ConstraintDiagramPkg.PropCeil(Hgrid, Vgrid, Aircraft);
    
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

% create figure
figure;
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
    FilledContour = contourf(Hgrid, Vgrid, eval(ConName), [0, Inf]);
    
    % get a position on the plot to leave text
    TextPos(icon, 1) = FilledContour(1, 30 * icon);
    TextPos(icon, 2) = FilledContour(2, 30 * icon);
   
end

% plot the constraint contours
for icon = 1:ncon
    
    % constraint name
    ConName = sprintf("g%02d", icon);
    
    % plot constraint contour
    contour(Hgrid, Vgrid, eval(ConName), [0, 0], 'k-');
    
end

% add labels
for icon = 1:ncon
    
    % label name
    LabName = sprintf("L%02d", icon);
    
    % place the text
    text(TextPos(icon, 1), TextPos(icon, 2), eval(LabName), "FontSize", 14);
    
end

% add axis labels
xlabel(HoriLabel);
ylabel(VertLabel);

% add axis limits
xlim([Hrange(1), Hrange(end)]);
ylim([Vrange(1), Vrange(end)]);

% increase font size
set(gca, "FontSize", 18);

% ----------------------------------------------------------

end