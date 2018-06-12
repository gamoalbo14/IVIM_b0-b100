function [c] = difffitmonoexp(x,dataADC)

global SIfit


%dataADC(1,:) = SI
%dataADC(2,:) = b

%x(1) = constante inicial
%x(2) = ADC


SIfit = x(1) * exp( -dataADC(2,:).*x(2)  ) ;

c = (SIfit - dataADC(1,:)).^2;

