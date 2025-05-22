function CDF = SkinFrictionDrag(Cf, Re, Fineness, WettedArea, LamUp, LamLow, MissionWingArea, F, Airfoil, ExcrescencesDrag)
% Inputs:
% Cf: skin friction coefficients (matrix)
% Re: Reynolds numbers (matrix)
% Fineness: fineness ratios (vector)
% WettedArea: wetted areas (vector)
% LamUp: upper surface laminar flow fractions (vector)
% LamLow: lower surface laminar flow fractions (vector)
% MissionWingArea: wing area (scalar)
% F: form factor coefficients (vector)
% Airfoil: airfoil technology factor (scalar)
% ExcrescencesDrag: excrescences drag factor (scalar)

% Get number of components
Nc = length(Fineness);

% Check for laminar flow
LaminarFlow = any(LamUp > 0.0) | any(LamLow > 0.0);

if LaminarFlow
    % Calculate laminar flow effects
    LaminarUpper = CalcLaminarFlow(LamUp);
    LaminarLower = CalcLaminarFlow(LamLow);
    Cf = Cf - 0.5 * (Cf - 1.328 ./ sqrt(Re)) .* (LaminarLower + LaminarUpper);
end

% Initialize form factor array
FormFactor = zeros(Nc, 1);

% Form factor for bodies (Fineness > 0.5)
IdxBody = find(Fineness > 0.5);
Fine = Fineness(IdxBody);

% Calculate form factor for bodies using Horner's method
FormFactor(IdxBody) = F(1) + Fine .* (F(2) + Fine .* (F(3) + Fine .* (F(4) + ...
    Fine .* (F(5) + Fine .* (F(6) * Fine + F(7))))));

% Set form factor to 1.0 for very high fineness ratios
FormFactor(Fineness >= 20.0) = 1.0;

% Form factor for surfaces (Fineness <= 0.5)
IdxSurf = find(Fineness <= 0.5);
Fine = Fineness(IdxSurf);

% Calculate form factors for surfaces
FF1 = 1.0 + Fine .* (F(8) + Fine .* (F(9) + Fine .* (F(10) + Fine .* (F(11) + ...
    Fine .* (F(12) + Fine .* F(13))))));
FF2 = 1.0 + Fine .* F(14);

FormFactor(IdxSurf) = FF1 .* (2.0 - Airfoil) + FF2 .* (Airfoil - 1.0);

% Calculate skin friction drag coefficient
CDF = sum(WettedArea .* Cf .* FormFactor) / MissionWingArea;

% Add excrescences drag
CDF = CDF * (1.0 + ExcrescencesDrag);
end

function Lam = CalcLaminarFlow(LamFrac)
% Helper function to calculate laminar flow effects
Lam = LamFrac .* (0.0064164 + LamFrac .* (0.48087e-4 - 0.12234e-6 * LamFrac));
end