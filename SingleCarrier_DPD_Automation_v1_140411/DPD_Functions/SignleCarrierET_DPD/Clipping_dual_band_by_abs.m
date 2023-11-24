function [InI1_clipped InQ1_clipped InI2_clipped InQ2_clipped peaks_index_ratio nb_iteration_clipping]=Clipping_dual_band_by_abs(InI1, InQ1, InI2, InQ2, Desired_PAPR)

x1=InI1+1i*InQ1;
x2=InI2+1i*InQ2;


%% calculate original PAPR
avg_in_1=10*log10(mean((abs(x1).^2))/100)+30;
peak_in_1=10*log10(max((abs(x1).^2))/100)+30;
PAPR_in_1=peak_in_1-avg_in_1;

avg_in_2=10*log10(mean((abs(x2).^2))/100)+30;
peak_in_2=10*log10(max((abs(x2).^2))/100)+30;
PAPR_in_2=peak_in_2-avg_in_2;


%% low sampling rate dual band Clipping

InI1_clipped=InI1;InQ1_clipped=InQ1;InI2_clipped=InI2;InQ2_clipped=InQ2; % initialization
New_peak=avg_in_1+avg_in_2+Desired_PAPR;
peak=10^((New_peak-30)/10);
iteration=[0 0];
peaks_index_ratio=0;
for n=1:length(InI1)
    r=(abs(x1(n)).^2)/100+(abs(x2(n)).^2)/100;
    if r > peak
       ratio=(r)/peak;
       iteration=iteration+1;
       peaks_index_ratio(iteration,:)=[ n ratio ];
       InI1_clipped(n)=InI1(n)/sqrt(ratio);
       InQ1_clipped(n)=InQ1(n)/sqrt(ratio);
       InI2_clipped(n)=InI2(n)/sqrt(ratio);
       InQ2_clipped(n)=InQ2(n)/sqrt(ratio);
    end
end
nb_iteration_clipping=length(peaks_index_ratio(:,1));

% figure(); hold on; 
% plot (1:nb_iteration_clipping, (abs(x_bbcombined(peaks_index_ratio(:,1))).^2)/100, 'b');
% plot (1:nb_iteration_clipping, (abs(x_clipped_bbcombined(peaks_index_ratio(:,1))).^2)/100, 'g');
% plot(1:nb_iteration_clipping,peak, 'r' );
% title('clipped peaks');

%% Calculate new PAPR
avg_in_1clipped=10*log10(mean((abs(InI1_clipped+1i*InQ1_clipped).^2))/100)+30;
peak_in_1clipped=10*log10(max((abs(InI1_clipped+1i*InQ1_clipped).^2))/100)+30;
PAPR_in_1clipped=peak_in_1clipped-avg_in_1clipped;

avg_in_2clipped=10*log10(mean((abs(InI2_clipped+1i*InQ2_clipped).^2))/100)+30;
peak_in_2clipped=10*log10(max((abs(InI2_clipped+1i*InQ2_clipped).^2))/100)+30;
PAPR_in_2clipped=peak_in_2clipped-avg_in_2clipped;




end
