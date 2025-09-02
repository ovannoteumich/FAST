function [Aircraft] = RecomputeSplits(Aircraft, SegBeg, SegEnd)
%
% [Aircraft] = RecomputeSplits(Aircraft, SegBeg, SegEnd)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 05 mar 2025
%
% Re-compute the operational power splits for a "full throttle" setting
% during the mission.
%
% WARNING: this function only works for two elements connected in parallel
% right now (or conventional/electric architectures that don't have any
% power splits).
%
% INPUTS:
%     Aircraft - structure with information about the aircraft and mission
%                being flown.
%                size/type/units: 1-by-1 / struct / []
%
%     SegBeg   - beginning segment index.
%                size/type/units: 1-by-1 / int / []
%
%     SegEnd   - ending segment index.
%                size/type/units: 1-by-1 / int / []
%
% OUTPUTS:
%     Aircraft - structure with the updated power splits. Only LamTSPS is
%                updated for now.
%                size/type/units: 1-by-1 / struct / []
%


%% PRE-PROCESSING %%
%%%%%%%%%%%%%%%%%%%%

% get the parallel connections
ParConns = Aircraft.Specs.Propulsion.PropArch.ParConns;

% identify any parallel connections
ParIndx = find(cellfun(@(x) ~isempty(x), ParConns));

% check if there are any parallel connections
if (~any(ParIndx))
    
    % don't re-compute if there aren't any splits
    return
    
end

% get the number of parallel connections
npar = length(ParIndx);

% get the number of sources and transmitters
nsrc = length(Aircraft.Specs.Propulsion.PropArch.SrcType);
TrnType = Aircraft.Specs.Propulsion.PropArch.TrnType;
ntrn = length(TrnType);

% get the power available (equal to power output for "full throttle" case)
% do not include sources (sink is inluded)
Pav = Aircraft.Mission.History.SI.Power.Pav(SegBeg:SegEnd, :);
Pout = Aircraft.Mission.History.SI.Power.Pout(SegBeg:SegEnd, :);

% get the power splits
LamUps = Aircraft.Mission.History.SI.Power.LamUps(SegBeg:SegEnd, :);
LamDwn = Aircraft.Mission.History.SI.Power.LamDwn(SegBeg:SegEnd, :);

% re-compute the power splits that are nonzero, so get their indices
idx = any(LamUps > 0, 2);

% get the number of downstream splits
nsplit = Aircraft.Settings.nargOperDwn;

% get a temporary power split
TmpSplit = LamDwn;

% get the original downstream matrix
OperDwn = PropulsionPkg.EvalSplit(Aircraft.Specs.Propulsion.PropArch.OperDwn, TmpSplit);

% loop through each power split
for ipar = 1:npar
    
    % get the index of the main connection
    imain = ParIndx(ipar) + nsrc;
    
    % get the supplemental connection(s)
    isupp = ParConns{ParIndx(ipar)};

    % get the total power output at any given time from those sources
    Out = sum(Pout(idx, [imain, isupp]), 2);
    
    % compute the downstream power split
    LamDwn(idx, [imain, isupp]-nsrc) = Pout(idx, [imain, isupp]) ./ Out;

    % compute up stream power splits
    LamUps(idx, [imain, isupp]-nsrc) = Pout(idx, [imain, isupp]) ./ Pav(idx, [imain, isupp]);

end

% if any are NaN, return 0 (assume it's from 0 power available)
LamDwn(isnan(LamDwn)) = 0;
LamUps(isnan(LamUps)) = 0;

% remember the power split
Aircraft.Mission.History.SI.Power.LamDwn(SegBeg:SegEnd, :) = LamDwn;
Aircraft.Mission.History.SI.Power.LamUps(SegBeg:SegEnd, :) = LamUps;

% ----------------------------------------------------------

end