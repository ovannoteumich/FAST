function [ThermalSystem] = AssignLoopNumbers(ThermalSystem)
%ASSIGNLOOPNUMBERS Summary of this function goes here


Arch = ThermalSystem.Arch;
NComps = size(Arch,1);

StartingComps = find(sum(Arch(1:end-4,1:end-4)) == 0);

LoopCounter = 1;

LoopIDs = zeros(NComps,NComps);

for ii = StartingComps(:)'
    followcomponent(ii)
    LoopCounter = LoopCounter+1;
end

NumLoops = length(StartingComps);

% If there is a fuel heat pump, add the loop and the ID for the pump
if sum(Arch(:,end-3))
    NumLoops = NumLoops+1;
    LoopIDs(end-3,end-1) = LoopCounter;
    LoopCounter = LoopCounter+1;
end

% If there is an air ambient pump, add the loop and the ID for the pump
if sum(Arch(:,end-2))
    NumLoops = NumLoops+1;
    LoopIDs(end-2,end) = LoopCounter;
    LoopCounter = LoopCounter+1;
end



% Build labeled cell matrix
Labeled = cell(NComps+1,NComps+1);
Labeled(1,1) = {"Component"};
Labeled(2:end,1) = ThermalSystem.CompNames(:);
Labeled(1,2:end) = ThermalSystem.CompNames(:)';

% Assign LoopID matrix
Labeled(2:end,2:end) = num2cell(LoopIDs);

% Remove no connections from nice labeled loops
for ii = 2:size(LoopIDs)+1
    for jj = 2:size(LoopIDs)+1
        if Labeled{ii,jj} == 0
            Labeled{ii,jj} = '';
        end
    end
end


% Assign Outputs
ThermalSystem.Loops.NumLoops = NumLoops;
ThermalSystem.Loops.LoopIDs = LoopIDs;
ThermalSystem.Loops.Labeled = Labeled;

% Function to asssign loop ID
    function followcomponent(ind)

        SendingTo = find(Arch(ind,:) == 1);
        LoopIDs(ind,SendingTo) = LoopCounter;

        %         if SendingTo == NComps-3 || SendingTo == NComps -2
        %             LoopIDs(SendingTo,SendingTo+2) = LoopCounter+1;
        %             LoopCounter = LoopCounter+1;
        %             return
        %         elseif SendingTo == NComps-1 || SendingTo == NComps
        %             LoopCounter = LoopCounter +1;
        %             return
        %         end
        if SendingTo > NComps-4
            return
        end

        followcomponent(SendingTo)
    end

end
