function check_for_zeros(input, real_zeros, imag_zeros)
    %plot max range of input as a circle on real-imag plane
    max_input = max(abs(input));
    ang=0:0.01:2*pi; 
    xp=max_input*cos(ang);
    yp=max_input*sin(ang);

    real_zeros(real_zeros == 0) = [];
    imag_zeros(imag_zeros == 0) = [];
    
    figure()
    hold on;
%     plot(xp,yp,'r.-');
    axis square;
    scatter(real(input),imag(input),'b.');
    
    for ind = 1:length(real_zeros)
        real_zeroxp = real_zeros(ind)*cos(ang);
        real_zeroyp = real_zeros(ind)*sin(ang);
        plot(real_zeroxp, real_zeroyp,'k');
    end
    
    for ind = 1:length(imag_zeros)
        imag_zeroxp = imag_zeros(ind)*cos(ang);
        imag_zeroyp = imag_zeros(ind)*sin(ang);
        plot(imag_zeroxp, imag_zeroyp,'m');
    end
    
    hold off
end