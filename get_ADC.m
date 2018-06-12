function [ ADC ] = get_ADC( bval )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

for i=1:1:size(bval,1)
    ADC(i,:)=abs(log(bval(i,1)/bval(i,end))/1000);
    
end

