function UpStreamStruct = OrderComponents(LoopsUnordered, UpStreamStem)
% BuildUpStreams generates all possible upstream connection matrices
% from a set of unordered component loops.
%
% Each loop defines components that must connect to a common outlet.
% The function explores every possible permutation of those components
% to produce all valid upstream architectures, stored as matrices.
%
% Inputs:
%   LoopsUnordered - cell array, each cell contains component indices for a loop
%   UpStreamStem   - base connectivity matrix (e.g., zeros)
%
% Output:
%   UpStreamStruct - struct containing all generated connection matrices
%
% Example:
%   BuildUpStreams({['12'], ['23']}, zeros(3))
%   → returns UpStreamStruct.Arch_1, Arch_2, ... with different connection paths

nLoops = numel(LoopsUnordered);
counter = 1;  % counts architectures

% Iterate through each loop definition
for k = 1:nLoops
    exploreLoop(1, UpStreamStem, LoopsUnordered{k});
end

%-------------------------------------------------------
% Recursive function to build connection permutations
%-------------------------------------------------------
    function exploreLoop(iter, stemMatrix, currentLoop)
        if iter > numel(currentLoop)
            % Base case: all elements in loop placed
            UpStreamStruct.("Arch_" + counter) = stemMatrix;
            counter = counter + 1;
            return
        end

        % Current element (as characters)
        indices = perms(char(currentLoop(iter)));
        [nPerms, nCols] = size(indices);

        % Loop through all permutations
        for p = 1:nPerms
            newStem = stemMatrix;

            % Connect this permutations indicies
            if nCols == 1
                %newStem(str2double(indices(p, 1)), end) = 1;  % connect to outlet
            else
                for c = 1:nCols-1
                    newStem(str2double(indices(p, c)), str2double(indices(p, c+1))) = 1;
                end
                %newStem(str2double(indices(p, nCols)), end) = 1;  % final connection to outlet
            end

            % Recurse to handle next component
            exploreLoop(iter + 1, newStem, currentLoop);
        end
    end
end
