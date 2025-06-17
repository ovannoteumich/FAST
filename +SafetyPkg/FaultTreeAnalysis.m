function [Pfail, FailModes] = FaultTreeAnalysis(Arch, Components, RemoveSrc)
%
% [Pfail, FailModes] = FaultTreeAnalysis(Arch, Components, RemoveSrc)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 27 may 2025
%
% Given an adjacency-like matrix, find the minimum cut sets that account
% for internal failures and redundant primary events. then, using the
% minimum cut sets, compute the system-level failure rate.
%
% INPUTS:
%     Arch       - the architecture matrix representing the system
%                  architecture to be analyzed.
%                  size/type/units: n-by-n / integer / []
%
%     Components - a structure array containing each component in the
%                  system architecture and the following information about
%                  it:
%                      a) the component name, a string
%                      b) the component type, a string
%                      c) a column vector of failure rates
%                      d) a column vector of failure modes corresponding to
%                         the failure rates
%                  size/type/units: 1-by-1 / struct / []
%
%     RemoveSrc  - a flag to indicate whether the sources should be removed
%                  from the system architecture (1) or not (0). if no
%                  argument is provided, the default is to not remove any
%                  components (0).
%                  size/type/units: 1-by-1 / integer / []
%
% OUTPUTS:
%     Pfail      - the probability that the system fails.
%                  size/type/units: 1-by-1 / double / []
%
%     FailModes  - string array of the different ways that the system
%                  architecture can fail.
%                  size/type/units: nfail-by-ncomp / string / []
%


%% CHECK FOR VALID INPUTS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% check the architecture     %
% matrix                     %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check that an architecture matrix was provided
if (nargin < 1)
    
    % throw an error
    error("ERROR - CreateFaultTree: the architecture matrix was not provided.");
    
end

% get the size of the architecture matrix
[nrow, ncol] = size(Arch);

% check the that number of rows and columns match
if (nrow ~= ncol)
    
    % throw an error
    error("ERROR - CreateFaultTree: architecture matrix must be square.");
    
end

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% check the component list   %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check that the component list was provided
if (nargin < 2)
    
    % throw an error
    error("ERROR - CreateFaultTree: component list was not provided.");
    
end

% get the number of components
ncomp = length(Components.Name);

% check that there are the same number of components as entries in matrix
if (ncomp ~= nrow)
    
    % throw an error
    error("ERROR - CreateFaultTree: number of compononents must match dimension of architecture matrix.");
    
end

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% check the flag             %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check if the "remove source" flag was included
if (nargin < 3)
    
    % if it isn't included, assume it should be 0
    RemoveSrc = 0;
    
end


%% PRE-PROCESSING %%
%%%%%%%%%%%%%%%%%%%%
    
% check for connections
ConnCheck = Arch > 0;

% count the number of input/output connections
ninput  = sum(ConnCheck, 1)';
noutput = sum(ConnCheck, 2) ;

% count the number of elements to trigger the gate
ntrigger = sum(Arch, 1)' ./ ninput;

% find the sources, sinks, and transmitters
isrc = find(ninput  == 0);
isnk = find(noutput == 0);

% get the number of sinks
nsnk = length(isnk);

% for a fault tree, there can only be one sink
if (nsnk > 1)
    
    % throw an error
    error("ERROR - CreateFaultTree: there are multiple sinks in the architecture matrix.");
    
end

% check if sources must be removed
if (RemoveSrc == 1)
    
    % remove their connections, but keep them in the matrix
    Arch(isrc, :) = 0; %#ok<*FNDSB>
    
end

% memory for finding connections
ArchConns = cell(ncomp, 1);

% remember the connections
for icomp = 1:ncomp
    
    % find the connections
    ArchConns{icomp} = find(Arch(:, icomp));
    
end


%% PERFORM A BOOLEAN ANALYSIS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% get all failure modes from %
% the system architecture    %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% recursively search the system architecture to extract all failure modes
FailModes = CreateCutSets(ArchConns, Components, isnk, ntrigger, ninput);

% eliminate duplicate events in single failure mode (idempotent law)
FailModes = IdempotentLaw(FailModes);

% eliminate duplicate events across failure modes (law of absorption)
FailModes = LawOfAbsorption(FailModes);


%% COMPUTE FAILURE RATE %%
%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the size of the failure modes
[nrow, ncol] = size(FailModes);

