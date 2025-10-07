function [Aircraft] = EvalDetailedTakeoff(Aircraft)
%
% [Aircraft] = EvalDetailedTakeoff(Aircraft)
% written by Emma Cassidy, emmasmit@umich.edu
% last modified: 29 sep 2025
%
% Evaluate the takeoff segment. Assume maximum thrust/power from all
% components in the propulsion system. In the detailed takeoff segment, the
% time to complete the takeoff roll is computed from the physics (unlike
% the less detailed takeoff segment, EvalTakeoff, which assumes a
% one-minute takeoff).
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

AR = Aircraft.Specs.Aero.AR;

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% information from the       %
% mission profile            %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the segment id
%SegsID = Aircraft.Mission.Profile.SegsID;
SegsID = 1;

% set number of points in the segment
npoint = Aircraft.Mission.Profile.SegPts(SegsID);

% get the beginning and ending control point indices
SegBeg = Aircraft.Mission.Profile.SegBeg(SegsID);
SegEnd = Aircraft.Mission.Profile.SegEnd(SegsID);

% ending altitude (beginning altitude assumed to be 0)
AltEnd = Aircraft.Mission.Profile.AltEnd(SegsID);

% ending airspeed (beginning airspeed assumed to be 0)
V_tko = Aircraft.Mission.Profile.VelEnd(SegsID);

% ending velocity type (beginning one is not needed)
vtype = Aircraft.Mission.Profile.TypeEnd(SegsID);

TkoRoll = Aircraft.Mission.Profile.TkoRoll;

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% invariants                 %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% gravitational acceleration
g = 9.81;

% assume no temperature variation
dISA = 0;

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% allocate memory for the    %
% mission history outputs    %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% altitude
Alt = repmat(Aircraft.Specs.Performance.Alts.Tko, npoint, 1);

% total mass in each time
Mass = repmat(MTOW, npoint, 1);

% TAS
TAS = zeros(npoint,1);

% time 
Time = zeros(npoint,1);

% drag
DV     = zeros(npoint, 1);

% time change
dt = zeros(npoint,1);

% friction
F = zeros(npoint,1); 

% acceleration
dV_dt = zeros(npoint, 1);

Ps = zeros(npoint,1);

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% setup the airspeed profile %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% convert the takeoff velocity to TAS, and find the density at takeoff
[~, V_tko, ~, ~, ~, Rho, ~] = MissionSegsPkg.ComputeFltCon( ...
                              AltEnd, dISA, vtype, V_tko);

Aircraft.Mission.History.SI.Performance.Rho(SegBeg:SegEnd) = Rho;

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% consider the geometry and  %
% its impact on aerodynamics %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% retireve clean drag coefficient
CD0 = Aircraft.Specs.Aero.CD0; 

% chnage in parasite drag in takeoff configuration
dCD0 = Aircraft.Specs.Aero.dCD1;

CL = .3;

%{
% hardcode flaps
flaps = 1;

% Compute the delta CD0 based on flaps and landing gear (hardcoded now)
if (flaps == 1)
    k_uc = 3.16e-5;
else
    k_uc = 5.81e-5;
end

% compute the change in parasite drag coefficient
dCD0 = W_S * k_uc * MTOW ^ -0.215;
%}
% k1 and k3 estimations (hardcoded for now, incorporate geometry later)
k1 = 1/(pi*Aircraft.Specs.Aero.e);
k3 = -.15*k1;

% G estimation (hardcoded for now, incorporate geometry later)
G = 1;

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% iteration setup            %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% define tolerance for testing convergence
EPS06 = 1.0e-6;

% maximum number of iterations
MaxIter = 10;

dTkoRoll = 1;

% ----------------------------------------------------------
%% FLY TAKEOFF %%
%%%%%%%%%%%%%%%%%


% get the power available
Pav = Aircraft.Mission.History.SI.Power.TV(SegBeg:SegEnd);

i = 0; 

