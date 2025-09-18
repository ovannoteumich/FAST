clear; clc; close all;

tic
AC_In = AircraftSpecsPkg.AEA;
AC_In.Settings.Plotting = 0;
% AC_In.Specs.Power.SpecEnergy.Batt = 0.8;

% size
AC_Out = Main(AC_In,@MissionProfilesPkg.AEAProfile)
toc

AC_Out.Specs.Weight
