function check_for_zeros(input, comp_zeros)
    %plot max range of input as a circle on real-imag plane
    max_input = max(abs(input));
    ang=0:0.01:2*pi; 
    xp=max_input*cos(ang);
    yp=max_input*sin(ang);

    figure();
    hold on;
%     plot(xp,yp);
    axis square;
    scatter(real(input),imag(input),'b.');
    
    for ind = 1:length(comp_zeros)
        real_zeroxp = real(comp_zeros(ind));
        imag_zeroyp = imag(comp_zeros(ind));
        plot(real_zeroxp, imag_zeroyp,'ko', 'MarkerFaceColor', 'r');
    end
    
    hold off
end