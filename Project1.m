clc
clear all
close all

% load the data
startdate = '01/01/1994';
enddate = '01/01/2022';
f = fred
KOR = fetch(f,'NGDPRSAXDCKRQ',startdate,enddate)
JPY = fetch(f,'JPNRGDPEXP',startdate,enddate)
kor = log(KOR.Data(:,2));
jpy = log(JPY.Data(:,2));
q = KOR.Data(:,1);

T = size(kor,1);

% Hodrick-Prescott filter
lam = 1600;
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

tauKRGDP = A\kor;
tauJPGDP = A\jpy;

% detrended GDP
kortilde = kor-tauKRGDP;
jpytilde = jpy-tauJPGDP;

% plot detrended GDP
dates = 1994:1/4:2022.1/4; zerovec = zeros(size(kor));
figure
title('Detrended log(real GDP) 1994Q1-2022Q1'); hold on
plot(q, kortilde,'b')
plot(q, jpytilde,'r')
datetick('x', 'yyyy-qq')

% compute sd(kor), sd(jpy), rho(kor), rho(jpy), corr(kor,jpy) (from detrended series)
korsd = std(kortilde)*100;
korrho = corrcoef(kortilde(2:T),kortilde(1:T-1)); korrho = korrho(1,2);
corryc = corrcoef(kortilde(1:T),jpytilde(1:T)); corryc = corryc(1,2);

disp(['Percent standard deviation of detrended log real GDP: ', num2str(korsd),'.']); disp(' ')
disp(['Serial correlation of detrended log real GDP: ', num2str(korrho),'.']); disp(' ')
disp(['Contemporaneous correlation between detrended log real GDP and PCE: ', num2str(corryc),'.']);
