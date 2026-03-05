function [MTOW,SMP,SMY,scaled] = solverFunc(loc,grid)
% adjusts design variables to scale with bounds and builds and runs FAST
% loc = [nprop, propdiam, wingroot, wingload, aspectratio, taperratio, rootalpha, tipalpha, htailarea, vtailarea]
  scaled = loc;
  scaled(1) = (scaled(1)*(grid-1)+1)*2; % (#)
  scaled(2) = scale(scaled(2),[0.5 3]); % (m)
  scaled(3) = scale(scaled(3),[10 20]); % (m)
  scaled(4) = scale(scaled(4),[250 1000]); % (N/m^2)
  scaled(5) = scale(scaled(5),[8 16]); % (N/A)
  scaled(6) = scale(scaled(6),[0.25 1]); % (N/A)
  scaled(7) = scale(scaled(7),[-5,10]); % (deg)
  scaled(8) = scale(scaled(8),[-10,5]); % (deg)
  scaled(9) = scale(scaled(9),[6 14]); % (m^2)
  scaled(10) = scale(scaled(10),[5 10]); % (m^2)
  
  nprop = scaled(1);
  propdiam = scaled(2);
  wingroot = scaled(3);
  wingload = scaled(4);
  aspectratio = scaled(5);
  taperratio = scaled(6);
  rootalpha = scaled(7);
  tipalpha = scaled(8);
  htailarea = scaled(9);
  vtailarea = scaled(10);

  Aircraft = feval(strcat("AircraftSpecsPkg.HW1DTE",num2str(nprop)));
  
  Aircraft.Geometry = VLMPkg.AeroGeomsPkg.HW1();

  Aircraft.Geometry.Props.Number = round(nprop/2);
  Aircraft.Geometry.Props.Diameter = propdiam;
  Aircraft.Geometry.Props.X = wingroot-1.2 + ((1:round(nprop/2))-1)*0.4;
  Aircraft.Geometry.Props.Y = 1.1 + ((1:round(nprop/2))-1)*0.15*propdiam;
  Aircraft.Geometry.Props.Z = 4 + ((1:round(nprop/2))-1)*1.5*propdiam;

  Aircraft.Geometry.Surfaces{1}.RootX = wingroot;

  Aircraft.Specs.Aero.W_S.SLS = wingload;

  Aircraft.Geometry.Surfaces{1}.Span = aspectratio;
  Aircraft.Geometry.Surfaces{1}.Chord = [2-taperratio,1,taperratio];

  Aircraft.Geometry.Surfaces{1}.Twist = [rootalpha,(rootalpha+tipalpha)/2,tipalpha];

  VSold = Aircraft.Geometry.VTail.Height*mean(Aircraft.Geometry.VTail.Chord);
  Aircraft.Geometry.VTail.Height = Aircraft.Geometry.VTail.Height*sqrt(vtailarea/VSold);
  Aircraft.Geometry.VTail.Chord = Aircraft.Geometry.VTail.Chord*sqrt(vtailarea/VSold);
  Aircraft.Geometry.Surfaces{2}.RootY = Aircraft.Geometry.Fuselage.Diameter/2+Aircraft.Geometry.VTail.Height+0.1;

  HSold = Aircraft.Geometry.Surfaces{2}.Span*mean(Aircraft.Geometry.Surfaces{2}.Chord)*2;
  Aircraft.Geometry.Surfaces{2}.Span = Aircraft.Geometry.Surfaces{2}.Span*sqrt(htailarea/HSold);
  Aircraft.Geometry.Surfaces{2}.Chord = Aircraft.Geometry.Surfaces{2}.Chord*sqrt(htailarea/HSold);

  try
    warning('off','all');
    % Aircraft = test();
    [Aircraft,~] = Main(Aircraft,@MissionProfilesPkg.HW1VLM);
  
    MTOW = Aircraft.Specs.Weight.MTOW;
    SMP = Aircraft.Specs.Stability.SMp;
    SMY = Aircraft.Specs.Stability.SMy;
  catch
    MTOW = nan;
    SMP = nan;
    SMY = nan;
  end
end

function out = scale(in,bounds)
  out = in*(max(bounds) - min(bounds)) + min(bounds);
end

function [Aircraft] = test
  t = randi(10);
  pause(t)
  Aircraft.Specs.Weight.MTOW = 30;
  Aircraft.Specs.Stability.SMp = 40;
  Aircraft.Specs.Stability.SMy = 50;
end