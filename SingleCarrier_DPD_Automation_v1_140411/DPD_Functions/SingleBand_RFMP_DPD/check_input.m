function check_input(input, den_zeros)
    %plot max range of input as a circle on real-imag plane
    max_input = max(abs(input));
    ang=0:0.01:2*pi; 
    xp=max_input*cos(ang);
    yp=max_input*sin(ang);

    figure();
    hold on;
    plot(xp,yp);
    scatter(real(den_zeros),imag(den_zeros),'r');
    hold off
end