% allocate memory for the failure rates (allocate ones for ease of
% multiplying across rows in a later step)
FailRates = ones(nrow, ncol);

% loop through each component and add in its failure rate
for icomp = 1:ncomp
    
    % find the component in the failure modes
    idx = find(strcmpi(FailModes, Components.Name(icomp)));
    
    % fill in the failure rate
    FailRates(idx) = Components.FailRate(icomp);
    
end

% multiply failure rates in the given row
PfailIndiv = prod(FailRates, 2);

% add all failure rates together for the system-level failure rate
Pfail = sum(PfailIndiv);

% ----------------------------------------------------------

end

% ----------------------------------------------------------
% ----------------------------------------------------------
% ----------------------------------------------------------

function [Failures] = CreateCutSets(ArchConns, Components, icomp, ntrigger, ninput)
%
% [Failures] = CreateCutSets(Arch, Components, icomp, ntrigger, ninput)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 16 jun 2025
%
% List out all components in the cut set for a system architecture. For
% each function call, check whether an internal failure mode exists and if
% there are any downstream components that need to be considered in this
% cut set.
%
% INPUTS:
%     Arch       - the architecture matrix representing the system
%                  architecture to be analyzed.
%                  size/type/units: n-by-n / int / []
%
%     Components - a structure array containing each component in the
%                  system architecture and the following information about
%                  it:
%                      a) the component name, a string
%                      b) a column vector of failure rates
%                  size/type/units: 1-by-1 / struct / []
%
%     icomp      - the index of the component in the fault tree currently
%                  being assessed.
%                  size/type/units: 1-by-1 / integer / []
%
%     ntrigger   - number of components required to trigger the gate
%                  size/type/units: n-by-1 / integer / []
%
%     ninput     - number of components that input to the current
%                  component (or NaN if it is a source).
%                  size/type/units: n-by-1 / integer or NaN / []
%
% OUTPUTS:
%     Failures   - the matrix updated with all of the necessary failure
%                  modes after recursively searching the system
%                  architecture.
%                  size/type/units: m-by-p / string / []
%


%% CHECK FOR AN INTERNAL FAILURE %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the downstream components
idwn = ArchConns{icomp};

% check if there is an internal failure mode
if (~strcmpi(Components.FailMode(icomp), "") == 1)
    
    % add the component failure
    IntFails = Components.Name(icomp);
    
    % flag the failure
    FailFlag = 1;

else
    
    % no failure
    IntFails = [];
    
    % turn off the failure flag
    FailFlag = 0;

end


%% CHECK FOR DOWNSTREAM FAILURES %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the number of downstream components
ndwn = length(idwn);

% allocate memory
DwnFails = cell(1, ndwn);

% loop through the downstream components
for i = 1:ndwn
        
    % search recursively and remember the downstream failures
    DwnFails{i} = CreateCutSets(ArchConns, Components, idwn(i), ntrigger, ninput);

end

