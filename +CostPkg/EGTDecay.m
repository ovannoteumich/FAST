function [] = EGTDecay()
EGT1000c = 10;
EGT2000c = 17;
ratec = 3;
EGTmax = 95;
recover = .8;
pts = 51;
%FEC = linspace(0,50, pts)';
FECa = [0;1;2];
EGTArray = [95; 95-EGT1000c; 95-EGT2000c];
%EGT = 95;
EGT = EGTArray(end);
i = 3;

while i < 50

    EGT = EGT - ratec;
    EGTArray = [EGTArray; EGT];
    FECa = [FECa; i];

    if rem((i),10) == 0
         EGT = EGT+ (EGTmax - EGT)*recover;
         EGTArray = [EGTArray; EGT; EGT-EGT1000c*1.2; EGT-EGT2000c*1.2];
         FECa = [FECa; i; i+1; i+2];
         recover = recover * .9;
         EGT1000c = EGT1000c*1.1;
         EGT2000c = EGT2000c*1.1;
         EGT = EGTArray(end);
         i = i +2;
    end

   i=i + 1;

end


figure(1);
plot(FECa, EGTArray)

figure(1);
plot(fhs2, egtMarg2)
xlabel("FEH")
ylabel("EGT Margin Decay")
hold on
plot(fhs3, egtMarg3)
plot(fhs4, egtMarg4)
yline(100, "-r")
yline(88, "-c")
yline(70, "-m")
scatter(dataCFM52(:,1),dataCFM52(:,2), "*")
scatter(dataCFM53(:,1),dataCFM53(:,2), "o")
scatter(dataCFM54(:,1),dataCFM54(:,2), "x")
legend("-5C2", "-5C3", "-5C4", "Redline -5C2", "Redline -5C3", "Redline -5C4", "-5C2 Data", "-5C3 Data", "-5C4 Data")


end