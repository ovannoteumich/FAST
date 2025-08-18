function [Wengine, Wfan, Wcore, Wremaining] = WatersWeight(Engine)


%% Fan Weight



if isnan(Engine.GearRatio)
    GearRatio = 1;
else
    GearRatio = Engine.GearRatio;
end

Nfan = 1 + Engine.LPCStages + Engine.LPTStages;

Vtip = Engine.DiamFan / 2 * (Engine.LP100 / 60 * 2 * pi) / GearRatio;

ht = 0.35;

Wfan = Nfan * (Vtip/1000)^2 * (1 - ht^2) * 0.1902 * Engine.Airflow_SLS ^ 1.143;




%% Core Weight

Ncore = Engine.IPCStages + Engine.IPTStages + Engine.HPCStages + Engine.HPTStages;

Wcore = Ncore * 0.383 * Engine.CoreFlow^1.117;

%% Remaining Weight
if ~isnan(Engine.GearStages)
    L = 5.7882;
    k = -1/13.4166;
    y = -3.9446;
    C = 0.9320;
else
    L = 2.7576;
    k = -1/19.9267;
    y = 1.4497;
    C = 0.4644;
end

Wfrac = L./(1+exp(-k*(Engine.CoreFlow-y)))+ C;

Wremaining = Wcore * Wfrac;

Wengine = Wcore + Wremaining + Wfan;
end











% Digitized data from https://ntrs.nasa.gov/api/citations/19770012125/downloads/19770012125.pdf
% figure 6, kg not lb
% % Reference
% %% Digitized S-curves for the Remaining Weight
% close all; clear; clc;
%
%
% % Geared
% Geared = [7.583442601069386, 2.612564088471534
% 21.0720538932029, 1.646836208317957
% 54.82243665742799, 0.9812582932248768
% 13.47035638293697, 2.0242299568948594
% 32.67216538555153, 1.30937556433187
% 6.300888013002208, 2.9644088157471162];
%
% L = 5.7882;
% k = -1/13.4166;
% y = -3.9446;
% C = 0.9320;
% airflow = linspace(0,100);
% Scurve = L./(1+exp(-k*(airflow-y)))+ C;
%
% figure(1)
% hold on
% scatter(Geared(:,1),Geared(:,2),'bo','filled')
% plot(airflow,Scurve,'b--')
% axis([-10 160 0 4])
% grid on
%
%
% % Ungeared
% Ungeared = [26.023256361737715, 1.063589896594772
% 60.0945722069989, 0.6442216342265801
% 98.47463549068411, 0.4808460855978578
% 18.37032733211373, 1.2952584345532059
% 40.46936708463212, 0.8214159528277438
% 80.2132487457111, 0.537346011007906];
%
% L = 2.7576;
% k = -1/19.9267;
% y = 1.4497;
% C = 0.4644;
% airflow = linspace(0,150);
% Scurve = L./(1+exp(-k*(airflow-y)))+ C;
%
% hold on
% scatter(Ungeared(:,1),Ungeared(:,2),'rd','filled')
% plot(airflow,Scurve,'r--')
%
%
% legend("Geared Data","Geared Fit","Nongeared Data","Nongeared Fit",'location','best')
%
% ylabel("Remaining Weight / Core Weight")
% xlabel("Core Airflow (kg/s)")
%









