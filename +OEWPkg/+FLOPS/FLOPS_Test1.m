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

Range          = 2500    *UnitConversionPkg.ConvLength(1,'naut mi', 'm');
Pax            = 150;
Neng           = 2;
THRSO          = 25000 * Neng  *UnitConversionPkg.ConvForce(1,'lbf','N');
WingArea       = 3500    *UnitConversionPkg.ConvLength(1,'ft', 'm')^2;
FuelWeight     = 50000       *UnitConversionPkg.ConvMass(1,'lbm','kg');
Height         = 60      *UnitConversionPkg.ConvLength(1,'ft', 'm');
Sweep          = 30;
Fus_Length     = 200     *UnitConversionPkg.ConvLength(1,'ft', 'm');
Span           = 200     *UnitConversionPkg.ConvLength(1,'ft', 'm');
Taper          = 0.2;
MTOW           = 250000       *UnitConversionPkg.ConvMass(1,'lbm','kg');
FANDIAM        = 8     *UnitConversionPkg.ConvLength(1,'ft', 'm');
L_eng          = 12       *UnitConversionPkg.ConvLength(1,'ft', 'm');


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


Pred =       1.0e+05 * [   1.122529631662567
   0.120218706838717
   0.449223950063503
   0.062535285119653
   1.754507573684441
   ];

True = [112234
    12154
    44577
    175423 - 168964
    175423];

Diff = round((Pred - True) ./True * 100,4,'significant');


WeightGroup = ["Structural","Propulsion","Systems","Ops","OEW"]';


ErrTab = table(WeightGroup,round(Pred,4,'significant'),round(True,4,'significant'),Diff,'VariableNames',["Weight Group","Predicted (lbm)","True (lbm)","Difference"])







