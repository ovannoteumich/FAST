function [ThermalSystem] = ThermalAnalysis(ThermalSystem)

ReturnSettings = [
    ThermalSystem.Settings.Coolant.FuelPumpReturn
    ThermalSystem.Settings.Coolant.AmbientPumpReturn
    ThermalSystem.Settings.Coolant.Fuel
    ThermalSystem.Settings.Coolant.Ambient
    ];



% Find which srcs are connected to what temps to give inlet temps
CompSums = sum(ThermalSystem.Arch);
NComps = length(CompSums);

ThermalSystem.Analysis.ReqMDot = zeros(NComps,1);

% Initialize components which are first in the loops by the temp of their
% destination
FirstInLoopInds = find(CompSums(1:NComps-4) == 0);

ThermalSystem.Analysis.TempsIn = -ones(NComps,1);
ThermalSystem.Analysis.TempsOut = -ones(NComps,1);

% Set input temperatures of components which receive coolant from after
% heat has been dumped
for FirstLoopCompInd = FirstInLoopInds(:)'

    % Call local function to do this for each source
    SnkInd = ThermalPkg.ArchitecturePkg.TraceUpstream(ThermalSystem.Arch,FirstLoopCompInd);

    % Adjust index because the Tempsettings dont include non sink comps
    ThermalSystem.Analysis.TempsIn(FirstLoopCompInd) = ReturnSettings(SnkInd - (NComps - 4));
end


% If there is an ambient sink, set temp out to the ambient temperature
if any(ThermalSystem.Arch(:,end))
    ThermalSystem.Analysis.TempsOut(end) = ThermalSystem.Settings.Coolant.Ambient;
end

% If there is a reservoir sink, set temp out to the reservoir temperature
if any(ThermalSystem.Arch(:,end-1))
    ThermalSystem.Analysis.TempsOut(end-1) = ThermalSystem.Settings.Coolant.Fuel;
end

% If there is an ambient pump, set pump output and ambient input
if ThermalSystem.Arch(end-2,end)
    ThermalSystem.Analysis.TempsIn(end) = ThermalSystem.Settings.Coolant.AmbientPumpSink;
    ThermalSystem.Analysis.TempsOut(end-2) = ThermalSystem.Settings.Coolant.AmbientPumpSink;
end

% Set input to reservoir as the reservoir pump setting
if ThermalSystem.Arch(end-3,end-1)
    ThermalSystem.Analysis.TempsIn(end-1) = ThermalSystem.Settings.Coolant.FuelPumpSink;
    ThermalSystem.Analysis.TempsOut(end-3) = ThermalSystem.Settings.Coolant.FuelPumpSink;
end

% Assign unknown temps
for SinkIndices = NComps-1:NComps
    sendbackward(SinkIndices,ThermalSystem.Arch)
end





% Assign Outputs


% Create nice labeled cell
ThermalSystem.Analysis.Labeled = cell(length(ThermalSystem.Analysis.TempsIn)+1,3);
ThermalSystem.Analysis.Labeled(1,1) = {"Component"};
ThermalSystem.Analysis.Labeled(1,2) = {"Inlet Temp"};
ThermalSystem.Analysis.Labeled(1,3) = {"Outlet Temp"};
ThermalSystem.Analysis.Labeled(2:end,1) = ThermalSystem.CompNames;

ThermalSystem.Analysis.Labeled(2:end,2) = num2cell(ThermalSystem.Analysis.TempsIn(:));
ThermalSystem.Analysis.Labeled(2:end,3) = num2cell(ThermalSystem.Analysis.TempsOut(:));

MissingInds = find(ThermalSystem.Analysis.TempsIn == -1);
ThermalSystem.Analysis.Labeled(MissingInds+1,2:3) = {"Nonexistent"};





%% nested function which traces components backwards
    function sendbackward(ind,arch)
        % takes in a component index and an architecture


        % Find where the connection sends the coolant to
        ReceivingFrom = find(arch(:,ind) == 1);

        % if it doesnt send anywhere, return out of the function
        if isempty(ReceivingFrom)
            ThermalSystem = ThermalPkg.HeatSourceSwitch(ind,ThermalSystem);
            return
        end


        for SendingCompIndex = ReceivingFrom(:)'
            % then continue sending the coolant onward
            sendbackward(SendingCompIndex,arch)
        end


        % Mix coolant flows incoming to component
        IncomingLoopInds = ThermalSystem.Loops.LoopIDs(ReceivingFrom,ind);

        % Get masses of incoming flows
        Masses = ThermalSystem.Loops.MassFlow(IncomingLoopInds);
        Masses = Masses(:);

        % Get temperatures
        Temps = ThermalSystem.Analysis.TempsOut(ReceivingFrom);
        Temps = Temps(:);
        
        % Calculate total enthalpy (TODO: add in different cp values for
        % different loops) this currently assumes same coolant in all loops
        TotalEnthalpy = sum(Masses .* Temps);

        % Assign Output
        ThermalSystem.Analysis.TempsIn(ind) = TotalEnthalpy / sum(Masses);

        % Update output temperature of current component
        ThermalSystem = ThermalPkg.HeatSourceSwitch(ind,ThermalSystem);



    end


end