% converge on take off roll length
while dTkoRoll > EPS06 && i < 10

    Dist = linspace(0, TkoRoll, npoint);

    for ipt = 1:npoint
    
        if ipt == 1
            F = 0.02 .* (MTOW * g);
            T = Aircraft.Specs.Propulsion.SLSThrust(1);
            dV_dt(ipt) = (T-F)/MTOW;
        else
            % compute the lift coefficient
            %CL = 2 * MTOW * g / (Rho * (TAS(ipt)^ 2) * S);
            
            % compute the CD
            CD = CD0 + dCD0 + (k1 + G * k3) * CL ^ 2;
        
    
            % compute the lift (assume takeoff is flown at CLmax)
            L = 0.5 .* Rho .* TAS(ipt) .^ 2 .* CL .* S;
            
            % compute the friction force (assume coefficient of friction)
            F = 0.02 .* (MTOW * g - L);
            
            % as liftoff occurs, L > W, so the frictional force is < 0 --- set it to 0
            if F < 0 
                F = 0;
            end
            
            % compute the drag
            D = 0.5 .* Rho .* TAS(ipt) .^ 2 .* CD .* S;
        
            DV(ipt) = (D+F).*TAS(ipt);
        
            Ps(ipt) = (Pav(ipt) - DV(ipt)) ./ (MTOW .* g);
        
            dV_dt(ipt) = Ps(ipt).*g./TAS(ipt);
        end
        
        if ipt ~= npoint
            % solve for dtime using 0 = 1/2 dv_dt^2 dt + v dt - ds;
            a = .5 .* dV_dt(ipt).^2;
            b = TAS(ipt);
            c = -(Dist(ipt+1)-Dist(ipt));
        
            dt(ipt) = (-b + sqrt(b.^2 - 4.*a.*c))./(2.*a);
        
        if dt < 0
            error
        end
        
            % update next velcoity
            TAS(ipt+1) = dV_dt(ipt) * dt(ipt) + TAS(ipt);
        
            % update time
            Time(ipt+1) = dt(ipt) + Time(ipt);
            
            % update power avaliable based on TAS
            Aircraft.Mission.History.SI.Performance.TAS(SegBeg:SegEnd) = TAS;
            
            % compute the power available
            Aircraft = PropulsionPkg.PowerAvailable(Aircraft);

            % get the updated power available
            Pav = Aircraft.Mission.History.SI.Power.TV(SegBeg:SegEnd);
        end
       
    end

    oldTkoRoll = TkoRoll;

    % check if takeoff velodity achieved
    id_vel = find(TAS > V_tko, 1, 'First');

    % if empty, takeoff speed not reached, lengthen runway
    if isempty(id_vel)
        TkoRoll = 1.1 * TkoRoll;
    else
        TkoRoll = Dist(id_vel);
    end

    dTkoRoll = abs(TkoRoll-oldTkoRoll);
     i = i +1;
end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %                        %
    % energy analysis        %
    %                        %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    dKE_dt = Mass .* TAS .* dV_dt;
    
    % power required (ncases)
    Preq = dKE_dt + DV;

    Preq(1) = Pav(1);
    
    % thrust required
    Treq = Preq ./ TAS;

    % ------------------------------------------------------
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %                        %
    % propulsion analysis    %
    %                        %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
            
    % store variables in the mission history
    Aircraft.Mission.History.SI.Power.Req(       SegBeg:SegEnd) = Preq;
    Aircraft.Mission.History.SI.Weight.CurWeight(SegBeg:SegEnd) = Mass;
    Aircraft.Mission.History.SI.Performance.Time(SegBeg:SegEnd) = Time;
    
    % perform the propulsion analysis
    Aircraft = PropulsionPkg.PropAnalysis(Aircraft);
