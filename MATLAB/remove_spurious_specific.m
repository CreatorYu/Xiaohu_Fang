function [ x_temp ] = remove_spurious_specific( x, fs,F  )
%REMOVE_FS removes the spurs that appear at the edge of the spectrum
    
    [meanPower, ~, ~] = checkPower(real(x), imag(x), 0);
    time_IQ = (0:(length(x)-1))./fs;
    
    n = length(F);
    x_temp = x; 
    for i = 1 : n
        x_temp = x_temp .* exp(1i*2*pi*-F(i)*time_IQ).';
        x_temp = x_temp - mean(x_temp);
        x_temp = x_temp .* exp(1i*2*pi*+F(i)*time_IQ).';
    end
%     PlotSpectrum(real(x), imag(x), real(x_temp), imag(x_temp), fs)
    [x_temp_I, x_temp_Q] = setMeanPower(real(x_temp), imag(x_temp), meanPower);
    x_temp = complex(x_temp_I, x_temp_Q);


end

