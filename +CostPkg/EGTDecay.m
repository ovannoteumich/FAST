%function [Aircraft] = EGTDecay(Aircraft)

% function that determines EGT decay coefficient values based on hotsection
% derating

n = 200;

fec = linspace(0,30000, n);


a = 0.08;
b = 0.659;

egtMarg = a.*fec.^b;

figure;
plot(fec, egtMarg)
xlabel("FEC")
ylabel("EGT Margin del Temp")
%end
%%
dataCFM52 = [1000, 6;2000, 10; 15000, 45];
dataCFM53 = [1000, 7; 2000, 14; 15000, 45];
dataCFM54 = [1000, 10;2000, 18; 13000, 48];

n =1000;
fhs2 = linspace(0, 30000, n);
egtMarg = zeros(n,1);

a2 = .13;
b2 = 0.6;

egtMarg2 = a2.*fhs2.^b2;

sv1 = 18000;
sv2 = 28000;

[~,i1] = find(sv1-fhs2 < 0,1);
recover1 = 30;
egtMarg2(i1:end) = a2.*(fhs2(i1:end)-sv1).^b2 + recover1;
[~,i2] = find(sv2-fhs2 < 0,1);
recover2 = 45;
egtMarg2(i2:end) = a2.*(fhs2(i2:end)-sv2).^b2 + recover2;

a3 = 0.14;
b3 = 0.61;
fhs3 = linspace(0, 30000, n);
egtMarg3 = a3.*fhs3.^b3;

sv1 = 17000;
sv2 = 26000;

[~,i1] = find(sv1-fhs3 < 0,1);
recover1 = 25;
egtMarg3(i1:end) = a3.*(fhs3(i1:end)-sv1).^b3 + recover1;
[~,i2] = find(sv2-fhs3 < 0,1);
recover2 = 40;
egtMarg3(i2:end) = a3.*(fhs3(i2:end)-sv2).^b3 + recover2;

fhs4 = linspace(0, 25000, n);
sv1 = 13000;
sv2 = 20000;
a4 = 0.15;
b4 = 0.62;

egtMarg4 = a4.*fhs4.^b4;

[~,i1] = find(sv1-fhs4< 0,1);
recover1 = 30;
egtMarg4(i1:end) = a4.*(fhs4(i1:end)-sv1).^b4 + recover1;
[~,i2] = find(sv2-fhs4 < 0,1);
recover2 = 35;
egtMarg4(i2:end) = a4.*(fhs4(i2:end)-sv2).^b4 + recover2;

figure;
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


%%

n =1000;
fhs = linspace(0, 40000, n);
egtMarg = zeros(n,1);

a2 = .13;
b2 = 0.61;

egtMarg2 = a2.*fhs.^b2;

sv1 = 10000;
sv2 = 20000;
sv3 = 30000;

[~,i1] = find(sv1-fhs < 0,1);
recover1 = 20;
egtMarg2(i1:end) = a2.*(fhs(i1:end)-sv1).^b2 + recover1;
[~,i2] = find(sv2-fhs < 0,1);
recover2 = 45;
egtMarg2(i2:end) = a2.*(fhs(i2:end)-sv2).^b2 + recover2;
[~,i3] = find(sv3-fhs < 0,1);
recover2 = 60;
egtMarg2(i3:end) = a2.*(fhs(i3:end)-sv3).^b2 + recover2;

a2 = .12;
b2 = 0.59;

egtMarg3 = a2.*fhs.^b2;

sv1 = 11000;
sv2 = 22000;
sv3 = 33000;

[~,i1] = find(sv1-fhs < 0,1);
recover1 = 20;
egtMarg3(i1:end) = a2.*(fhs(i1:end)-sv1).^b2 + recover1;
[~,i2] = find(sv2-fhs < 0,1);
recover2 = 40;
egtMarg3(i2:end) = a2.*(fhs(i2:end)-sv2).^b2 + recover2;
[~,i3] = find(sv3-fhs < 0,1);
recover2 = 60;
egtMarg3(i3:end) = a2.*(fhs(i3:end)-sv3).^b2 + recover2;

a2 = .11;
b2 = 0.59;

egtMarg4 = a2.*fhs.^b2;

sv1 = 13000;
sv2 = 23000;
sv3 = 34000;

[~,i1] = find(sv1-fhs < 0,1);
recover1 = 20;
egtMarg4(i1:end) = a2.*(fhs(i1:end)-sv1).^b2 + recover1;
[~,i2] = find(sv2-fhs < 0,1);
recover2 = 40;
egtMarg4(i2:end) = a2.*(fhs(i2:end)-sv2).^b2 + recover2;
[~,i3] = find(sv3-fhs < 0,1);
recover2 = 60;
egtMarg4(i3:end) = a2.*(fhs(i3:end)-sv3).^b2 + recover2;


figure;
plot(fhs, egtMarg2)
xlabel("FEH")
ylabel("EGT Margin Decay")
hold on
plot(fhs, egtMarg3)
plot(fhs, egtMarg4)
yline(95, "-r")
legend("0%", "5%", "10%", "EGT Redline")
