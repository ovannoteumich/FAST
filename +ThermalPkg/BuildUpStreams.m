function [UpStreamStruct] = BuildUpStreams(LoopsUnordered,UpStreamStem)

nloops = length(LoopsUnordered);

counter = 1;

for kk = 1:nloops

    addarch(1,UpStreamStem,LoopsUnordered{kk})

end

    function [] = addarch(iter, instem, curarch)

        stem = instem;

        if iter > length(curarch)
            UpStreamStruct.("Arch_" + counter) = stem;
            counter = counter + 1;
            return
        end

        indices = perms(char(curarch(iter)));
        nind = size(indices,2);
        nperm = size(indices,1);

        for mm = 1:nperm

            if nind ==1
                stem(str2double(indices(mm,1)), end) = 1;
                addarch(iter+1,stem,curarch)
                stem = instem;
            else

                for jj = 1:nind-1
                    stem(str2double(indices(mm,jj)),str2double(indices(mm,jj+1))) = 1;
                end

                stem(str2double(indices(mm,nind)), end) = 1;
                addarch(iter+1,stem,curarch)
                stem = instem;
            end

        end

    end

end




