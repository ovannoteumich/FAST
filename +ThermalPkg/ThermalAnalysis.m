function [ThermalOut] = ThermalAnalysis(ThermalSystem)

ReturnSettings = [
    ThermalSystem.ReservoirPumpReturnSetting
    ThermalSystem.AmbientPumpReturnSetting
    ThermalSystem.ReservoirSetting
    ThermalSystem.AmbientSetting
    ];



% Find which srcs are connected to what temps to give inlet temps
CompSums = sum(ThermalSystem.Arch);
NComps = length(CompSums);

% Initialize components which are first in the loops by the temp of their
% destination
FirstInLoopInds = find(CompSums(1:NComps-4) == 0);

TempsIn = -ones(NComps,1);
TempsOut = -ones(NComps,1);

% Set input temperatures of components which receive coolant from after
% heat has been dumped
for FirstLoopCompInd = FirstInLoopInds

    % Call local function to do this for each source
    SnkInd = ThermalPkg.TraceUpstream(ThermalSystem.Arch,FirstLoopCompInd);

    % Adjust index because the Tempsettings dont include non sink comps
    TempsIn(FirstLoopCompInd) = ReturnSettings(SnkInd - (NComps - 4));
end


% If there is an ambient sink, set temp out to the ambient temperature
if any(ThermalSystem.Arch(:,end))
    TempsOut(end) = ReturnSettings(4);
end

% If there is a reservoir sink, set temp out to the reservoir temperature
if any(ThermalSystem.Arch(:,end-1))
    TempsOut(end-1) = ReturnSettings(3);
end

% If there is an ambient pump, set pump output and ambient input
if ThermalSystem.Arch(end-2,end)
    TempsIn(end) = ThermalSystem.AmbientPumpSinkSetting;
    TempsOut(end-2) = ThermalSystem.AmbientPumpSinkSetting;
end

% Set input to reservoir as the reservoir pump setting
if ThermalSystem.Arch(end-3,end-1)
    TempsIn(end-1) = ThermalSystem.ReservoirPumpSinkSetting;
    TempsOut(end-3) = ThermalSystem.ReservoirPumpSinkSetting;
end

% Assign unknown temps
for SinkIndices = NComps-1:NComps
    sendbackward(SinkIndices,ThermalSystem.Arch)
end





% Assign Outputs
ThermalOut.TempsIn = TempsIn;
ThermalOut.TempsOut = TempsOut;

% Create nice labeled cell
ThermalOut.Labeled = cell(length(TempsIn)+1,3);
ThermalOut.Labeled(1,1) = {"Component"};
ThermalOut.Labeled(1,2) = {"Inlet Temp"};
ThermalOut.Labeled(1,3) = {"Outlet Temp"};
ThermalOut.Labeled(2:end,1) = ThermalSystem.CompNames;

ThermalOut.Labeled(2:end,2) = num2cell(TempsIn(:));
ThermalOut.Labeled(2:end,3) = num2cell(TempsOut(:));

MissingInds = find(TempsIn == -1);
ThermalOut.Labeled(MissingInds+1,2:3) = {"Nonexistent"};





%% nested function which traces components backwards
    function sendbackward(ind,arch)
        % takes in a component index and an architecture

        % read in the global state vector


        % Find where the connection sends the coolant to
        ReceivingFrom = find(arch(:,ind) == 1);

        % if it doesnt send anywhere, return out of the function
        if isempty(ReceivingFrom)
            TempsOut = ThermalPkg.ToyHeatSource(ind,TempsIn,TempsOut);
            return
        end


        for SendingCompIndex = ReceivingFrom(:)'
            % then continue sending the coolant onward
            sendbackward(SendingCompIndex,arch)
        end


        % Mix coolant flows incoming to component
        TempsIn(ind) = sum(TempsOut(ReceivingFrom))./length(ReceivingFrom);

        % Update output temperature of current component
        TempsOut = ThermalPkg.ToyHeatSource(ind,TempsIn,TempsOut);




    end


end