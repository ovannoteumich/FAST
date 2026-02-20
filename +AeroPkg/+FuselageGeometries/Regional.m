function fuselage = Regional()
% Regional (smol, 2-2) jet fuselage geometry
%   Input Base Values for fuselage, with spline components for nosecone and
%   tailcone
  
  fuselage.Diameter = 2.6; % (m) Cylindrical Tube Diameter
  fuselage.CylBaseLength = 4; % (m) Added Required Length to the cylindrical section, can be negative, but cylinder length with pax cannot be.
  fuselage.PaxRow = 4; % Passengers Per Row.  Required Passengers will take a max of the mod for number of rows in meshing
  fuselage.RowSpacing = UnitConversionPkg.ConvLength(37,"in","m"); % Spacing per row.  Take some regression data or something idk.  Regional Turboprops do not have lay downs lol

  % These values define splines that define the nosecone of the fuselage,
  % appended in meshing by a 0, 0, 1 to make the nosecone flush.  Last
  % element of Radii must be zero
  fuselage.Nose.XPos = [-1, -1.5, -2, -2.2]; % (unitless) Position from cylinder normalized by fuselage.Diameter of fuselage spline control points, -x is further forward
  fuselage.Nose.YPos = [-0.15, -0.25, -0.4, -0.45]; % (unitless) normalized by fuselage.Diameter Y offset for centerline of non-circular fuselage shaping
  fuselage.Nose.Radii = [0.83, 0.65, 0.3, 0]; % (unitless) normalized by fuselage.Diameter radii of cross sections of fuselage for non-circular segments (1 is fuselage diameter)
  fuselage.Nose.Spline = "pchip"; % argument for interp1, i.e. 'linear', 'cubic', 'pchip', 'makima'

  % These values define splines that define the tailcone of the fuselage,
  % appended in meshing by a 0, 0, 1 to make the tailcone flush.  Last
  % element of Radii must be zero
  fuselage.Tail.XPos = [1, 4]; % (unitless) Position from cylinder normalized by fuselage.Diameter of fuselage spline control points, +x is further backward
  fuselage.Tail.YPos = [0.05,1]; % (unitless) normalized by fuselage.Diameter Y offset for centerline of non-circular fuselage shaping
  fuselage.Tail.Radii = [0.95,0]; % (unitless) normalized by fuselage.Diameter radii of cross sections of fuselage for non-circular segments (1 is fuselage diameter)
  fuselage.Tail.YSpline = "makima"; % argument for interp1, i.e. 'linear', 'cubic', 'pchip', 'makima'
  fuselage.Tail.RSpline = "makima"; % argument for interp1, i.e. 'linear', 'cubic', 'pchip', 'makima'

end