function [outputLD,outputStab] = SolverTest(geom)
% A test script for the Aero Solver.  Tests Lift from Drag with Alpha
% Newton step, and stability calculations
  conditions.alpha = 2.5; % (deg) guess of alpha for newton solver initialization, the closer the better... (maybe even use the slope from last step)
  conditions.alt = 10000; % (m)
  conditions.V = 180; % (m/s) or conditions.Mach = 0.6
  conditions.L = 280000; % (N) Lift at current condition
  conditions.T = 30000; % (N) Thrust approximation at current condition, prefer to use value from drag at previous point, which will be close enough
  conditions.TrimSurf = 2; % Surface Number used for trimming moment
  conditions.CG = [16,1.4,0]; % X,Y,Z coords (m) of the CG for stability and moment calcs
  conditions.Stab = false; % Stability calculations or not?  Creating variable for false is unnecessary

  outputLD = VLMPkg.AeroSolver(geom,conditions);

  clear conditions;

  conditions.alpha = 2.5; % (deg) guess of alpha for newton solver initialization, the closer the better... (maybe even use the slope from last step)
  conditions.alt = 10000; % (m)
  conditions.Mach = 0.6; % (m/s) or conditions.V = 180
  conditions.L = 280000; % (N) Lift at current condition
  conditions.T = 30000; % (N) Thrust approximation at current condition, prefer to use value from drag at previous point, which will be close enough
  conditions.TrimSurf = 2; % Surface Number used for trimming moment
  conditions.CG = [16,1.4,0]; % X,Y,Z coords (m) of the CG for stability and moment calcs
  conditions.Stab = true; % Stability calculations or not?  Creating variable for false is unnecessary

  outputStab = VLMPkg.AeroSolver(geom,conditions);
end