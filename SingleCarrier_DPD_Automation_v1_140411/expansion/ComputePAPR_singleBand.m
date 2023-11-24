function PAPR1_original = ComputePAPR_singleBand(In_I,In_Q)

    avg_in1=10*log10(mean((abs(In_I+1i*In_Q).^2))/100)+30;
    peak_in1=10*log10(max((abs(In_I+1i*In_Q).^2))/100)+30;
    PAPR1_original=peak_in1-avg_in1;
    
end