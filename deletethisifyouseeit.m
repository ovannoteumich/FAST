
%% A320
clear; clc; close all;

tic
AC_In = AircraftSpecsPkg.A320Neo;
AC_In.Settings.Plotting = 0;

AC_Out = Main(AC_In,@MissionProfilesPkg.A320)
toc

AC_Out.Specs.Weight



%% CeRAS
clear; clc; close all;

tic
AC_In = AircraftSpecsPkg.CeRAS;
AC_In.Settings.Plotting = 0;

AC_Out = Main(AC_In,@MissionProfilesPkg.CeRAS)
toc

AC_Out.Specs.Weight

%% AEA

clear; clc; close all;

tic
AC_In = AircraftSpecsPkg.AEA;
AC_In.Settings.Plotting = 0;

AC_Out = Main(AC_In,@MissionProfilesPkg.AEAProfile)
toc

AC_Out.Specs.Weight