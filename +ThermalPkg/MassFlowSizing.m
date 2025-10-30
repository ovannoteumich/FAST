function [ThermalSystem] = MassFlowSizing(ThermalSystem)


% Initialize Mass Flow to Something
ThermalSystem.Loops.MassFlow = ones(ThermalSystem.Loops.NumLoops,1);

% Set Thermal Tolerance
EPS06 = 1e-6;

% Assign Maximum Temperatures
ThermalSystem = ThermalPkg.AssignMaxTemps(ThermalSystem);

% Run an initial thermal analysis to start the loop
ThermalSystem = ThermalPkg.ThermalAnalysis(ThermalSystem);

% Do not size pump loops, gets done separately
NPumpLoops = sum(ThermalSystem.Arch(end-3:end-2,:),'all');

for jj = 1:ThermalSystem.Loops.NumLoops-NPumpLoops
    
    %  Reset large error each time
    Err = 1;

    while abs(Err) > EPS06

    % Components for the Coolant loop jj
    [Cols,~] = find(ThermalSystem.Loops.LoopIDs == jj);

    CurrentTemps = ThermalSystem.Analysis.TempsOut(Cols);
    MaxTemps = ThermalSystem.Analysis.MaxTemps(Cols);

    [LowestDiff,LDI] = min(MaxTemps - CurrentTemps);

    % Calculate Error
    Err = (LowestDiff)./MaxTemps(LDI);

    % Scale mass flow in the coolant loop we are interested in with a
    % simple fixed point scaling
    ThermalSystem.Loops.MassFlow(jj) = (1 - Err) * ThermalSystem.Loops.MassFlow(jj);
    
    % Rerun thermal analysis
    ThermalSystem = ThermalPkg.ThermalAnalysis(ThermalSystem);


    end

    

    

end


% Solve for mass flow in the pump loops if they exist
ThermalSystem = ThermalPkg.AssignPumpLoops(ThermalSystem);




end

