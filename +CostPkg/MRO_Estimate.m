function [] = MRO_Estimate(Aircraft, Aircraft_Old)

% engiens tart with 95 EGT margin
% compute novel aircraft maintence cycles based on knownlegacy engine
% cycles
% would this be good to make a surrogate model of -- thinking having engine
% setting and time spent at it correlates to a margin temerature degrease
% to would be thrust x time x margin decrease

% for baseline: 
% first 1000 cycles is 15 degree decrease then 
% 5 degree decrease per 1000 EFC
% SV 1 allows moderate restoration
% sv 2 almost full restortion
% for every 1 degree increas MdotCF by .1%



Aircraft2 = Aircraft_Old;
Aircraft2.Specs.Performance.Range = UnitConversionPkg.ConvLength(800, "naut mi", "m");
Aircraft2.Settings.Analysis.Type = -1;

Aircraft2.Specs.Power.LamUps = rmfield(Aircraft2.Specs.Power.LamUps, 'Miss');
Aircraft2.Specs.Power.LamDwn = rmfield(Aircraft2.Specs.Power.LamDwn, 'Miss');
Aircraft2 = Main(Aircraft2, @MissionProfilesPkg.NarrowBodyMission);



end