function [] = DOERuns(FileName)
%
% [] = DOERuns()
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 16 jan 2026
%
% vary multiple technological and architectural parameters to identify the
% fuel burn and MTOW for each configuration. this data is used to create a
% surrogate model.
%
% INPUTS:
%     FileName - the name of the .xlsx file that should be imported for
%                running the experiments.
%                size/type/units: 1-by-1 / string / []
%
% OUTPUTS:
%     none
%

% initial cleanup
clc, close all


%% IMPORT THE PARAMETERS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read the table
MyTab = readtable(FileName);

% get the number of experiments
nexp = height(MyTab);

% extract the values
CrsSpeed   = table2array(MyTab(:,  1));
BattSpecEn = table2array(MyTab(:,  2));
P_Wem      = table2array(MyTab(:,  3));
P_Weg      = table2array(MyTab(:,  4));
LamTko     = table2array(MyTab(:,  5));
LamClb     = table2array(MyTab(:,  6));
LDInc      = table2array(MyTab(:,  7));
MaxPax     = str2double(table2array(MyTab(:,  8)));
PropArch   = str2double(table2array(MyTab(:,  9)));
NumDTE     = str2double(table2array(MyTab(:, 10)));
SerCells   = str2double(table2array(MyTab(:, 11)));

% allocate memory for results
Fuel = zeros(nexp, 1);
MTOW = zeros(nexp, 1);


%% RUN SIMULATIONS %%
%%%%%%%%%%%%%%%%%%%%%

% loop through all the samples
parfor iexp = 1:nexp
    
    % try to run it
    try
        
        % get the aircraft
        AC = AircraftSpecsPkg.RegionalTurboprop(0);
        
        % set the number of passengers
        AC.Specs.TLAR.MaxPax = MaxPax(iexp);
                
        % set the cruise speed (Mach 0.55 to Mach 0.65)
        AC.Specs.Performance.Vels.Crs = 0.55 + 0.1 * CrsSpeed(iexp);
        
        % set the electric motor and generator power-to-weight ratios
        % (from 3 to 7 kW/kg)
        AC.Specs.Power.P_W.EM = 3 + 4 * P_Wem(iexp);
        AC.Specs.Power.P_W.EG = 3 + 4 * P_Weg(iexp);
        
        % get the propulsion system architecture
        iarch = PropArch(iexp);
        
        % check the propulsion architecture
        if     (iarch == 2)
            
            % set the number of battery cells in series
            AC.Specs.Power.Battery.SerCells = SerCells(iexp);
            
            % set the takeoff and climb power splits
            AC.Specs.Power.LamDwn.SLS = (0 + 8 * LamTko(iexp)) / 100;
            AC.Specs.Power.LamDwn.Tko = (0 + 8 * LamTko(iexp)) / 100;
            AC.Specs.Power.LamDwn.Clb = (0 + 3 * LamClb(iexp)) / 100;
            
            % set the battery gravimetric specific energy
            AC.Specs.Power.SpecEnergy.Batt = 0.120 + 0.480 * BattSpecEn(iexp);
            
        else
            
            % make sure input are zero
            BattSpecEn(iexp) = 0;
            LamTko(    iexp) = 0;
            LamClb(    iexp) = 0;
            SerCells(  iexp) = 0;
            
        end
            
        if (iarch == 3)
            
            % set the number of distributed propulsors
            AC.Specs.Propulsion.NumDTE = NumDTE(iexp);
            
            % get the multiplicative factor (between 0 and 6%)
            LDMult = 1 + 6 * LDInc(iexp) / 100;
            
        else
            
            % make sure there is no multiplicative factor
            LDInc(iexp) = 0;
            
            % force the value to 1
            LDMult = 1;
            
        end
        
        % set the lift-to-drag ratios
        AC.Specs.Aero.L_D.Crs = AC.Specs.Aero.L_D.Crs * LDMult;
        AC.Specs.Aero.L_D.Clb = AC.Specs.Aero.L_D.Clb * LDMult;
        AC.Specs.Aero.L_D.Des = AC.Specs.Aero.L_D.Des * LDMult;
        
        % create the propulsion architecture
        AC = AircraftSpecsPkg.RegionalTurbopropPropulsion(AC, iarch);
        
        % size the aircraft
        ACOut = Main(AC, @MissionProfilesPkg.RegionalTurbopropMission);
        
        % get the fuel burn and MTOW
        Fuel(iexp) = ACOut.Specs.Weight.Fuel;
        MTOW(iexp) = ACOut.Specs.Weight.MTOW;
        
    catch
        
        % sample failed
        Fuel(iexp) = NaN;
        MTOW(iexp) = NaN;
        
    end    
end

% assemble results into table
NewTab = table(CrsSpeed, BattSpecEn, P_Wem, P_Weg, LamTko, LamClb, LDInc, ...
               MaxPax, PropArch, NumDTE, SerCells, Fuel, MTOW);
           
% get the prior row names
RowNames = MyTab.Properties.RowNames;

% update the current table
NewTab.Properties.RowNames = RowNames;


%% POST-PROCESSING %%
%%%%%%%%%%%%%%%%%%%%%

% get the string before .xlsx
Prefix = split(FileName, ".xlsx");

% write the table
writetable(NewTab, sprintf("%sComplete.xlsx", Prefix(1)));

% ----------------------------------------------------------

end