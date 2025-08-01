clc; clear;

%% A320Neo Testing ; A320()
% call main
A320Neo = Main(AircraftSpecsPkg.A320Neo(), @MissionProfilesPkg.A320)

% collect variables of interest
Weights_A320 = A320Neo.Specs.Weight;
Slits_Up_A320 = A320Neo.Mission.History.SI.Power.LamUps;
DesignStrat_A320 = A320Neo.Specs.Propulsion.DesignStrategy;
NumStrat_A320 = A320Neo.Specs.Propulsion.NumStrats;

%% AEA Testing ; AEAProfile()
% call main
AEA = Main(AircraftSpecsPkg.AEA(), @MissionProfilesPkg.AEAProfile)

% collect variables of interest
Weights_AEA = AEA.Specs.Weight;
Slits_Up_AEA = AEA.Mission.History.SI.Power.LamUps;
DesignStrat_AEA = AEA.Specs.Propulsion.DesignStrategy;
NumStrat_AEA = AEA.Specs.Propulsion.NumStrats;


%% ATR42 Testing ; ATR42_600()


%% ERJ175LR Testing ; ERJ()


%% ERJ190_E2 Testing ; ERJ()


%% ERJ190_FE Testing ; ERJ()


%% Example Testing ; NotionalMission00()


%% Example Testing ; RegionalJetMission00()


%% Example Testing ; TurboPropMission00()


%% Example Testing ; ParametricReegional()


%% Example Testing ; BRECruise00()


%% LM100J_Conventional Testing ; LM100J()


%% LM100J_Hybrid Testing ; LM100J()