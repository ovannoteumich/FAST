function DigraphThermal(ThermalSystem)
%
% DigraphThermal(Arches,node)
%
% This is a simple graphing function which makes a nice visual based on the
% architecture structure and an index or node.

% Set fig num to node num to mathc
fig = figure;
set(fig, 'Units', 'pixels', 'Position', [200, 200, 800, 600]);  % 800×600 pixels

% Extract Size
NComps = size(ThermalSystem.Arch,1);

% Add reverse connections too
Up = ThermalSystem.Arch;

% Initialize DownMatrix
Down = zeros(size(Up));

% Find where sinks should point back to sources
CompSums = sum(Up);
FirstInLoopInds = find(CompSums(1:NComps-4) == 0);

% Loop through and add those down connections
for ii = FirstInLoopInds(:)'
    SnkInd = ThermalPkg.ArchitecturePkg.TraceUpstream(Up,ii);
    Down(SnkInd,ii) = 1;
end

% Check Rez Pump Connections
if Up(end-3,end-1)
    Down(end-1,end-3) = 1;
end

% Check Amb Pump Connections
if Up(end-2,end)
    Down(end,end-2) = 1;
end


subplot(1,2,2)
% Digraph needs the binary arch index and the names of all the sources
graphout = digraph(Up + Down,ThermalSystem.CompNames);

% Plot the digraph
p = plot(graphout);
p.EdgeColor = [0.918, 0.722, 0]; % Corn
p.NodeColor = [0 0 0]; % Black Nodes
p.LineWidth = 1.2;

% Text formatting
p.MarkerSize = 6;                  % Larger node markers
p.NodeLabelColor = [0 0 0];        % Black text
title({"Thermal Architecture","With Cooling Flow"})
hold on

% Color Downstream connections blue for the cooling
for ii = 1:NComps
    for jj = 1:NComps
        if Down(ii,jj)
            highlight(p,ii,jj,'EdgeColor','b')
        end
    end
end

% Color Rez Pump Connections
if Up(end-3,end-1)
    highlight(p,NComps-3,NComps-1,'EdgeColor','r')
end

% Color Amb Pump Connections
if Up(end-2,end)
    highlight(p,NComps-2,NComps,'EdgeColor','r')
end


% Also show simplified version
subplot(1,2,1)
simplegraph = digraph(Up,ThermalSystem.CompNames);

% Plot the digraph
p2 = plot(simplegraph);
p2.EdgeColor = [0, 0, 0]; % Corn
p2.NodeColor = [0 0 0]; % Black Nodes
p2.LineWidth = 1.2;

% Text formatting
p2.MarkerSize = 6;                  % Larger node markers
p2.NodeLabelColor = [0 0 0];        % Black text
title({"Base Thermal Architecture"})
hold on


end