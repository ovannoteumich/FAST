function [Aircraft] = ProcessPropArch(Aircraft)
%
% [Aircraft] = ProcessPropArch(Aircraft)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 18 sep 2025
%
% given a propulsion architecture, find how each gas turbine engine is
% connected to a propeller. the power required at the propeller is
% necessary for determining the gas turbine engine power output.
% additionally, compute the hybrid electric coefficients for the gas
% turbine engine to run in the BADA equation.
%
% INPUTS:
%     Aircraft - information about the aircraft and its propulsion
%                architecture.
%                size/type/units: 1-by-1 / struct / []
%
% OUTPUTS:
%     Aircraft - information updated with the propeller connections and
%                hybrid electric coefficients for each engine to be
%                analyzed.
%                size/type/units: 1-by-1 / struct / []
%

% get the propulsion archcitecture
Arch = Aircraft.Specs.Propulsion.PropArch.Arch;

% get the source and transmitter types
SrcType = Aircraft.Specs.Propulsion.PropArch.SrcType;
TrnType = Aircraft.Specs.Propulsion.PropArch.TrnType;

% get the number of components
[ncomp, ~] = size(Arch);

% get the number of sources and transmitters
nsrc = length(SrcType);
ntrn = length(TrnType);

% compute the number of sinks
nsnk = ncomp - nsrc - ntrn;

% get the downstream sizing splits
LamSLS = Aircraft.Specs.Power.LamDwn.SLS;

% convert to a cell array
LamCell = num2cell(LamSLS);

% get the splits
LamDwn = Aircraft.Specs.Propulsion.PropArch.OperDwn(LamCell{:});

% allocate memory for indexed transmitter arrays
WhichProp = zeros(1, ntrn);
HEcoeff   = zeros(1, ntrn);

% create logical array transmitters
itrn = logical([zeros(nsrc, 1);  ones(ntrn, 1); zeros(nsnk, 1)]);

% combine types to form an ID
ID = [SrcType'; TrnType'; zeros(nsnk, 1)];

% look at the propeller connections
PropIdx = find(ID == 2)';

% define a power vector
PowerVector = zeros(ncomp, 1);

% loop through all propellers to find indirect gas turbine engines
for iprop = PropIdx
        
    % remember a copy of the index
    jprop = iprop;
        
    % remember the index
    krow = jprop;
    
    % loop until gas turbine engine is found
    while (~isempty(krow))
        
        % check if any are gas turbine engines
        AnyGTE = logical(sum(Arch(:, krow) > 0 & ID == 1 & itrn, 2));
        
        if (any(AnyGTE))
            
            % get its index
            igte = find(AnyGTE);

            % remember the propeller connection
            WhichProp(igte - nsrc) = iprop;

            % perturb the power vector
            PowerVector(iprop) = 1;

            % propagate power downstream
            Pout = PropulsionPkg.PowerFlow(PowerVector, Arch', LamDwn, ones(ncomp, ncomp), -1, 1.0e-06);
            
            % remove the perturbation
            PowerVector(iprop) = 0;
            
            % remember the coefficient
            HEcoeff(igte - nsrc) = 2 - Pout(igte);
            
            % break out of the loop
            break;
            
        else
            
            % remember the indices
            jrow = krow;
            
            % search a level deeper
            [krow, ~] = find(Arch(:, jrow));
            
        end
    end    
end

% loop through all propellers to find directly connected gas turbine engines
for iprop = PropIdx
    
    % find gas turbine engines
    GTEIdx = find(Arch(:, iprop) > 0 & ID == 1 & itrn);

    % check for an index
    if (~isempty(GTEIdx))

       % remember the index
       WhichProp(GTEIdx - nsrc) = iprop;

    end
end

% remember the coefficients
Aircraft.Specs.Propulsion.Engine.HEcoeff = HEcoeff;
Aircraft.Specs.Propulsion.PropArch.WhichProp = WhichProp;

end