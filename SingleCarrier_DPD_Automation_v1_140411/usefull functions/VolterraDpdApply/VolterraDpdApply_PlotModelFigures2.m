function VolterraDpdApply_PlotModelFigures2(Vin,Volterra)
    Volterra = VolterraDpdApply_Create_Data(real(Vin),imag(Vin),real(Volterra),imag(Volterra));

%% I & Q
%     display('I Waveform plot');
%     figure()
%         title('I Component','fontSize',20);
%         xlabel('time','FontSize',15);
%         ylabel('Voltage','FontSize',15);
%         hold on
%             plot(Volterra.Out_I(1:1000),'.');
%             plot(Volterra.Out_Q(1:1000),'ro');
%             legend('Predistorted I','Predistorted Q',2);
%         hold off
% 
%% AM/AM
    display('AM/AM plot');
    figure()
        title('AM/AM Distortion','FontSize',20);
        xlabel('Pin (dBm)','FontSize',15);
        ylabel('Pout./Pin (dB)','FontSize',15);
        hold on
            plot(Volterra.Pin,Volterra.Pout-Volterra.Pin,'ro' );
            legend('Predistorted AMAM',2);
        hold off  
% %% AM/PM
%     display('AM/PM plot');
%     figure()
%         hold on
%             title('AM/PM Distortion','FontSize',20);
%             xlabel('Pin (dBm)','FontSize',15);
%             ylabel('Phase distortion (degree)','FontSize',15);
%         
%             angle_distortion = Volterra.Phout - Volterra.Phin;
%             aux = angle_distortion > pi;
%                 angle_distortion = angle_distortion - 2*aux*pi;
%             aux = angle_distortion < -pi;
%                 angle_distortion = angle_distortion + 2*aux*pi;
%             plot(Volterra.Pin,angle_distortion*180/pi,'ro') ;
% 
%             legend('Predistorted AMPM',2);
%         hold off
% 
% %% PSD
%     display('PSD plot');
%     figure()
%         Fs = 3.84*10^6;
%         h                = spectrum.welch;
%         h.OverlapPercent = 40            ;
%         h.SegmentLength  = 2048          ;
%         h.windowName     = 'Flat Top'    ;
%         hold on
%             msspectrum(h,Volterra.Vin,'centerdc',Fs)           ;
%             H = plot(msspectrum(h,Volterra.Vout,'centerdc',Fs));
%                 set(H,'Color','RED');
%             legend('Input PSD','Predistorted PSD',2);
%         hold off