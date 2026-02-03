function [EngineCostTable] = Engine_LCC(Aircraft)
%
% [] = Life_Cycle_COst(Preq, Time, SOCBeg, Parallel, Series)
% originally written by Emma Cassidy, emmasmit@umich.edu
% 
% last updated: 31 July 2025
% determines ngine life cyle cost per engine
% 
%
%

%% SETUP  %%
%%%%%%%%%%%% 

% Cost categories (rows)
CostCategory= {
    'Acquisition'
    'Flight Costs'
    'Management'
    'MRO'
    'End of Life'
    'TOTAL'
};

n = numel(CostCategory);

% Initialize cost columns (placeholders)
TotalCost   = zeros(n,1);
AverageCost = zeros(n,1);

% Create table
EngineCostTable = table( ...
    CostCategory, ...
    TotalCost, ...
    AverageCost, ...
    'VariableNames', {'CostCategory','Total','Average'} ...
);

%% Life Cycle Overview %%
%%%%%%%%%%%%%%%%%%%%%%%%%

% aircraft life span (years)
span = 25;

% year into service
eis = 2025;

% make vector of operating years
oy = eis:1:eis+span; 
oy = oy';
n = length(oy);

% aircraft base case
range = 800; %nmi
fltime = 2; %hrs
fpd = 5; % flights per day

% FEC at end of  that year
FCye = cumsum(fpd.*365.*ones(size(oy)));
% FEC at year beginning
FCyi = [0;FCye(1:end-1)];

% MRO assumptions for conventional (Flight Equivalent Cycles)
SV1_FEC = 1e4; % intitial check, oiling, and repairs
SV2_FEC = 2e4; % full engine teardown, LLPs replacements

%% Engine Cost Values %%
%%%%%%%%%%%%%%%%%%%%%%%%

% initial aquisition cost
Initial_Cost = 12e6; % 2025

% battery pack cost by weight
battC_kg = 108 * .25; % $/kwh * kwh/kg;

% EM cost estimate by weight;
EMC_kg = 2000;

% flight energy costs
JetFuelkwh_Cost = 0.0712;
Electkwh_Cost   = 0.1152;

% energy inflation rate
r_JetFuel = 0.005; % $/kwh
r_Elect   = 0.039;

% jetfuel energy conversion
jetfuelspecE =  12; % kwh/kg

% base yar labor cost (per hour)
labor_cost = 170;
svLabor = 2200.*labor_cost;

% labor cost increase rate (%)
r_labor = 0.027;

% LLP replacement costs
LLPc = 4.2e6;

% base shop visit cost (no LLP replacement)
baseSVCost = svLabor + 1e6;

% major SV cost w/ LLP replacements
LLPcost = 2800.*labor_cost+LLPc;

% monitoring cost per FH estimate
monFH_eng = 100; % engine monitor per FH
monFH_batt = 20; % batt monitor per FH
monFH_EM = 10;   % EM monitor per FH

%% Acquisition Cost %%
%%%%%%%%%%%%%%%%%%%%%%
AcqC = Initial_Cost; % initial engine cost

% check for electronic engine components 
if Aircraft.Specs.Weight.Batt > 0
    AcqC = AcqC + Aircraft.Specs.Weight.Batt.*battC_kg; % battery weight estimate
end

if Aircraft.Specs.Weight.EM > 0
    AcqC = AcqC + Aircraft.Specs.Weight.EM.*EMC_kg; % EM weight estimate
end

%% Engine Moniotring Cost %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FHy = fltime.*FCye; % flight hours by year

% cost of monitoring engine by year
monC = FHy .* monFH_eng; 

% check for electronic engine components 
if Aircraft.Specs.Weight.Batt > 0
    monbatt = FHy.*monFH_batt; % battery monitoring cost estimate
    monC = monbatt + monC;
end

if Aircraft.Specs.Weight.EM > 0
    monEM = monC + FHy.*monFH_EM; % EM monitoring cost estimate
     monC = monEM + monC;
end


%% MRO Comparison and EGT 
% assumed EGT decay per cylc
rEGT = 5/1000; % conventional
% EGT_rateC = 4/1000; % hybrid derate (85%)

% max FEC between engine SVs
maxFEC = 10000; %for conventional
LLPfec = 20000; % max cycles for LLP replacement
% maxFEC = 20000; % for hybrid 

% assumed EGT drop first 2000 cycles
EGT2000c = 17; % conventional ac
% EGT2000c = 17;

% max EGT for new engine
maxEGT = 95; % for conventional
% maxEGT = 135; % for hybrid 

% get flight thrust rating
Aircraft.Settings.PowerStrat = 1;
Aircraft = PropulsionPkg.RecomputeSplits(Aircraft, 1, 102); %recompute poste sizing to get lamups
Aircraft.Settings.PowerStrat = -1;

PC = Aircraft.Mission.History.SI.Power.LamUps(:,1);
derate = 1-max(PC);

% EGT Margin per year
EGTi_year = zeros(n,1); % start of year
EGTe_year = zeros(n,1); % end of year
EGTi_year(1) = maxEGT;

% initial 2000c drop
EGTe_year(1) = EGTi_year(1) - EGT2000c;

% FEC of last SV
lastSV = 0; % start with no SV
% create empty array for SV FECs
SV = []; % column 1 for FEC, column 2 for EGT margin pre SV
recoverSV = .85; % percent of EGT margin restored through SV