% enumerate the downstream failures, if any exist
if (ndwn > 0)
        
    if (ndwn == 1) % OR gate
        
        % the only failure is the downstream failure, it is an OR gate
        FinalFails = DwnFails{1};
        
    else % AND or K/N gate
        
        % check for an AND gate (# of trigger events matches # of inputs)
        if (ntrigger(icomp) == ninput(icomp))
        
            % enumerate all failures in the AND gate
            FinalFails = AndGate(DwnFails, ndwn);
            
        else % K/N GATE
            
            % remember the number of events to trigger
            mtrigger = ntrigger(icomp);
            
            % get the number of combinations
            ncomb = factorial(ndwn) / (factorial(mtrigger) * factorial(ndwn - mtrigger));
            
            % get the number of indices
            Idx = 1 : mtrigger;
            
            % cell array for downstream failures
            NewDwn = cell(1, mtrigger);
            
            % loop through each set of combinations
            for icomb = 1:ncomb

                % get current failures
                for itrigger = 1:mtrigger
                    NewDwn{itrigger} = DwnFails{Idx(itrigger)};
                end
                
                % enumerate the current failures
                if (mtrigger == 1)
                    
                    % there is only one failure, do not use an AND gate
                    CurFails = NewDwn{itrigger};
                    
                else
                    
                    % use an AND gate to get all possible failures
                    CurFails = AndGate(NewDwn, mtrigger);
                    
                end
                
                % add one to the final index
                Idx(end) = Idx(end) + 1;
                
                % add a dummy index
                dummy = 0;
                
                % loop through all indices
                for itrigger = mtrigger : -1 : 2
                    
                    % check if a current index exceeds its limit
                    if (Idx(itrigger) > (ndwn - dummy))
                        
                        % increment the prior index
                        Idx(itrigger - 1) = Idx(itrigger - 1) + 1;
                        
                        % reset indices beyond this one
                        if (dummy > 0)
                            Idx(itrigger:end) = Idx(itrigger - 1) + (1 : (mtrigger - itrigger + 1));
                        else
                            Idx(end) = Idx(itrigger - 1) + 1;
                        end
                        
                    end
                    
                    % incremement the dummy index
                    dummy = dummy + 1;
                    
                end
            
                % append the current failures to the final ones
                if (icomb == 1)
                    
                    % remember the current failures
                    FinalFails = CurFails;
                    
                else
                    
                    % get the size of each failure
                    [nrow1, ncol1] = size(FinalFails);
                    [nrow2, ncol2] = size(  CurFails);
                    
                    % check for the larger array
                    if (ncol1 > ncol2)
                        
                        % add more empty columns to CurFails
                        FinalFails = [FinalFails; CurFails, strings(nrow2, ncol1 - ncol2)];
                        
                    elseif (ncol1 < ncol2)
                        
                        % add more empty columns to FinalFails
                        FinalFails = [FinalFails, strings(nrow1, ncol2 - ncol1); CurFails];
                        
                    else
                        
                        % they are the same size, just append arrays
                        FinalFails = [FinalFails; CurFails];
                        
                    end                    
                end
                
                % simplify with the idempotent law
                FinalFails = IdempotentLaw(FinalFails);
                
                % simplify with the law of absorption
                FinalFails = LawOfAbsorption(FinalFails);
                
            end
        end            
    end
    
    % get the size of the downstream failures
    [~, ncol] = size(FinalFails);
    
    % add columns and append downstream failures
    if (FailFlag == 1)
        Failures = [FinalFails; IntFails, strings(1, ncol - FailFlag)];
        
    else
        Failures = FinalFails;
        
    end
    
else
    
    % return only the internal failures
    Failures = IntFails;
    
end


end

% ----------------------------------------------------------
% ----------------------------------------------------------
% ----------------------------------------------------------

function [FinalFails] = AndGate(DwnFails, ndwn)
%
% [FinalFails] = AndGate(DwnFails, ndwn)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 17 jun 2025
%
% enumerate all failures from the downstream inputs, simplifying as pairs
% of failures are enumerated to reduce the problem size.
%
% INPUTS:
%     DwnFails   - the set of downstream failures for each input into the
%                  current component.
%                  size/type/units: 1-by-ndwn / cell / []
%
%     ndwn       - number of downstream components that connect to the
%                  current one.
%                  size/type/units: 1-by-1 / integer / []
%
% OUTPUTS:
%     FinalFails - array of all possible failures after enumeration and
%                  simplification.
%                  size/type/units: m-by-p / string / []
%

% remove any downstream failures that are empty
for idwn = 1:ndwn
    
    % check for an empty set of failures
    if (isempty(DwnFails{idwn}))
        
        % cannot enumerate, failures are missing
        FinalFails = [];
        
        % exit the code
        return
        
    end
end

% get the first sets of failures
TempFails = {DwnFails{1}, DwnFails{2}};

% loop through and enumerate each failure
for i = 2:ndwn
    
    % make sure both entries are not empty
    if (~isempty(TempFails{1})) && (~isempty(TempFails{2}))
        
        % enumerate the failures
        FinalFails = EnumerateFailures(TempFails);
        
        % for the first time, evaluate all columns
        if (i == 2)
            FinalFails = IdempotentLaw(FinalFails);
            
        else
            FinalFails = IdempotentLaw(FinalFails, ColIdx);
            
        end
        
        % simplify
        FinalFails = LawOfAbsorption(FinalFails);
        
    elseif (isempty(TempFails{1}))
        
        % keep only the second set of failures
        FinalFails = TempFails{2};
        
    elseif (isempty(TempFails{2}))
        
        % keep only the first set of failures
        FinalFails = TempFails{1};
        
    end
    
    % check if we're done
    if (i < ndwn)
        
        % add the next failure
        TempFails = {FinalFails, DwnFails{i+1}};
        
        % get the number of columns in the array
        [~, ColIdx] = size(FinalFails);
        
        % start reducing at the following column
        ColIdx = ColIdx + 1;
        
    end
end

% ----------------------------------------------------------

end

% ----------------------------------------------------------
% ----------------------------------------------------------
% ----------------------------------------------------------

function [EnumFails] = EnumerateFailures(FailList)
%
% [EnumFails] = EnumerateFailures(FailList)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 23 apr 2025
%
% Given a set of failures from multiple AND gates, enumerate all possible
% failures that could cause a system failure.
%
% INPUTS:
%     FailList  - an array of possible failures from each part of an AND
%                 gate. all failures from a single part of the AND gate
%                 must be in a column vector.
%                 size/type/units: m-by-n / string / []
%
% OUTPUTS:
%     EnumFails - an array of enumerated failures that could cause the
%                 system to fail.
%                 size/type/units: p-ny-n / string / []
%


%% SETUP FOR ENUMERATION %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the number of elements in the input array
[~, nelem] = size(FailList);

% remember the number of rows/columns required
nrow = zeros(1, nelem);
ncol = zeros(1, nelem);

% compute the maximum number of elements in a column
for ielem = 1:nelem
    
    % get the size of the string array
    [nrow(ielem), ncol(ielem)] = size(FailList{ielem});
    
end

% get the total number of rows and columns required
mrow = prod(nrow);
mcol =  sum(ncol);

% allocate memory for the output array
EnumFails = strings(mrow, mcol);


%% ENUMERATE %%
%%%%%%%%%%%%%%%

% keep track of the column index
ColIdx = 0;

% loop through each set of components
for ielem = 1:nelem
    
    % get the current failure
    CurFail = FailList{ielem};
    
    % number of times the matrix must repeat
    nrep1 = prod(nrow(ielem+1:end));
    
    % number of times the repeated matrix repeats
    nrep2 = prod(nrow(1:ielem-1));
            
    % loop through all columns
    for icol = 1:ncol(ielem)
        
        % repeatedly represent the matrix elements
        TempCol = repelem(CurFail(:, icol), nrep1);
        
        % repeatedly represent the column
        EnumFails(:, ColIdx + icol) = repmat(TempCol, nrep2, 1);
        
    end
    
    % update the column index
    ColIdx = ColIdx + ncol(ielem);
    
end


end

% ----------------------------------------------------------
% ----------------------------------------------------------
% ----------------------------------------------------------

function [NewModes] = IdempotentLaw(FailModes, SplitCol)
%
% [NewModes] = IdempotentLaw(FailModes)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 28 apr 2025
%
% use the idempotent law to eliminate duplicate events in a single failure
% mode of a fault tree. the idempotent law is a boolean algebra rule,
% stating that: X * X = X
%
% INPUTS:
%     FailModes - matrix of required failures for the system to fail. each
%                 row represents a single failure mode.
%                 size/type/units: m-by-n / string / []
%
% OUTPUTS:
%     NewModes  - updated matrix after the idempotent law is applied. the
%                 number of columns returned may be reduced due to the
%                 simplifications (i.e., p <= n).
%                 size/type/units: m-by-p / string / []
%


%% PRE-PROCESSING %%
%%%%%%%%%%%%%%%%%%%%

% get the number of failure modes and maximum number of comopnents
[nmode, ncomp] = size(FailModes);

% check if two arguments are given
if (nargin < 2)
    SplitCol = 0;
end


%% BOOLEAN ALGEBRA SIMPLIFICATION %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check if there is a column to split at
if (SplitCol > 0)
    OutIdx =  1 : SplitCol - 1        ;
    InrIdx = @(x) SplitCol     : ncomp;
    
else
    OutIdx =          1 : ncomp - 1;
    InrIdx = @(x) x + 1 : ncomp    ;
    
end

% loop through all columns except the last one
for icomp = OutIdx % formerly 1:(ncomp-1)
    
    % remember the current column
    TempCol = FailModes(:, icomp);
        
    % loop through remaining columns
    for jcomp = InrIdx(icomp) % formerly (icomp+1):ncomp
        
        % compare elements in the columns
        FailModes(:, jcomp) = CompareCols(TempCol, FailModes(:, jcomp));

    end
end


%% POST-PROCESSING %%
%%%%%%%%%%%%%%%%%%%%%

% get the maximum number of components now used
ncomp = max(sum(~strcmpi(FailModes, ""), 2));

% create a new array for returning values
NewModes = strings(nmode, ncomp);

% loop through each row
for imode = 1:nmode
    
    % get the remaining components
    CompsLeft = ~strcmpi(FailModes(imode, :), "");
    
    % get the number of components remaining
    ncomp = sum(CompsLeft);
    
    % remember the remaining components
    NewModes(imode, 1:ncomp) = FailModes(imode, CompsLeft);
    
end


end

% ----------------------------------------------------------
% ----------------------------------------------------------
% ----------------------------------------------------------

function [Col2] = CompareCols(Col1, Col2)
%
% [Col2] = CompareCols(Col1, Col2)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 23 apr 2025
%
% for the elements in Col2 that match those in Col1, set them to be an
% empty string. this is a helper function for performing a fault tree
% analysis in parallel.
%
% INPUTS:
%     Col1 - first  column to be compared.
%            size/type/units: n-by-1 / string / []
%
%     Col2 - second column to be compared.
%            size/type/units: n-by-1 / string / []
%
% OUTPUTS:
%     Col2 - updated column with empty strings.
%            size/type/units: n-by-1 / string / []
%

% compare the two columns
StrCmp = strcmpi(Col1, Col2);

% remove the ones that match
Col2(StrCmp, :) = "";

end

% ----------------------------------------------------------
% ----------------------------------------------------------
% ----------------------------------------------------------

function [NewModes] = LawOfAbsorption(FailModes)
%
% [NewModes] = LawOfAbsorption(FailModes)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 28 apr 2025
%
% use the law of absorbption to eliminate duplicate events across multiple
% failure modes in a fault tree. the law of absorbption is a boolean
% algebra rule stating that:
%     a) X * (X + Y) = X
%     b) X +  X * Y  = X
%
% INPUTS:
%     FailModes - matrix of required failures for the system to fail. each
%                 row represents a single failure mode.
%                 size/type/units: m-by-n / string / []
%
% OUTPUTS:
%     NewModes  - updated matrix after the law of absorbptiion is applied.
%                 the number of rows and columns returned may be reduced
%                 due to the simplifications (i.e., p <= m and q <= n).
%                 size/type/units: p-by-q / string / []
%


