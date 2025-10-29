function [Aircraft] = EGTDecay(Aircraft)

% function that determines EGT decay coefficient values based on hotsection
% derating

n = 200;

fec = linspace(0,30000, n);


a = 0.104;
b = 0.659;

egtMarg = a.*fec.^b;

figure;
plot(fec, egtMarg)
xlabel("FEC")
ylabel("EGT Margin del Temp")
end