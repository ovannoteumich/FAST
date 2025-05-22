function CDi = InducedDrag(Mach, Lift, P, Sref, AR, SpanEfficiencyFactor, SW25, TR, Redux, Gamma)
% COMPUTEINDUCEDDRAG Calculates induced drag coefficient
% Inputs:
%   Mach - Mach number
%   Lift - Lift force (lbf)
%   P - Static pressure (lbf/ft^2)
%   Sref - Wing reference area (ft^2)
%   AR - Aspect ratio
%   SpanEfficiencyFactor - Span efficiency factor
%   SW25 - Quarter chord sweep angle (degrees)
%   TR - Taper ratio
%   Redux - Boolean for span efficiency reduction
%   Gamma - Ratio of specific heats (default = 1.4)
%
% Outputs:
%   CDi - Induced drag coefficient

% Calculate lift coefficient
CL = 2.0 * Lift / (Sref * Gamma * P * Mach^2);

% Calculate span efficiency
if Redux
    % Adjustment for extreme taper ratios
    % Reference: DeYoung, John. "Advanced Supersonic Technology Concept Study Reference
    % Characteristics," NASA Contractor Report 132374.
    SpanEfficiency0 = 1.0 + 0.1 * AR * (0.4226 * sqrt(AR) - 0.35 * TR - 0.143);
else
    SpanEfficiency0 = 1.0;
end

if SpanEfficiencyFactor <= 0.3
    SpanEfficiency = SpanEfficiency0 + SpanEfficiencyFactor;
else
    SpanEfficiency = SpanEfficiency0 * SpanEfficiencyFactor;
end

% Calculate basic induced drag
CDi = CL^2 / (pi * AR * SpanEfficiency);

% If forward sweep, add Warner Robins Factor
if real(SW25) < 0.0
    DegToRad = pi / 180;  % Convert degrees to radians
    
    TH = (1.0 - TR) / (1.0 + TR) / AR;
    TanSw = tan(SW25 / DegToRad);
    COSA = 1.0 / sqrt(1.0 + (TanSw - 3.0 * TH)^2);
    COSB = 1.0 / sqrt(1.0 + (TanSw + TH)^2);
    CAYT = 0.5 * ((1.1 - 0.11 / (1.1 - Mach * COSA)) / (1.1 - 0.11 / (1.1 - Mach * COSB)) - 1.0)^2;
    
    CDi = CDi + CAYT * CL^2;
end

end