% EGT margin decay per FEC iterated by years
for i = 2:n
    % get beginning EGT
    EGTbeg = EGTe_year(i-1);
    EGTi_year(i) = EGTbeg;
    % get values for current year
    FECbeg = FCyi(i);
    FECend = FCye(i);
    

    % final EGT margin
    EGTend = EGTbeg - (FECend-FECbeg).*rEGT;

    % check if end year FEC > maxFEC for SVs
    if FECend - lastSV > maxFEC 
        % SV FECs
        lastSV = lastSV + maxFEC;
        % egt margin before SV
        EGTpreSV = EGTbeg - (lastSV-FECbeg).*rEGT;
        % recover EGT margin for post SV
        EGTpstSV = EGTpreSV + (maxEGT - EGTpreSV)*recoverSV;
        % reduce EGT recovery after every SV
        recoverSV = 0.9 .* recoverSV;
        % save SV information
        SV = [SV; [lastSV, EGTpreSV, EGTpstSV]];
        % final EGT margin
        EGTend = EGTpstSV - (FECend-lastSV).*rEGT;
    
     % check if EGT margin lower than safe
    elseif EGTend < 0.2*maxEGT
        EGTpreSV = 0.2.*maxEGT;
        % determine SV FEC based on EGT 
        lastSV = (EGTbeg - EGTpreSV)./rEGT + FECbeg;
        % recover EGT margin for post SV
        EGTpstSV = EGTpreSV+ (maxEGT - EGTpreSV)*recoverSV;
        % reduce EGT recovery after every SV
        recoverSV = 0.9 .* recoverSV;
        % save SV information
        SV = [SV; [lastSV, EGTpreSV, EGTpstSV]];
        % final EGT margin
        EGTend = EGTpstSV - (FECend-lastSV).*rEGT;
    end
    % save EGT margin for next year
    EGTe_year(i)=EGTend;
end

% FEC of shop visit
SVcyc = SV(:,1);

SVcost = ones(length(SVcyc),1).*baseSVCost;

% multiples of LLC FEC up to max(x)
targets = LLPfec:LLPfec:ceil(max(SVcyc)/LLPfec)*LLPfec;

idx = arrayfun(@(t) find(SVcyc <= t, 1, 'last'), targets);
idx = idx(~isnan(idx)); 

SVcost(idx) = SVcost(idx)+LLPcost;

%% Flight Operating Cost %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

eFuel = Aircraft.Mission.History.SI.Energy.E_ES(end,1)./3.6e6;
fuelb = Aircraft.Specs.Weight.Fuel;
eBatt = Aircraft.Mission.History.SI.Energy.E_ES(end,2)./3.6e6;


% cummulative fuel burn each year
fuelb_year = zeros(size(oy)); % kg

% new engine 1 cycle fuel burn cost
fuelC = eFuel.*JetFuelkwh_Cost.*fpd.*365;

% FEC per year
FECy = fpd .* 365;

% SFC increases 0.1% for every 1-degree-C EGT margin lost
% iterate overyears and take average fuel burn for that year
for i = 1:n
    % get start and end FEC
    FECbeg = FCyi(i);
    FECend = FCye(i);
    
    % get year start and end EGT
    EGTbeg = EGTi_year(i);
    EGTend = EGTe_year(i);

    % beginning year fuel burn 
    ifuelb = ((maxEGT-EGTbeg)/1000 + 1).*fuelb;
    % end year fuel burn
    efuelb = ((maxEGT-EGTend)/1000 + 1).*fuelb;

    % check if a SV occurs
    iSV = find(SV(:,1)>=FECbeg & SV(:,1)<=FECend,1,'first');
    % if it does split average fuel for before and after SV and multipy by
    % cycles 
    if ~isempty(iSV)
        % pre SV fuel burn
        preSV_fuelb = ((maxEGT-SV(iSV,2))/1000 + 1).*fuelb;
        % determine average fuelburn pre SV
        fburnavgi = (ifuelb+preSV_fuelb)./2;

        % post SV fuel burn
        pstSV_fuelb = ((maxEGT-SV(iSV,3))/1000 + 1).*fuelb;
        % determine average fuelburn post SV
        fburnavge = (efuelb+pstSV_fuelb)./2;

        % determine full year avergae fuel burn
        fuelb_avg = (preSV_fuelb.*(SV(iSV,1)-FECbeg) + pstSV_fuelb.*(FECend- SV(iSV,1)))./(FECend-FECbeg); 
    else
        % if not just have one average 
        fuelb_avg = (ifuelb+efuelb)/2;
    end
    
    % total fuel burn per year
    fuelb_year(i) = fuelb_avg .* (FECend-FECbeg);

end

% convert fule burn to fuel energy and costs
fuelC_year = fuelb_year.*r_JetFuel.*jetfuelspecE;
%% EGT Plots

figure;
plot(FECy, fuelC_year)

%% Outputs %%
%%%%%%%%%%%%% 

% input costs into table
% aquisition
EngineCostTable.Total(1) = AcqC;
EngineCostTable.Average(1) = AcqC;

% flight costs
EngineCostTable.Total(2) = fuelC_year(end);
EngineCostTable.Average(2) = fuelb;

% monitoring costs
EngineCostTable.Total(3) = monC(end);
EngineCostTable.Average(3) = monC(1);

% MRO costs 
EngineCostTable.Total(4) = sum(SVcost);
EngineCostTable.Average(4) = baseSVCost;

% end-of-life costs 
EngineCostTable.Total(5) = 0;%EOL(end);
EngineCostTable.Average(5) = 0;%EOL(1);

% MRO costs 
EngineCostTable.Total(6) = sum(EngineCostTable.Total);
EngineCostTable.Average(6) = 0;


end

