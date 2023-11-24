function mark_zeroes(figure, real_zeros, imag_zeros)

    % power level for zeros
    pwr_rz = 10*log10(((real_zeros).^2)./100)+30;
    pwr_iz = 10*log10(((imag_zeros).^2)./100)+30;
    hold on
    
        for ind=1:length(pwr_rz)
            rp = pwr_rz(ind);
            line([rp rp],get(figure,'YLim'),'Color',[0 0 0],'LineStyle','-.');
        end

        for ind=1:length(pwr_iz)
            ip = pwr_iz(ind);
            line([ip ip],get(figure,'YLim'),'Color',[1 0 1],'LineStyle','-.');
        end

    hold off
    
end