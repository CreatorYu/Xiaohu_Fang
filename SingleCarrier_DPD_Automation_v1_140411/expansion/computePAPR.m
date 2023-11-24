function PAPR = computePAPR(I,Q)

    avg=10*log10(mean((abs(I+1i*Q).^2))/100)+30;
    peak=10*log10(max((abs(I+1i*Q).^2))/100)+30;
    PAPR=peak-avg;
    
end