function [Aircraft] = EvalTaxi(Aircraft)
%
% [Aircraft] = EvalTaxi(Aircraft)
% originally written by Emma Cassidy, emmasmit@umich.edu
% last modified: 13 oct 2025
%
% Evaluate the takeoff segment. Converge on ground roll to compute takeoff
% performance
%
% INPUTS:
%     Aircraft - aircraft being flown.
%                size/type/units: 1-by-1 / struct / []
%
% OUTPUTS:
%     Aircraft - aircraft flown after takeoff with the mission history
%                updated in "Aircraft.Mission.History.SI".
%                size/type/units: 1-by-1 / struct / []
%


%% PRE-PROCESSING %%
%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% info about the aircraft    %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% weight: get the maximum takeoff weight
MTOW = Aircraft.Specs.Weight.MTOW; 

% wing loading: get the wing loading
W_S = Aircraft.Specs.Aero.W_S.SLS;

% area: get the wing area
S = MTOW / W_S;

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% information from the       %
% mission profile            %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the segment id
SegsID = Aircraft.Mission.Profile.SegsID;

% set number of points in the segment
npoint = Aircraft.Mission.Profile.SegPts(SegsID);

% get the beginning and ending control point indices
SegBeg = Aircraft.Mission.Profile.SegBeg(SegsID);
SegEnd = Aircraft.Mission.Profile.SegEnd(SegsID);

% beginning and ending altitudes
%AltBeg = Aircraft.Mission.Profile.AltBeg(SegsID);
AltEnd = Aircraft.Mission.Profile.AltEnd(SegsID);

% beginning and ending velocities
%VelBeg = Aircraft.Mission.Profile.VelBeg(SegsID);
V_taxi = Aircraft.Mission.Profile.VelEnd(SegsID);

% beginning and ending velocity types
%TypeBeg = Aircraft.Mission.Profile.TypeBeg(SegsID);
vtype = Aircraft.Mission.Profile.TypeEnd(SegsID);

%convert to seconds
taxiT = Aircraft.Mission.Profile.TaxiTime .*60;

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% invariants                 %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% gravitational acceleration------[scalar]
g = 9.81;

% assume no temperature variation-------[scalar]
dISA = 0;

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% allocate memory for the    %
% mission history outputs    %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TAS
TAS = V_taxi;

% time 
Time = taxiT;

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% setup the airspeed profile %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% convert the takeoff velocity to TAS, and find the density at takeoff
[~, V_taxi, ~, ~, ~, Rho, ~] = MissionSegsPkg.ComputeFltCon( ...
                              AltEnd, dISA, vtype, V_taxi);

Aircraft.Mission.History.SI.Performance.Rho(SegEnd) = Rho;

Aircraft.Mission.History.SI.Performance.TAS(SegEnd) = TAS;

% ----------------------------------------------------------------
%% Eval Taxi %%
%%%%%%%%%%%%%%%%%

Aircraft = PropulsionPkg.PowerAvailable(Aircraft);

% lift and frag at taxi speeds is assumed negligable

% compute the friction force (assume coefficient of friction)
% concrete friction
Crr = .02;
F = Crr.*MTOW.*g;

% get force required to overcome friction
DV = (F).* TAS;

Preq = DV;

Dist = Time.*TAS;
            
% store variables in the mission history
Aircraft.Mission.History.SI.Power.Req(       SegEnd) = Preq;
Aircraft.Mission.History.SI.Weight.CurWeight(SegEnd) = MTOW;
Aircraft.Mission.History.SI.Performance.Time(SegEnd) = Time + Aircraft.Mission.History.SI.Performance.Time(SegBeg);

% perform the propulsion analysis
Aircraft = PropulsionPkg.PropAnalysis(Aircraft);

%% FILL THE STRUCTURE %%
%%%%%%%%%%%%%%%%%%%%%%%%

% performance metrics
Aircraft.Mission.History.SI.Performance.Dist(SegEnd) = Dist + Aircraft.Mission.History.SI.Performance.Dist(SegBeg);
Aircraft.Mission.History.SI.Performance.EAS( SegEnd) = TAS  ; % at takeoff this is the same

% current segment
Aircraft.Mission.History.Segment(SegBeg:SegEnd) = "Taxi";


end

