function [CDi] = InducedDrag(Inputs)
%
% [CDi] = InducedDrag(Inputs)
% modified by Paul Mokotoff, prmoko@umich.edu
% patterned after Aviary's "compute" method in induced_drag.py,
% translated by Cursor, an AI Code Editor
% last updated: 27 may 2025
%
% INPUTS:
%     Inputs - data structure with all necessary inputs.
%              size/type/units: 1-by-1 / struct / []
%
% OUTPUTS:
%     CDi    - induced drag coefficient.
%              size/type/units: 1-by-1 / double / []
%


%% PARSE INPUTS %%
%%%%%%%%%%%%%%%%%%

% get all inputs
Mach = Inputs.Mach;
Lift = Inputs.Lift;
P = Inputs.P;
Sref = Inputs.Sref;
AR = Inputs.AR;
SpanEfficiencyFactor = Inputs.SpanEfficiencyFactor;
SW25 = Inputs.SW25;
TR = Inputs.TR;
Gamma = Inputs.Gamma;
Redux = Inputs.Redux;


%% COMPUTE THE INDUCED DRAG COEFFICIENT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% calculate the lift coefficient
CL = 2.0 * Lift / (Sref * Gamma * P * Mach ^ 2);

% check for the redux flag
if (Redux)
    
    % adjust for extreme taper ratios
    % Reference: DeYoung, John. "Advanced Supersonic Technology Concept Study Reference
    % Characteristics," NASA Contractor Report 132374.
    SpanEfficiency0 = 1.0 + 0.1 * AR * (0.4226 * sqrt(AR) - 0.35 * TR - 0.143);
    
else
    
    % assume a perfect efficiency scale factor
    SpanEfficiency0 = 1.0;
    
end

% modify the span efficiency factor
if (SpanEfficiencyFactor <= 0.3)
    
    % add to the existing one
    SpanEfficiency = SpanEfficiency0 + SpanEfficiencyFactor;
    
else
    
    % scale the existing one
    SpanEfficiency = SpanEfficiency0 * SpanEfficiencyFactor;
    
end

% calculate the basic induced drag
CDi = CL^2 / (pi * AR * SpanEfficiency);

% if forward sweep, add Warner Robins Factor
if real(SW25) < 0.0
    
    % convert degrees to radians
    DegToRad = pi/180;
    
    % compute scale factors
    TH = (1.0 - TR) / (1.0 + TR) / AR;
    TanSW = tan(SW25 / DegToRad);
    COSA = 1.0 / sqrt(1.0 + (TanSW - 3.0 * TH)^2);
    COSB = 1.0 / sqrt(1.0 + (TanSW + TH)^2);
    CAYT = 0.5 * ((1.1 - 0.11/(1.1 - Mach * COSA))/(1.1 - 0.11/(1.1 - Mach * COSB)) - 1.0)^2;
    
    % scale the induced drag coefficient
    CDi = CDi + CAYT * CL^2;
    
end


end