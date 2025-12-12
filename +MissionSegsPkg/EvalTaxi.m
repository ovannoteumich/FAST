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

%   assumes single engine taxi as an option
%
% OUTPUTS:
%     Aircraft - aircraft flown after takeoff with the mission history
%                updated in "Aircraft.Mission.History.SI".
%                size/type/units: 1-by-1 / struct / []
%


%% PRE-PROCESSING %%
%%%%%%%%%%%%%%%%%%%%


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

Fuel = Aircraft.Specs.Propulsion.PropArch.SrcType == 1;
Batt = Aircraft.Specs.Propulsion.PropArch.SrcType == 0;

% if not first segment, get accumulated quantities
if (SegBeg > 1)
    
    % initialize aircraft mass
    Mass = repmat(Aircraft.Mission.History.SI.Weight.CurWeight(SegBeg), npoint, 1);
    
    % get distance flown and time aloft
    %Dist(1) = Aircraft.Mission.History.SI.Performance.Dist(SegBeg);
    %Time(1) = Aircraft.Mission.History.SI.Performance.Time(SegBeg);
    
    % initialize fuel and battery energy remaining
    Eleft_ES = repmat(Aircraft.Mission.History.SI.Energy.Eleft_ES(SegBeg, :), npoint, 1);
    
else
    
    % initialize aircraft mass: assume maximum takeoff weight
    Mass = repmat(Aircraft.Specs.Weight.MTOW, npoint, 1);
    
    % check for any fuel
    if (any(Fuel))
        
        % compute the fuel energy remaining
        Eleft_ES(:, Fuel) = Aircraft.Specs.Power.SpecEnergy.Fuel * Aircraft.Specs.Weight.Fuel;
        
    end
    
    % check for any battery
    if (any(Batt))
        
        % compute the battery energy remaining
        Eleft_ES(:, Batt) = Aircraft.Specs.Power.SpecEnergy.Batt * Aircraft.Specs.Weight.Batt;
        
    end
    
end


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
TAS = repmat(V_taxi,npoint,1);

% time 
Time = [0;taxiT];

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% setup the airspeed profile %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% convert the takeoff velocity to TAS, and find the density at takeoff
[~, V_taxi, ~, ~, ~, Rho, ~] = MissionSegsPkg.ComputeFltCon( ...
                              AltEnd, dISA, vtype, V_taxi);

Aircraft.Mission.History.SI.Performance.Rho(SegBeg:SegEnd) = Rho;

Aircraft.Mission.History.SI.Performance.TAS(SegBeg:SegEnd) = TAS;

% ----------------------------------------------------------------
%% Eval Taxi %%
%%%%%%%%%%%%%%%%%

Aircraft = PropulsionPkg.PowerAvailable(Aircraft);

% lift and frag at taxi speeds is assumed negligable

% compute the friction force (assume coefficient of friction)
% concrete friction
Crr = .02;
F = Crr.*Mass.*g;

% get force required to overcome friction
DV = (F).* TAS;

Preq = DV;

Dist = Time.*TAS;
            
% store variables in the mission history
Aircraft.Mission.History.SI.Power.Req(SegBeg:SegEnd) = Preq;
Aircraft.Mission.History.SI.Weight.CurWeight(SegBeg:SegEnd) = Mass;
Aircraft.Mission.History.SI.Performance.Time(SegBeg:SegEnd) = Time + Aircraft.Mission.History.SI.Performance.Time(SegBeg);
Aircraft.Mission
% perform the propulsion analysis
Aircraft = PropulsionPkg.PropAnalysis(Aircraft);

%% FILL THE STRUCTURE %%
%%%%%%%%%%%%%%%%%%%%%%%%

% performance metrics
Aircraft.Mission.History.SI.Performance.Dist(SegBeg:SegEnd) = Dist + Aircraft.Mission.History.SI.Performance.Dist(SegBeg);
Aircraft.Mission.History.SI.Performance.EAS(SegBeg:SegEnd) = TAS  ; % at takeoff this is the same


% current segment
Aircraft.Mission.History.Segment(SegBeg:SegEnd) = "Taxi";


end

