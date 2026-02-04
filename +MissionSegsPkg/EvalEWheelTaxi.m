function [Aircraft] = EvalEWheelTaxi(Aircraft)
%
% [Aircraft] = EvalTaxi(Aircraft)
% originally written by Emma Cassidy, emmasmit@umich.edu
% last modified: 29 oct 2025
%
% Evaluate taxi segement based on electric motors in landing gear wheels,
% size electric motors required for taxi
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

% get landging gear electric motor weight
if isfield(Aircraft.Specs.Weight, "LandEM")
    W_LandEM = Aircraft.Specs.Weight.LandEM;
else
    W_LandEM = 0;
    Aircraft.Specs.Weight.LandEM = 0;
end

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

Aircraft.Mission.History.SI.Performance.TAS(SegEnd) = TAS;

% ----------------------------------------------------------------
%% Eval Taxi %%
%%%%%%%%%%%%%%%%%

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
%Aircraft = PropulsionPkg.PropAnalysis(Aircraft);
%SOC   = Aircraft.Mission.History.SI.Power.SOC(SegBeg:SegEnd,2);
SOC = [100; 100];

% battery: get battery cell arrangement
SerCells = Aircraft.Specs.Power.Battery.SerCells;
ParCells = Aircraft.Specs.Power.Battery.ParCells;
    % power available from the battery
[V, I, Pbatt,  Q, SOC,C_rate] = BatteryPkg.Discharging(Aircraft, Preq, Time, SOC(1), ParCells, SerCells);
        

% get the energy from the battery
E_ES = Preq .* Time;

wEM = Preq ./ 1000 /10;
if Aircraft.Settings.Analysis.Type > -2
    % add them to the payload
    Aircraft.Specs.Weight.Payload = Aircraft.Specs.Weight.Payload - W_LandEM + wEM;
    Aircraft.Specs.Weight.LandEM = wEM;
end


%% FILL THE STRUCTURE %%
%%%%%%%%%%%%%%%%%%%%%%%%

% performance metrics
Aircraft.Mission.History.SI.Performance.Dist(SegEnd) = Dist + Aircraft.Mission.History.SI.Performance.Dist(SegBeg);
Aircraft.Mission.History.SI.Performance.EAS( SegEnd) = TAS  ; % at takeoff this is the same

% energy from battery and remaining
Aircraft.Mission.History.SI.Energy.E_ES(SegEnd, 2)= Aircraft.Mission.History.SI.Energy.E_ES(SegBeg, 2) + E_ES;
Aircraft.Mission.History.SI.Energy.Eleft_ES(SegEnd, 2)= Aircraft.Mission.History.SI.Energy.Eleft_ES(SegBeg, 2) - E_ES;
Aircraft.Mission.History.SI.Power.SOC(SegBeg:SegEnd,2) = SOC;
Aircraft.Mission.History.SI.Power.Voltage( SegEnd, 2) = V  ;
Aircraft.Mission.History.SI.Power.Current( SegEnd, 2) = I  ;
Aircraft.Mission.History.SI.Power.Capacity(SegEnd, 2) = Q  ;
Aircraft.Mission.History.SI.Power.C_rate(  SegEnd, 2) = C_rate;

% set values for fuel side not used
Aircraft.Mission.History.SI.Energy.E_ES(SegEnd, 1)= Aircraft.Mission.History.SI.Energy.E_ES(SegBeg, 1);
Aircraft.Mission.History.SI.Energy.Eleft_ES(SegEnd, 1)= Aircraft.Mission.History.SI.Energy.Eleft_ES(SegBeg, 1);
Aircraft.Mission.History.SI.Power.SOC(SegEnd,1) = Aircraft.Mission.History.SI.Power.SOC(SegBeg,1);
Aircraft.Mission.History.SI.Weight.Fburn(SegEnd,1) = Aircraft.Mission.History.SI.Weight.Fburn(SegBeg,1);
Aircraft.Mission.History.SI.Weight.CurWeight(SegEnd,1) = Aircraft.Mission.History.SI.Weight.CurWeight(SegBeg,1);

% current segment
Aircraft.Mission.History.Segment(SegBeg:SegEnd) = "EWheelTaxi";


end

