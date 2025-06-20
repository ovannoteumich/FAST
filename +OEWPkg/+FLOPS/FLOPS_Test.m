%{
1....Range
2....Pax
3....Neng
4....Thrust
5....Wing_Area
6....Fuel_Weight
7....Height
8....Sweep
9....Fus_Length
10...Span
11...Taper Ratio
12...MTOW 
13...Fan Diameter
14...Length Engine
15...Engine Dry Weight
%}
clear; clc

Range          = 4000    *UnitConversionPkg.ConvLength(1,'naut mi', 'm');
Pax            = 250;
Neng           = 3;
THRSO          = 40000 * Neng  *UnitConversionPkg.ConvForce(1,'lbf','N');
WingArea       = 5500    *UnitConversionPkg.ConvLength(1,'ft', 'm')^2;
FuelWeight     = 75000       *UnitConversionPkg.ConvMass(1,'lbm','kg');
Height         = 90      *UnitConversionPkg.ConvLength(1,'ft', 'm');
Sweep          = 27;
Fus_Length     = 300     *UnitConversionPkg.ConvLength(1,'ft', 'm');
Span           = 250     *UnitConversionPkg.ConvLength(1,'ft', 'm');
Taper          = 0.3;
MTOW           = 550000       *UnitConversionPkg.ConvMass(1,'lbm','kg');
FANDIAM        = 12     *UnitConversionPkg.ConvLength(1,'ft', 'm');
L_eng          = 16       *UnitConversionPkg.ConvLength(1,'ft', 'm');


Params = [Range
    Pax
    Neng
    THRSO
    WingArea
    FuelWeight
    Height
    Sweep
    Fus_Length
    Span
    Taper
    MTOW
    FANDIAM
    L_eng];

OEWPkg.FLOPS.FLOPS_OEW(Params,1);


% Structs
% Propulsion
% Systems
% Ops
% OEW


Outs =       1.0e+05 * [   3.029808580104006
   0.290024540802488
   0.930124657140155
   0.113057511173138
   4.363015289219788
   ];

Trues = [293078
    29441
    90388
    424726 - 412907
    424726];

(Outs - Trues) ./Trues * 100








