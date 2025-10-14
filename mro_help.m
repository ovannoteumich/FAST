%% EGT
cycles = 1:30000;
a = 0.104;
b = 0.659;

egt_loss1 = a.*cycles.^ b;
egt_loss2 = .08.*cycles.^ b;
egt_loss3 = .06.*cycles.^ .67;

figure;
plot(cycles, egt_loss1)
hold on
plot(cycles, egt_loss2)
plot(cycles, egt_loss3)
xlabel("FEC")
ylabel("EGT Loss Degrees C")
legend("Baseline", "Ex Derated 1", "Ex Derated 2")

%% mdot increase

egt_decay = linspace(0, 95,10);
fuelB = [];
Mdot = [];
inc = [];
inc(1) = 0;
Mdot(1) = Aircraft2.Specs.Propulsion.MDotCF;
Aircraft2.Specs.Performance.Range = UnitConversionPkg.ConvLength(800, "naut mi", "m");
Aircraft2.Settings.Analysis.Type = -1;
fuelB(1) = Aircraft2.Specs.Weight.Fuel;

for i = 2:length(egt_decay)
inc(i) = (egt_decay(i)-egt_decay(i-1)) .* .001 + 1;
Mdot(i)= inc(i) .* Mdot(i-1);
Aircraft2.Specs.Propulsion.MDotCF = Mdot(i);
Aircraft2.Specs.Power.LamUps = rmfield(Aircraft2.Specs.Power.LamUps, 'Miss');
Aircraft2.Specs.Power.LamDwn = rmfield(Aircraft2.Specs.Power.LamDwn, 'Miss');
Aircraft2 = Main(Aircraft2, @MissionProfilesPkg.NarrowBodyMission);
fuelB(i) = Aircraft2.Specs.Weight.Fuel;

end

figure;
plot(egt_decay,fuelB)
ylabel('FuelB')
yyaxis right
plot(egt_decay, Mdot)
xlabel('EGT Decay')
ylabel('Mdot_cf')