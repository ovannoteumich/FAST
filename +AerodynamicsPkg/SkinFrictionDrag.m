function [CDF] = SkinFrictionDrag(Inputs)
%
% [SkinFrictionDragCoeff] = SkinFrictionDrag(Inputs)
% modified by Paul Mokotoff, prmoko@umich.edu
% patterned after Aviary's "compute" method in skin_friction_drag.py,
% translated by Cursor, an AI Code Editor
% last updated: 28 may 2025
%
% compute the skin friction drag coefficient for a given aircraft
% configuration.
%
% INPUTS:
%     Inputs  - data structure with all necessary inputs.
%               size/type/units: 1-by-1 / struct / []
%
% OUTPUTS:
%     CDF     - skin friction drag coefficient
%               size/type/units: npnt-by-1 / double / []
%


%% PROCESS INPUTS AND OPTIONS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract the inputs
Cf       = Inputs.SkinFrictionCoeff; % (npnt-by-ncomp)
Re       = Inputs.Re; % (npnt-by-ncomp)
Fineness = Inputs.FinenessRatios; % (1-by-ncomp)
Swet     = Inputs.WettedAreas; % (1-by-ncomp)
LamUp    = Inputs.LaminarFractionsUpper; % (1-by-ncomp)
LamLow   = Inputs.LaminarFractionsLower; % (1-by-ncomp)
Swing    = Inputs.WingArea; % scalar
AirfoilTech      = Inputs.AirfoilTechnology; % scalar
ExcrescencesDrag = Inputs.ExcrescencesDrag; % scalar


%% COMPUTE THE SKIN FRICTION DRAG COEFFICIENT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check for laminar flow fractions
LaminarFlow = any(LamUp > 0.0) | any(LamLow > 0.0);

% check if laminar flow coefficients must be calculated
if (LaminarFlow == 1)
    
    % compute the laminar flow coefficients
    LaminarUpper = CalcLaminarFlow(LamUp );
    LaminarLower = CalcLaminarFlow(LamLow);
    
    % update the skin friction coefficient
    Cf = Cf - 0.5 * (Cf - 1.328 ./ sqrt(Re)) .* (LaminarLower + LaminarUpper);
    
end

% allocate memory for the form factor
FormFactor = zeros(1, length(Fineness));

% define the factor coefficients
F = [4.34255, -1.14281,  0.171203,    -0.0138334,    0.621712e-3,      0.137442e-6, -0.145532e-4, ...
     2.94206,  7.16974, 48.8876  , -1403.02     , 8598.76       , -15834.3        ,  4.275      ] ;

% get bodies with fineness ratio greater than 0.5
IdxBody = find(Fineness > 0.5);

% remember their fineness
Fine = Fineness(IdxBody);

% for these bodies, compute the form factor
FormFactor(IdxBody) = F(1) + Fine .* (F(2) + Fine .* (F(3) + Fine .* (F(4) + ...
    Fine .* (F(5) + Fine .* (F(6) .* Fine + F(7))))));

% set a cutoff for the maximum form factor
FormFactor(Fineness >= 20.0) = 1.0;

% get bodies with a fineness ratio less than or equal to 0.5
IdxSurf = find(Fineness <= 0.5);

% remember their fineness
Fine = Fineness(IdxSurf);

% calculate the form factor coefficients
FF1 = 1.0 + Fine .* (F(8) + Fine .* (F(9) + Fine .* (F(10) + Fine .* (F(11) + Fine .* (F(12) + Fine .* F(13))))));
FF2 = 1.0 + Fine .* F(14);

% remember the form factors for these surfaces
FormFactor(IdxSurf) = FF1 .* (2.0 - AirfoilTech) + FF2 .* (AirfoilTech - 1.0);

% calculate the skin friction drag coefficient
CDF = sum(Swet .* Cf .* FormFactor, 2) ./ Swing;

% account for excresence drag (usually 6%)
CDF = CDF .* (1.0 + ExcrescencesDrag);


end

% ----------------------------------------------------------
% ----------------------------------------------------------
% ----------------------------------------------------------

function [LamFlowCoeff] = CalcLaminarFlow(LamFrac)
%
% [LamFlowCoeff] = CalcLaminarFlow(LamFrac)
% modified by Paul Mokotoff, prmoko@umich.edu
% patterned after Aviary's "compute" method in skin_friction_drag.py,
% translated by Cursor, an AI Code Editor
% last updated: 23 may 2025
%
% compute the laminar flow coefficient.
%
% INPUTS:
%     LamFrac      - laminar fraction.
%                    size/type/units: m-by-n / double / []
%
% OUTPUTS:
%     LamFlowCoeff - the laminar flow coefficient.
%                    size/type/units: m-by-n / double / []
%

% compute the laminar flow coefficient
LamFlowCoeff = LamFrac .* (0.0064164 + LamFrac .* (0.48087e-4 - 0.12234e-6 .* LamFrac));

end