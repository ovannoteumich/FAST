clear; clc; close all;

tic
AC_In = AircraftSpecsPkg.A320Neo;
AC_In.Settings.Plotting = 0;

AC_Out = Main(AC_In,@MissionProfilesPkg.A320)
toc

AC_Out.Specs.Weight
