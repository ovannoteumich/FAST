function geom = HW1()
% Baseline geometry of the aircraft.  Can be modified externally.
%   For a regional turboprop with distributed turboelectric type bit
%   Fully Symmetrical, no asymmetries allowed, because Rutan is probably in
%   the Epstein files or something idk

  geom.Pax = 90;

  geom.Fuselage = VLMPkg.FuselageGeometries.Regional();

  geom.AreaSurf = 1; % the surface scaled to get the correct w/s and stuff in the sizing code

  % Values assumed to be zero (or one, for stuff like chord lengths or
  % thiccnesses) unless specified here.

  % Single values always valid for distributions, but if using control
  % points, exactly one allowed per control point specified, and organized
  % and ordered from root to tip.

  Wing.Airfoil = VLMPkg.AirfoilGeometries.NACA(23110);

  Wing.NumCtrlPts = 3; % number of spanwise control points on each half of wing
  Wing.Spacing = 1.5; % 0: uniform, 1: concentrated at root and tip evenly, -1: concentrated at center evenly, >1: concentration towards the tip at the power specified, <-1: concentration towards the root at the negative of the power specified

  Wing.Span = 25; % (m)

  Wing.RootX = 15; % (m) downstream from tip, these snap to the outside of the fuselage basically, and calculate span from there in z direction
  Wing.RootY = 0.85; % (m) above the centerline of fuselage cylinder
  Wing.RootBase = 0; % 0, means centered on leading edge, 1 means centered on trailing edge, defaults to 0.25

  Wing.Hedral = 3; % (deg), no base, as it is all around the chord as a rotation axis.  // distributions can maybe be made to add winglets if you are a tryhard
  
  Wing.Sweep = 30; % (deg) scalar only supported for now.
  Wing.SweepBase = 0; % from root so the leading edge is a straight line;

  Wing.Chord = [5, 3, 1]; % (m) no base, as everything is handled by taper base
  Wing.ChordSmoothing = 'linear'; % argument for interp1, i.e. 'linear', 'cubic', 'pchip', 'makima'

  Wing.Twist = [3, 0, -1]; % (deg) 0 is aligned with fuselage, note: there is no default AoA, this handles it by default.
  Wing.TwistBase = 0.25; % twist around quarter chord
  Wing.TwistSmoothing = 'makima'; % argument for interp1, i.e. 'linear', 'cubic', 'pchip', 'makima'


  HTail.Airfoil = VLMPkg.AirfoilGeometries.NACA(0010);

  HTail.NumCtrlPts = 2;

  HTail.Span = 3;

  HTail.RootX = 32.4; % (m) snaps to edge of VTail
  HTail.RootY = 4.5; % (m) should be mounted as a T tail
  HTail.RootBase = 0; % fixed at LE

  HTail.Sweep = 0; % (deg) Flat Trailing edge basically
  HTail.SweepBase = 1; % Trailing edge

  HTail.Chord = [1.5, 0.7]; % (m) Defaults to linear interp if not otherwise noted, and always in NumCtrlPts = 2

  HTail.Twist = -1; % (deg) -1 degree angle of attack relatve to fuselage across full span


  geom.Surfaces = {Wing,HTail}; % Holds all horizontal(ish) surfaces for looping over in the mesh generation phase.

  % VTail is required and basically builds half of an airfoil that is fixed
  % to the symmetry plane on top of the fuselage
  geom.VTail.NumCtrlPts = 2; % No Airfoil, as NACA 00xx series is only one allowed

  geom.VTail.Height = 3; % (m) height above fuselage

  geom.VTail.RootX = 30.5; % (m) no RootY, because it snaps to top of fuselage.
  geom.VTail.RootBase = 1;

  geom.VTail.Sweep = 5; % (deg)
  geom.VTail.SweepBase = 1; % almost flat trailing edge

  geom.VTail.Chord = [3, 1.5]; % (m) Chord lengths for the VTail

  % Propellers, defined individually or together.  Diameters, position
  % specified, properties automatic in mesher and solver.
  % NOTE: DO NOT PUT THESE BEHIND A HORIZONTAL FLOW COMPONENT.  IT WILL
  % BREAK THE WHOLE THING AND YOU WILL CRY.
  geom.Props.Number = 3; % Number of propellors on each side, so in this case, 6 in total.
  
  geom.Props.Diameter = 2.5; % (m) DIAMETER of each propeller (can be not all the same with an array of size of Number)

  geom.Props.X = [13.8, 14.2, 14.6]; % (m) x distance back from tip of the fuselage
  geom.Props.Y = [1.1, 1.3, 1.5]; % (m) y distance up from fuselage centerline
  geom.Props.Z = [4, 8, 12]; % (m) z distance out from centerline
end