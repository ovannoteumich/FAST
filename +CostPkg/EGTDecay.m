function [] = EGTDecay()
n = 50;
a = 2.3;
d = linspace(0,.35,n);
EGTi = 95 .*exp(d .* a);

figure(1); clf;

plot(d*100, EGTi, 'k-', 'LineWidth', 2.0);   % black line, thicker
grid on;

xlabel('Derate (%)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Initial EGT Margin (°C)', 'FontSize', 14, 'FontWeight', 'bold');
title('PW1127G Initial EGT Margin vs Derate', 'FontSize', 16, 'FontWeight', 'bold');

set(gca, 'FontSize', 14, 'LineWidth', 1);  % makes axes thicker + bigger tick labels



EGT1000c = 10;
EGT2000c = 17;
ratec = 5;
EGTmax = 95;
recover = .85;
pts = 51;
%FEC = linspace(0,50, pts)';
FECa = [0;1;2];
EGTArray = [EGTmax; EGTmax-EGT1000c; EGTmax-EGT2000c];
%EGT = 95;
EGT = EGTArray(end);
i = 3;
deT = 1;

while i < 50

    EGT = EGT - ratec;
    EGTArray = [EGTArray; EGT];
    FECa = [FECa; i];

    if rem((i),10) == 0
         EGT = EGT+ (EGTmax - EGT)*recover;
         EGTArray = [EGTArray; EGT; EGT-EGT1000c; EGT-EGT2000c];
         FECa = [FECa; i; i+1; i+2];
         recover = recover * .9;
         %EGT1000c = EGT1000c*1.1;
         %EGT2000c = EGT2000c*1.1;
         EGT = EGTArray(end);
         i = i +2;
    end

   i=i + 1;

end

figure(2); clf;

plot(FECa, EGTArray, 'k-', 'LineWidth', 2.0);   % black line, thicker
grid on;

xlabel("FEC (x1000 cycles)", 'FontSize', 14, 'FontWeight', 'bold');
ylabel('EGT Margin Decay (°C)', 'FontSize', 14, 'FontWeight', 'bold');
title('PW1127G Initial EGT Margin vs Derate', 'FontSize', 16, 'FontWeight', 'bold');

set(gca, 'FontSize', 14, 'LineWidth', 1);


EGT1000c = 10;
EGT2000c = 17;
ratec = 4;
EGTmax = 135;
recover = .85;
pts = 51;
%FEC = linspace(0,50, pts)';
FECa = [0;1;2];
EGTArray = [EGTmax; EGTmax-EGT1000c; EGTmax-EGT2000c];
%EGT = 95;
EGT = EGTArray(end);
i = 3;
deT = 1;

while i < 50

    EGT = EGT - ratec;
    EGTArray = [EGTArray; EGT];
    FECa = [FECa; i];

    if EGT<60*deT 
        %|| rem((i),40) == 0
         EGT = EGT+ (EGTmax - EGT)*recover;
         EGTArray = [EGTArray; EGT; EGT-EGT1000c; EGT-EGT2000c];
         FECa = [FECa; i; i+1; i+2];
         recover = recover * .95;
         EGT = EGTArray(end);
         i = i +2;
         deT = deT * .8;
    end

   i=i + 1;

end


figure(3); clf;

plot(FECa, EGTArray, 'k-', 'LineWidth', 2.0);   % black line, thicker
grid on;

xlabel("FEC (x1000 cycles)", 'FontSize', 14, 'FontWeight', 'bold');
ylabel('EGT Margin Decay (°C)', 'FontSize', 14, 'FontWeight', 'bold');
title('PW1127G Initial EGT Margin vs Derate', 'FontSize', 16, 'FontWeight', 'bold');

set(gca, 'FontSize', 14, 'LineWidth', 1);



end