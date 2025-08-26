function [Aircraft] = LamFill(Aircraft)
%
% 
% Fill in lambda UPs and DWNs splits in mission history for each
% transmitter
%

%% Setup %%
%%%%%%%%%%%

% make altitude vector 
Profile = Aircraft.Mission.Profile;

% loop through segments 
for i = 1 : length(Profile.Segs)

    % get altitude distribution over each segement
    SegAlt = linspace(Profile.AltBeg(i), Profile.AltEnd(i), Profile.SegPts(i));

    % fill altitude in mission history 
    Aircraft.Mission.History.SI.Performance.Alt(Profile.SegBeg(i):Profile.SegEnd(i), 1) = SegAlt;

end

% save altitude for use
Alt = Aircraft.Mission.History.SI.Performance.Alt;
nlen = height(Alt);
ntrans = length(Aircraft.Specs.Propulsion.PropArch.TrnType);

% get lambda splits over mission profile
LamUps = Aircraft.Specs.Power.LamUps;
LamDwn = Aircraft.Specs.Power.LamDwn;

%% Fill in Lambda Mission Values %%

% check if lambda mission values already given
if isfield(LamUps, 'Miss')

% if no lambda mission filled, fill in based on Lam input
else
%ONLY WORKS CURRENTLY FOR PHE

    % designate space for lambda mission array
    LamUps.Miss = zeros(nlen,ntrans);
    LamDwn.Miss = zeros(nlen,ntrans);

    % get transient types
    TrnType = Aircraft.Specs.Propulsion.PropArch.TrnType;
    iEM = find(TrnType == 0);
    iGT = find(TrnType == 1);
    iFan =find(TrnType == 2);

    % collect mission profile information
    nsegs = length(Profile.Segs);
    
    for i = 1:nsegs
        
        Seg = Profile.Segs(i);
        % check segement type and get correct lambda chars
        if Seg == 'Takeoff'
            lamseg = 'Tko';
        elseif Seg == 'Climb'
            lamseg = 'Clb';
        elseif Seg == 'Cruise'
            lamseg = 'Crs';
        elseif Seg == 'Descent'
            lamseg = 'Des';
        elseif Seg == 'Landing'
            lamseg = 'Lnd';
        end

        % segement length
        npt = Profile.SegEnd(i)-Profile.SegBeg(i)+1;
        
        % fill in current segment power
        ups = ones(1,ntrans);
        dwn = ones(1,ntrans);

        ups(iEM) = LamUps.(lamseg);
        % the rest of the ups will be determined later, assumes 1 for now

        dwn(iEM) = LamDwn.(lamseg);
        dwn(iGT) = dwn(iGT) - dwn(iEM);
        dwn(iFan) = 0.5;
        
        % propagate through sgement points
        LamUps.Miss(Profile.SegBeg(i):Profile.SegEnd(i), :) = repmat(ups,npt,1);
        LamDwn.Miss(Profile.SegBeg(i):Profile.SegEnd(i), :) = repmat(dwn,npt,1);

    end
    
    Aircraft.Specs.Power.LamUps = LamUps;
    Aircraft.Specs.Power.LamDwn = LamDwn;
    Aircraft.Mission.History.SI.Power.LamUps = LamUps;
    Aircraft.Mission.History.SI.Power.LamSwn = LamDwn;


end


end