function parts = Partitions(items)
% Partitions generates all possible ways to group the given items into sets.
% Each result is a partition showing how the items can be divided into one
% or more groups, while keeping their order within each group.
%
% It works by using recursion and backtracking:
% - Starting from the first item, it tries every possible way to either
%   (1) add the item to an existing group, or
%   (2) start a new group with that item.
% - It continues this process for all items, and when all have been placed,
%   the current grouping is saved as one possible partition.
%
% Example:
%   Partitions({'A','B','C'}) returns:
%       ["ABC"]
%       ["AB","C"]
%       ["AC","B"]
%       ["A","BC"]
%       ["A","B","C"]


% Read in the number of elements we want to use
n = numel(items);

% instantiate partitions output to nothing
parts = {};

% Run the recursive function with an initial iteration and an empty string
% array
backtrack(1, strings(0,1));

% backtracking function
    function backtrack(i, groups)
        % inputs an iteration and the current group of elements
        if i > n
            % if the iteration is too deep, we want to add the group to a
            % list of partitions and then move back out
            parts{end+1} = groups; 
            return
        end

        % get current item or component
        x = string(items{i});

        % 1) put x into existing groups (concatenate)
        for g = 1:numel(groups)

            % add the element to the string array
            groups(g) = groups(g) + x;

            % run a backtrack again
            backtrack(i+1, groups);

            % undo change to explore other options
            groups(g) = extractBefore(groups(g), strlength(groups(g)));
        end

        % 2) start a new group containing only x and then recurse
        groups(end+1) = x;

        % go into that group to loop through the possibilities of future
        % items
        backtrack(i+1, groups);

        % remove last group to restore previous state
        groups(end) = [];
    end


end


