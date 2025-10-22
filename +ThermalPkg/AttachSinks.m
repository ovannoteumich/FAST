function [CompleteArches] = AttachSinks(SinklessArches)

% Reach in fieldnames and length of architectures which need sinks (and
% heatpumps)
archnames = fieldnames(SinklessArches);
Narch = length(archnames);

% Initialize the output to an empty struct
CompleteArches = struct();

% Instantiate a Counter
counter = 1;

% Loop through sinkless architectures
for ii = 1:Narch

    % Bring in current architecture
    curarch = SinklessArches.(archnames{ii});

    % Find Inds where pumps are needed
    LoopEndInds = find(sum(curarch,2) == 0);

    % find number of pumps needed
    nloops = length(LoopEndInds);

    % for each they can all be connected to a either a reservoir pump or an
    % ambient pump, reservoir is
    Stem = [curarch, zeros(size(curarch,1),2)];
    Stem = [Stem;zeros(2,size(Stem,2))];



    assignpump(1,Stem)



end




    function assignpump(iter,localstem)



        % if at the limit, just return current arch and move on
        if iter > nloops
            CompleteArches.("Arch_"+counter) = addsink(localstem);
            counter = counter+1;
            return
        end

        % otherwise, loop through possibilities (assign to rez or to amb)
        % and then recurse

        % Go through each last row
        for jj = size(localstem,1)-1:size(localstem,1)
            % assign to rez
            localstem(LoopEndInds(iter),jj) = 1;
            assignpump(iter+1,localstem)
            localstem(LoopEndInds(iter),jj) = 0; % undo
        end

    end
end

function [ArchWithSinks] = addsink(arch)

% Check if there are rez and amb pumps
rezs = any(arch(:,end-1) == 1);
ambs = any(arch(:,end) == 1);

% Extract size of arch
N = size(arch,1);

% Add 2 columns and 2 rows
arch = [arch,zeros(N,2)];
arch = [arch; zeros(2,N+2)];

% If rezs, dump rez pump to rez sink
if rezs
    arch(end-3,end-1) = 1;
end

% If ambients, dump amb pump to amb sink
if ambs
    arch(end-2,end) = 1;
end

% Assign Output
ArchWithSinks = arch;




end



