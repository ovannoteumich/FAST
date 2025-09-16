function parts = Partitions(items)
% items: cell array of single-character strings, e.g. {'A','B','C'}
% returns: cell array of partitions, each a string array like ["AB","C"]

n = numel(items);
parts = {};

backtrack(1, strings(0,1));

    function backtrack(i, groups)
        if i > n
            parts{end+1} = groups; %#ok<AGROW>
            return
        end
        x = string(items{i});
        % put x into existing groups (concatenate)
        for g = 1:numel(groups)
            groups(g) = groups(g) + x;   % concatenate string
            backtrack(i+1, groups);
            groups(g) = extractBefore(groups(g), strlength(groups(g))); % undo
        end
        % or start a new group
        groups(end+1) = x;
        backtrack(i+1, groups);
        groups(end) = [];
    end


end