%
% FLIGHT PHYSICS:
% First, compute the aircraft's acceleration based on the thrust/power
% available and drag at each control point. Then, based on the thrust and
% drag, compute the acceleration at the control points (assume it is
% constant between control points). Use the airspeed difference and
% acceleration to determine the time to travel between the respective
% control points as well as the distance between the control points.
%
% T0                          T1                 T2
% D0                          D1                 D2
% V0                          V1                 V2
% |                           |                  |
% o---------------------------o------------------o
% |        dV_dt1             |     dV_dt2       |
% |           dt1             |        dt2       |
%
     %{   
% get the thrust at each point
T = Pav ./ V;

% the first point will have a divide by 0 error, leave it as NaN
T(1) = NaN;

% compute the lift (assume takeoff is flown at CLmax)
L = 0.5 .* Rho .* V(2:end) .^ 2 .* CL_max .* S;

% compute the friction force (assume coefficient of friction)
F = 0.02 .* (MTOW * g - L);

% as liftoff occurs, L > W, so the frictional force is < 0 --- set it to 0
F(F < 0) = 0;

% compute the drag
D(2:end) = 0.5 .* Rho .* V(2:end) .^ 2 .* CD .* S;
    
% compute the acceleration (assume constant mass for now)
dV_dt(2:end) = (T(2:end) - D(2:end) - F) ./ MTOW;
    
% compute the time between control points
dtime(2:end) = diff(V) ./ dV_dt(2:end);

% compute the distance travelled
ddist(2:end) = diff(V .^ 2) ./ (2 .* dV_dt(2:end));

% compute power to overcome drag
DV = D .* V;

% compute the specific excess power (assume constant mass)
Ps = (Pav - DV) ./ (Mass .* g);

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% aircraft performance post- %
% processing                 %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% compute the time to takeoff and distance travelled
Time = cumsum(dtime);
Dist = cumsum(ddist);

% get the flight conditions for the entire takeoff roll
[EAS, TAS, Mach] = MissionSegsPkg.ComputeFltCon(Alt, dISA, "TAS", V);

% remember the flight conditions
Aircraft.Mission.History.SI.Performance.Time(SegBeg:SegEnd) = Time;
Aircraft.Mission.History.SI.Performance.Mach(SegBeg:SegEnd) = Mach;
Aircraft.Mission.History.SI.Performance.Alt( SegBeg:SegEnd) = Alt ;

% ------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        %
% energy analysis        %
%                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%

% potential energy
PE = Mass .* g .* Alt;

% kinetic energy
KE = 0.5 .* Mass .* TAS .^ 2;

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% propulsion analysis, get   %
% the fuel burn, energy      %
% consumed, etc.             %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% remember information in the mission history
Aircraft.Mission.History.SI.Power.Req(       SegBeg:SegEnd) = Preq;
Aircraft.Mission.History.SI.Weight.CurWeight(SegBeg:SegEnd) = Mass;

% perform the propulsion analysis
Aircraft = PropulsionPkg.PropAnalysis(Aircraft);


%% FILL THE AIRCRAFT STRUCTURE %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% performance metrics
Aircraft.Mission.History.SI.Performance.Dist(SegBeg:SegEnd) = Dist ; % m
Aircraft.Mission.History.SI.Performance.EAS( SegBeg:SegEnd) = EAS  ; % m/s
Aircraft.Mission.History.SI.Performance.RC(  SegBeg:SegEnd) = dh_dt; % m/s
Aircraft.Mission.History.SI.Performance.Acc( SegBeg:SegEnd) = dV_dt; % m / s^2
Aircraft.Mission.History.SI.Performance.FPA( SegBeg:SegEnd) = FPA  ; % deg
Aircraft.Mission.History.SI.Performance.Ps(  SegBeg:SegEnd) = Ps   ; % m/s
Aircraft.Mission.History.SI.Performance.LD(  SegBeg:SegEnd) = L_D  ;

% energy quantities
Aircraft.Mission.History.SI.Energy.PE(SegBeg:SegEnd) = PE; % J
Aircraft.Mission.History.SI.Energy.KE(SegBeg:SegEnd) = KE; % J

% current segment
Aircraft.Mission.History.Segment(SegBeg:SegEnd) = "Takeoff";

% ----------------------------------------------------------

%% SETUP %%
%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% specifications from the    %
% aircraft structure         %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% maximum rate of climb
dh_dtMax = Aircraft.Specs.Performance.RCMax;

% lift-drag ratio
L_D = Aircraft.Specs.Aero.L_D.Clb;

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
AltBeg = Aircraft.Mission.Profile.AltBeg(SegsID);
AltEnd = Aircraft.Mission.Profile.AltEnd(SegsID);

% beginning and ending velocities
VelBeg = Aircraft.Mission.Profile.VelBeg(SegsID);
VelEnd = Aircraft.Mission.Profile.VelEnd(SegsID);

% beginning and ending speed types
TypeBeg = Aircraft.Mission.Profile.TypeBeg(SegsID);
TypeEnd = Aircraft.Mission.Profile.TypeEnd(SegsID);

% rate of climb (if prescribed)
dh_dtReq = Aircraft.Mission.Profile.ClbRate(SegsID);
     
% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% physical quantities        %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% acceleration due to gravity
g = 9.81; % m / s^2

% assume no temperature deviation (for now)
dISA = 0;

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% iteration setup            %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% define tolerance for testing convergence
EPS06 = 1.0e-6;

% maximum number of iterations
MaxIter = 10;


%% INITIALIZE THE CLIMB SEGMENT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% segment initialization     %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% vector of equally spaced altitudes
Alt = linspace(0, AltEnd, npoint)'; % m
                         


% ----------------------------------------------------------                                            

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% array initialization       %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize arrays that accumulate (and start at 0)
Dist = zeros(npoint, 1); % m
Time = zeros(npoint, 1); % s

% memory for the fuel and battery energy remaining
Eleft_ES = zeros(npoint, 1);

% get the energy source types
Fuel = Aircraft.Specs.Propulsion.PropArch.SrcType == 1;
Batt = Aircraft.Specs.Propulsion.PropArch.SrcType == 0;

% remember the power splits
%Aircraft.Mission.History.SI.Power.LamDwn(SegBeg:SegEnd, :) = repmat(Aircraft.Specs.Power.LamDwn.Clb, SegEnd - SegBeg + 1, 1);
%Aircraft.Mission.History.SI.Power.LamUps(SegBeg:SegEnd, :) = repmat(Aircraft.Specs.Power.LamUps.Clb, SegEnd - SegBeg + 1, 1);

%LamSLS = Aircraft.Specs.Power.LamTSPS.SLS;
Aircraft.Mission.History.SI.Power.LamTSPS(SegBeg:SegEnd) = zeros(npoint, 1);

% if not first segment, get accumulated quantities
if (SegBeg > 1)
    
    % initialize aircraft mass
    Mass = repmat(Aircraft.Mission.History.SI.Weight.CurWeight(SegBeg), npoint, 1);
    
    % get distance flown and time aloft
    Dist(1) = Aircraft.Mission.History.SI.Performance.Dist(SegBeg);
    Time(1) = Aircraft.Mission.History.SI.Performance.Time(SegBeg);
    
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

Aircraft.Mission.History.SI.Weight.CurWeight(SegBeg:SegEnd) = Mass;

% remember the fuel and battery energy remaining
Aircraft.Mission.History.SI.Energy.Eleft_ES(SegBeg:SegEnd, :) = Eleft_ES;

% ----------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% iteration initialization   %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% iteration counter
iter = 0;

% guess the power required (to iterate over)
PreqOld = zeros(npoint, 1);



%% EVALUATE THE CLIMB SEGMENT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% iterate                    %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% flight path angle should converge within 10 iterations
%while (iter < MaxIter)

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %                        %
    % get the flight         %
    % conditions             %
    %                        %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % calculate energy height
    EnHt = TAS .^ 2 ./ (2 * g);
    
    % difference in energy heigt
    dEnHt = diff(EnHt);
    
    % get the flight conditions (ncases)
    [EAS, ~, Mach, ~, ~, Rho, ~] = MissionSegsPkg.ComputeFltCon(...
                                   Alt, dISA, "TAS", TAS);
                               
    % remember the flight conditions for computing the power available
    Aircraft.Mission.History.SI.Performance.TAS( SegBeg:SegEnd) = TAS ;
    Aircraft.Mission.History.SI.Performance.Rho( SegBeg:SegEnd) = Rho ;
    Aircraft.Mission.History.SI.Performance.Mach(SegBeg:SegEnd) = Mach;
    Aircraft.Mission.History.SI.Performance.Alt(SegBeg:SegEnd)  = Alt;
    
    % ------------------------------------------------------
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %                        %
    % propulsion analysis,   %
    % find power available   %
    %                        %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % compute the power available
    Aircraft = PropulsionPkg.PowerAvailable(Aircraft);
    
    % get the power available
    Pav = Aircraft.Mission.History.SI.Power.TV(SegBeg:SegEnd);

    % ------------------------------------------------------

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %                        %
    % performance analysis   %
    %                        %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    L = 0.5 .* Rho .* TAS .^ 2 .* CL_max .* S;

    % compute the friction force (assume coefficient of friction)
    F = 0.02 .* (Mass * g - L);

    % as liftoff occurs, L > W, so the frictional force is < 0 --- set it to 0
    F(F < 0) = 0;

    % compute the drag
    D = 0.5 .* Rho .* TAS .^ 2 .* CD .* S;
    

    % compute the drag power (power to overcome drag)
    DV = (D + F) .* TAS;
            
    % compute the specific excess power
    Ps = (Pav - DV) ./ (Mass .* g);

    
    % check for invalid specific excess power values
    if (any(Ps(1:end-1) < 0))
        if Aircraft.Settings.PrintOut ==1
            warning('Target climb altitude cannot be reached (Ps < 0). Results may be faulty.')
        end
        if Aircraft.Settings.Analysis.Type < 0
                if Aircraft.Settings.PrintOut ==1
                    error('Target takeoff roll speed cannot be reached (Ps < 0). Results may be faulty.')
                end
        end
    end
    
    %dV_dt = (diff(TAS.^2))./(2*(diff(Dist)));

    dTime = dEnHt ./ Ps(1:end-1);

    dV_dt = [diff(TAS)./dTime;0];
    
    % compute the acceleration
    %dTime = [diff(TAS) ./ dV_dt; 0];
            
   
    dV_dtMax = Ps .* g ./ TAS;

    % adjust points when the required acceleration can't be realized
    errdV_dt = find(dV_dt - dV_dtMax > EPS06);

    % for first 0 point use F= m*a cause power 0
    %

    if (any(errdV_dt))
            
            % assume maximum acceleration at all points
            dV_dt = dV_dtMax(errdV_dt);
        
            % update velocity profile (assume maximum acceleration at all)
            TAS(2:end) = TAS(1) + cumsum(dV_dt(1:end-1) .* dTime);
        
            % avoid overspeeding
            TAS(TAS > TASEnd) = TASEnd;
            
            % re-compute the acceleration
            dV_dt = [diff(TAS) ./ dTime; 0];
            
    end

    % cumulative time flown (ncases)
    Time(2:end) = Time(1) + cumsum(dTime);
    
    % ------------------------------------------------------
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %                        %
    % energy analysis        %
    %                        %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    dKE_dt = Mass .* TAS .* dV_dt;
    
    % power required (ncases)
    Preq = dKE_dt + DV;
    
    % thrust required
    Treq = Preq ./ TAS;

    % ------------------------------------------------------
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %                        %
    % propulsion analysis    %
    %                        %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
            
    % store variables in the mission history
    Aircraft.Mission.History.SI.Power.Req(       SegBeg:SegEnd) = Preq;
    Aircraft.Mission.History.SI.Weight.CurWeight(SegBeg:SegEnd) = Mass;
    Aircraft.Mission.History.SI.Performance.Time(SegBeg:SegEnd) = Time;
    
    % perform the propulsion analysis
    Aircraft = PropulsionPkg.PropAnalysis(Aircraft);
    
    % extract updated mass from aircraft structure
    Mass = Aircraft.Mission.History.SI.Weight.CurWeight(SegBeg:SegEnd);
    
    % ------------------------------------------------------
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %                        %
    % check convergence and  %
    % iterate as needed      %
    %                        %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    % check convergence on power required
    PreqCheck = abs(Preq - PreqOld) ./ Preq;
        
    % break if tolerance is reached at all points
    %if (~any(PreqCheck > EPS06))
%         fprintf(1, "Breaking Climb...\n\n");
     %   break;
    %end
    
    % remember the power required
    PreqOld = Preq;
        
    % iterate
    iter = iter + 1;
    
%end


%% POST-PROCESSING %%
%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% compute output parameters  %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ground speed (ncases)
GS = TAS .* cosd(FPA);

% distance travelled in each segment (ncases-1)
dDist = GS(1:end-1) .* dTime;

% cumulative distance flown (ncases)
Dist(2:end) = Dist(1) + cumsum(dDist);


%% FILL THE STRUCTURE %%
%%%%%%%%%%%%%%%%%%%%%%%%

     %}

% performance metrics
Aircraft.Mission.History.SI.Performance.Dist(SegBeg:SegEnd) = Dist ;
Aircraft.Mission.History.SI.Performance.EAS( SegBeg:SegEnd) = TAS  ; % at takeoff this is the same
Aircraft.Mission.History.SI.Performance.RC(  SegBeg:SegEnd) = 0;
Aircraft.Mission.History.SI.Performance.Acc( SegBeg:SegEnd) = dV_dt;
Aircraft.Mission.History.SI.Performance.Ps(  SegBeg:SegEnd) = Ps   ;

% current segment
Aircraft.Mission.History.Segment(SegBeg:SegEnd) = "DetailedTakeoff";

% ----------------------------------------------------------

end