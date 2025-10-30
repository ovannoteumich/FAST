function [SettingInd] = TraceUpstream(Arch,SInd)
% This function finds which sink or pump temp each component should be
% initialized to by following the upstream matrix to the end

% Pull in arch size
NComp = size(Arch,1);

% This will trace the upstream connections
Tracer = zeros(NComp,1);

% Follow the index of interest
Tracer(SInd) = 1;

% Want to iterate for 1 more than the total number of components to ensure
% convergence
for ii = 1:NComp+1

    % Step forward, track the connection
    Tracer2 = (Arch')*Tracer;

    % Only update if the new value is greater than zero
    for jj = 1:NComp
        if Tracer2(jj) > 1e-5
            Tracer(jj) = Tracer2(jj);
        end
    end
end

% Only interested in final connections, get rid of sinks
Tracer(1:end-4) = 0;

% Find sinks that are in the path
SNKInds = find(Tracer == 1);

% Only interested in the first sink it encounters because thats the
% temperature the component will receive
SettingInd = SNKInds(1);

end