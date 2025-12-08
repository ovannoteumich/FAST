% PW 1100 G taxi study for Bada Coefficicents
slsT = 120.4; %kN
PC = [1, .85, .3, .07];
ff = [.8, .67, .2322, .08];
tsfc = ff ./ (PC.*slsT);

Cff3    =  0.4006;
Cff2    = -0.4323;
Cff1    =  0.9946;
Cffch   =  6.1*10^-7;
HEcoeff =  1;

%mff = Cff3 .* 