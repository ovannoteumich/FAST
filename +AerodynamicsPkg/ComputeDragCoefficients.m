function [CD] = ComputeDragCoefficients(Inputs)
%
% [CD] = ComputeDragCoefficients(Inputs)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 28 may 2025
%
% combine the drag coefficients into a single drag coefficient for further
% analysis. the zero-lift and lift-dependent drag coefficients are scaled
% prior to combining. sub/supersonic scale factors are are applied to the
% drag coefficients after combining into one.
%
% INPUTS:
%     Inputs - data structure with all necessary information.
%              size/type/units: 1-by-1 / struct / []
%
% OUTPUTS:
%     CD     - drag coefficient at given flight conditions.
%              size/type/units: npnt-by-1 / double / []
%


%% PARSE INPUTS %%
%%%%%%%%%%%%%%%%%%

% import the scale factors
ScaleCD0 = Inputs.ZeroLiftDragCoeffFactor;
ScaleCDI = Inputs.LiftDependentDragCoeffFactor;
ScaleSub = Inputs.SubsonicDragCoeffFactor;
ScaleSup = Inputs.SupersonicDragCoeffFactor;


%% COMPUTE CD %%
%%%%%%%%%%%%%%%%

% compute the drag components
CD_SkinFric = AerodynamicsPkg.SkinFrictionDrag(Inputs);
CD_Compress = AerodynamicsPkg.CompressibilityDrag(Inputs);
CD_Pressure = AerodynamicsPkg.LiftDependentDrag(Inputs);
CD_Induced  = AerodynamicsPkg.InducedDrag(Inputs);

% compute CD0 (zero-lift drag coefficient)
CD0 = CD_SkinFric + CD_Compress;

% compute CDI (lift-dependent drag coefficient)
CDI = CD_Pressure + CD_Induced;

% compute the pre-scaled drag coefficients
PrescaleCD = CD0 .* ScaleCD0 + CDI .* ScaleCDI;

% get the mach numbers
Mach = Inputs.Mach;

% index the supersonic ones
IdxSup = Mach > 1;

% scale all by the subsonic factor
CD = PrescaleCD .* ScaleSub;

% scale supersonic ones by its respective factor
CD(IdxSup) = CD(IdxSup) .* ScaleSup;


end