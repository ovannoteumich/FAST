function [OutputTemp] = MotorHeatGen(InputTemp,mdot,Motor,WorkingFluid)

% Heat Added is simply motor inefficiency
q = Motor.Power*(1 - Motor.Eta);

% Q = MCAT inversed
delT = q / mdot / WorkingFluid.SpecificHeat;

% Add delta T
OutputTemp = InputTemp + delT;


end

