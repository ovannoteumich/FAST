function [OptAircraft] = MissionPowerOpt(Aircraft)

%
% OptAicraft = MissionPowerOpt(Aircraft)
% written by Emma Cassidy, emmasmit@umich.edu
% last updated: Feb 2024
%
% Optimize electric motor power code on an off-design mission for a
% parallel-hybrid propulsion architecture.
% The optimzer used is the built in fmincon with the interior point method.
% See setup below to change optimizer paramteters.
%
%
% INPUTS: 
%   Aircraft - Aircraft struct with desired power code starting values and 
%              desired mission conditions. 
% OUTPUTS:
%   OptAircraft - optimized aircraft struct with optimial power code

%% PRE-PROCESSING AND SETUP %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% Optimizer Settings         %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set up optimization algorithm and command window output
% Default - interior point w/ max 50 iterations
options = optimoptions('fmincon','MaxIterations', 100 ,'Display','iter','Algorithm','sqp', 'UseParallel',true);

% objective function convergence tolerance
options.OptimalityTolerance = 10^-12;

% step size convergence
options.StepTolerance = 10^-12;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% Aircraft  Settings         %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% run off design mission
Aircraft.Settings.Analysis.Type = -2;

% turn off FAST print outs
Aircraft.Settings.PrintOut = 0;

% turn off FAST internal SOC constraint
Aircraft.Settings.PowerOpt = 1;

Aircraft.Settings.PowerStrat = 1;

% no mission history table
Aircraft.Settings.Table = 0;
%Aircraft.Specs.Weight.Batt = 3e3;

% climb beg and end ctrl pt indeces
% get the number of points in each segment
TkoPts = Aircraft.Settings.TkoPoints;
ClbPts = Aircraft.Settings.ClbPoints;
CrsPts = Aircraft.Settings.CrsPoints;
DesPts = Aircraft.Settings.DesPoints;

% number of points in the main mission
npt = TkoPts + 3 * (ClbPts - 1) + CrsPts - 1 + 3 * (DesPts - 1);

n1= 10;
n2= 64;
pts = [10:27,37:45,55:63];
% get starting point
PC0 = Aircraft.Specs.Power.LamUps.Miss(pts, [1,3]);
b = size(PC0);
lb = zeros(b)*-.001;
ub = ones(b);

% save storage values
PClast = [];
fburn = [];
SOC    = [];
Ps = [];
dh_dt = [];
DOC = 0;
g = 9.81;
priceTable = readtable('\+ExperimentPkg\Energy_CostbyAirport.xlsx');
%% Run the Optimizer %%
%%%%%%%%%%%%%%%%%%%%%%%%%
tic
PCbest = fmincon(@(PC0) ObjFunc(PC0, Aircraft), PC0, [], [], [], [], lb, ub, @(PC0) Cons(PC0, Aircraft), options);
t = toc/60


%% Post-Processing %%
%%%%%%%%%%%%%%%%%%%%%%%%%
fburnOG = ObjFunc(PC0, Aircraft);
fburnOpt = ObjFunc(PCbest, Aircraft);
fdiff = (fburnOpt - fburnOG)/fburnOG;
pout = sprintf("Fuel Burn Reduction: %f", fdiff);
disp(pout)

Aircraft.Specs.Power.LamUps.Miss(pts, [1,3]) = PCbest;
Aircraft.Specs.Power.LamUps.Miss(pts, [2,4]) = PCbest;
Aircraft = Main(Aircraft, @MissionProfilesPkg.A320);
OptAircraft = Aircraft;
disp(PCbest)
    
%% Nested Functions %%
%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
%  Function Evaluation        %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fburn, SOC, dh_dt] = FlyAircraft(PC, Aircraft)
    % input updated PC
    Aircraft.Specs.Power.LamUps.Miss(pts, [1,3]) = PC;
    Aircraft.Specs.Power.LamUps.Miss(pts, [2,4]) = PC;

    try
        % fly off design mission
        Aircraft = Main(Aircraft, @MissionProfilesPkg.A320);
        
        % fuel required for mission
        fburn = Aircraft.Mission.History.SI.Weight.Fburn(end);
        if fburn < 0 
            fburn = 10^3;
        end
        % SOC for mission
        SOC = Aircraft.Mission.History.SI.Power.SOC(n1:64,2);
        %Aircraft = ExperimentPkg.EnergyCost_perAirport(Aircraft, "ATL", priceTable);
        %DOC = Aircraft.Mission.History.SI.Performance.Cost;
    catch 
        fburn = 1e10;
        % SOC for mission
        SOC = -1*Aircraft.Mission.History.SI.Power.SOC(n1:64,2);
        DOC = 10e12;
    end
    

    % check if enough power for desired climb profile
    % extract climb TAS
    TAS = Aircraft.Mission.History.SI.Performance.TAS(n1:64);
    % rate of climb
    dh_dt = Aircraft.Mission.History.SI.Performance.RC(n1:64);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% Objective Function         %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [val] = ObjFunc(PC, Aircraft)
    % check if PC values changes
    if ~isequal(PC, PClast)
        [fburn, SOC, dh_dt] = FlyAircraft(PC, Aircraft);
        PClast = PC;
        %disp(PC)
    end
    % return objective function value
    val = fburn;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% SOC Constraint             %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
function [c, ceq] = Cons(PC, Aircraft)
    % check if PC values changes
    if ~isequal(PC, PClast)
        [fburn, SOC, dh_dt] = FlyAircraft(PC, Aircraft);
        PClast = PC;
    end
    % compute SOC constraint
    cSOC = Aircraft.Specs.Battery.MinSOC - SOC;
    

    % compute RC constraint
    cRC = dh_dt - Aircraft.Specs.Performance.RCMax;

    % out put constraints
    c = [cSOC; cRC];
    ceq = [];

end

end

