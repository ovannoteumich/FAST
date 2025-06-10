function [Aircraft] = DragPolar(Aircraft)
%
% [Aircraft] = DragPolar(Aircraft)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 10 jun 2025
%
% combine the drag coefficients into a single drag coefficient for further
% analysis. the zero-lift and lift-dependent drag coefficients are scaled
% prior to combining. sub/supersonic scale factors are are applied to the
% drag coefficients after combining into one. then, use the drag
% coefficient to compute the lift-drag ratio.
%
% INPUTS:
%     Aircraft - data structure with mission history and specifications.
%                size/type/units: 1-by-1 / struct / []
%
% OUTPUTS:
%     Aircraft - data structure with lift-drag ratio at the given flight
%                conditions.
%                size/type/units: npnt-by-1 / double / []
%


%% GET FLIGHT CONDITIONS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the segment id
SegsID = Aircraft.Mission.Profile.SegsID;

% get the beginning and ending control point indices
SegBeg = Aircraft.Mission.Profile.SegBeg(SegsID);
SegEnd = Aircraft.Mission.Profile.SegEnd(SegsID);

% get the mach number
Mach = Aircraft.Mission.History.SI.Performance.Mach(SegBeg:SegEnd);

% get the lift coefficient
CL = Aircraft.Mission.History.SI.Aero.CL(SegBeg:SegEnd);


%% COMPUTE CD %%
%%%%%%%%%%%%%%%%

% import the scale factors
ScaleCD0 = Aircraft.Specs.Aero.ScaleCD0;
ScaleCDI = Aircraft.Specs.Aero.ScaleCDI;
ScaleSub = Aircraft.Specs.Aero.ScaleSub;
ScaleSup = Aircraft.Specs.Aero.ScaleSup;

% compute the drag components
CD_SkinFric = AerodynamicsPkg.SkinFrictionDrag(Aircraft);
CD_Compress = AerodynamicsPkg.CompressibilityDrag(Aircraft);
CD_Pressure = AerodynamicsPkg.LiftDependentDrag(Aircraft);
CD_Induced  = AerodynamicsPkg.InducedDrag(Aircraft);

% check for windmilling drag
CD_Windmill = AerodynamicsPkg.WindmillDrag(Aircraft);

% compute CD0 (zero-lift drag coefficient)
CD0 = CD_SkinFric + CD_Compress + CD_Windmill;

% compute CDI (lift-dependent drag coefficient)
CDI = CD_Pressure + CD_Induced;

% compute the pre-scaled drag coefficients
PrescaleCD = CD0 .* ScaleCD0 + CDI .* ScaleCDI;

% index the supersonic ones
IdxSup = Mach > 1;

% scale all by the subsonic factor
CD = PrescaleCD .* ScaleSub;

% scale supersonic ones by its respective factor
CD(IdxSup) = CD(IdxSup) .* ScaleSup;

% store it in the mission history
Aircraft.Mission.History.SI.Aero.CD(SegBeg:SegEnd) = CD;


%% COMPUTE THE LIFT-DRAG RATIO %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% compute the lift-drag ratio
L_D = CL ./ CD;

% store it in the mission history
Aircraft.Mission.History.SI.Aero.L_D(SegBeg:SegEnd) = L_D;


end