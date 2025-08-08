
clear; clc;

Ceras = EngineModelPkg.TurbofanNonlinearSizing(EngineModelPkg.EngineSpecsPkg.CeRAS);

PW1919 = EngineModelPkg.TurbofanNonlinearSizing(EngineModelPkg.EngineSpecsPkg.PW_1919G);

Leap = EngineModelPkg.TurbofanNonlinearSizing(EngineModelPkg.EngineSpecsPkg.LEAP_1A26);

P_T = [Ceras.LPTObject.DelivWork / Ceras.Thrust.Bypass
PW1919.LPTObject.DelivWork / PW1919.Thrust.Bypass
Leap.LPTObject.DelivWork / Leap.Thrust.Bypass];


% Use this value to get rough conversion of LPT power to thrust conversion
mean(P_T)


