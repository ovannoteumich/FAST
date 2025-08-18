clear; clc; close all
% Digitized data from https://ntrs.nasa.gov/api/citations/19770012125/downloads/19770012125.pdf
% figure 6, kg not lb



Geared = [7.583442601069386, 2.612564088471534
21.0720538932029, 1.646836208317957
54.82243665742799, 0.9812582932248768];

Ungeared = [26.023256361737715, 1.063589896594772
60.0945722069989, 0.6442216342265801
98.47463549068411, 0.4808460855978578
18.37032733211373, 1.2952584345532059];

P_G = polyfit(Geared(:,1),Geared(:,2),2);

P_Ug = polyfit(Ungeared(:,1),Ungeared(:,2),2);


x = linspace(5,100)';
frac = polyval(P_G,x);
nonfrac = polyval(P_Ug,x);

plot(x,frac)
axis([0 100 0 3])
hold on
plot(x, nonfrac)