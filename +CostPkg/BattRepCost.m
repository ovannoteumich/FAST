function [Money] = BattRepCost(Aircraft, Year, BMS, Lifespan)
%
% written by Yipeng Liu, yipenglx@umich.edu
% last updated: 05 Jun 2025
%
% Compute the battery (and its battery management system if needed)
% replacement cost during the life cycle of the general battery energy
% storage system. Some parameters should be aware of updating year by year.
%
% INPUTS:
%     Aircraft      - structure with information about the aircraft's mission
%                     history and battery SOC after flying.
%                     size/type/units: 1-by-1 / struct / []
%
%     Year          - the calender year of the current study is at.
%                     size/type/units: 1-by-1 / integer / [years]
%
%     BMS           - providing the flexibility for the function input that
%                     whether user wants to consider the cost of BMS, or
%                     just battery cells cost solely. 1 - Yes, 0 - No.
%                     size/type/units: 1-by-1 / integer / []
%
%     Lifespan      - the lifespan of the specific battery system, from the
%                     analysis results. The unit is in years, i.e. 2, or 5
%                     years until the battery reaches to its EOL (70%).
%                     size/type/units: 1-by-1 / integer / [years]
%
% OUTPUTS:
%     Cost          - the battery (w/ or w/o BMS) replacement cost for its
%                     lifecycle.
%                     size/type/units: 1-by-1 / struct / [$]

%% BMS Cost Portion of Battery System Cost %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Call the LIB battery type from specs
BattType = Aircraft.Specs.Battery.Chem; % NMC = 1, LFP = 2

years_data = [2023, 2026, 2030, 2035]'; % [1]

% Choose the corresponding BMS portion for desired battery chem (if BMS is
% considered)
if BMS == 1

    if BattType == 1
    
        bms_nm  = [2, 2.2, 3, 3.5]';  % [1]
        coeffs_nm  = polyfit(years_data, bms_nm,  1);
        BMS_lambda = polyval(coeffs_nm, Year);%   For Ni/Mn (NMC), in %

    elseif BattType == 2
    
        bms_lfp = [2.2, 3.1, 3.5, 2.6]';  % [1]
        coeffs_lfp = polyfit(years_data, bms_lfp, 2); 
        BMS_lambda = polyval(coeffs_lfp, Year);%   For LFP, in %
    
    else
        error('Invalid ChemType input. Please input "1" for NMC or "2" for LFP.');
    end

elseif BMS == 0 % If user don't consider BMS cost portion
    BMS_lambda = 0;
else
    error('Invalid BMS requirement. Please input "1" for YES or "2" for NO.');
end

%% Unit Capacity Cost of the Battery [$/kWh] %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





end



%% Reference
% [1] Knehr, Kevin, Joseph Kubal, and Shabbir Ahmed. Cost analysis and
% projections for us-manufactured automotive lithium-ion batteries. No.
% ANL/CSE-24/1. Argonne National Laboratory (ANL), Argonne, IL (United
% States), 2024.   ------ Page 44, Table 29