%% PRE-PROCESSING %%
%%%%%%%%%%%%%%%%%%%%

% find the maximum number of failure modes and components in a failure
[nfail, ncomp] = size(FailModes);


%% BOOLEAN ALGEBRA SIMPLIFICATION %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% use failure modes with icomp components to simplify more complex events
for icomp = 1:ncomp
   
    % compute the sum of the rows ahead of time
    RowSum = sum(~strcmpi(FailModes, ""), 2);
    
    % get the index of the failure modes with icomp components
    Baseline = find(RowSum == icomp);
    
    % get the number of failure modes in the baseline
    nmode = length(Baseline);
    
    % check if any exist
    if (nmode == 0)
        
        % continue on
        continue
        
    end
    
    % loop through all the failure modes
    for imode = 1:nmode
       
        % get the failure
        CurMode = FailModes(Baseline(imode), 1:icomp);
        
        % check if the current mode has any failure modes left
        if (sum(strcmpi(CurMode, ""), 2) == icomp)
            continue;
        end
                
        % get the current failure index
        CurIdx = Baseline(imode);
        
        % loop through all failure modes
        for ifail = 1:nfail
            
            % check if failure mode is used for comparison
            if (ifail == CurIdx)
                
                % continue on
                continue;
                
            end
            
            % look for common components
            CheckCommon = matches(FailModes(ifail, :), CurMode);
            
            % check if the current failure is within other failures
            if (sum(CheckCommon) == icomp)
            
                % a failure mode is shared - eliminate the current one
                FailModes(ifail, :) = "";
            
            end                
        end
    end
end


%% POST-PROCESSING %%
%%%%%%%%%%%%%%%%%%%%%

% check if any of the rows are empty
KeepRow = any(~strcmpi(FailModes, ""), 2);

% check if any of the cols are empty
KeepCol = any(~strcmpi(FailModes, ""), 1);

% use only the columns with failure modes in them
NewModes = FailModes(KeepRow, KeepCol);


end