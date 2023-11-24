function [a_coef1 a_coef2 NMSE_error1 NMSE_error2 num_coef]=Identify_dual_band_2DMP(I1_inpa, Q1_inpa,I2_inpa, Q2_inpa, I2_outpa , Q2_outpa ,I3_outpa , Q3_outpa , Dualband_2DMP_Parameters , rec_srate, NbOfPoint,c1,c2,data_length ,model)

%external parameters
traning_data_length = NbOfPoint;%number of points used
m=Dualband_2DMP_Parameters.memory_step;%=1; 
d=Dualband_2DMP_Parameters.memory_depth;%=3 ; 
M=d-1;
NL=Dualband_2DMP_Parameters.NL;%=7 ; 


% bandwidth=Dualband_Volterra_Parameters.max_bandwidth_of_band; obselete


%internal parameters
jump=1;

task='DPD';
% task='Modeling';
Validation='same data';


%% PA or DPD construction : 
if strcmp(task, 'DPD')
    temp=I1_inpa; I1_inpa=I2_outpa; I2_outpa=temp;
    temp=Q1_inpa; Q1_inpa=Q2_outpa; Q2_outpa=temp;
    temp=I2_inpa; I2_inpa=I3_outpa; I3_outpa=temp;
    temp=Q2_inpa; Q2_inpa=Q3_outpa; Q3_outpa=temp;
end

%% same length of data

min_length=min(min(length(I1_inpa),length(I2_inpa)),min(length(I2_outpa),length(I3_outpa)));
I1_inpa=I1_inpa(1:min_length); Q1_inpa=Q1_inpa(1:min_length);
I2_inpa=I2_inpa(1:min_length); Q2_inpa=Q2_inpa(1:min_length); 
I2_outpa=I2_outpa(1:min_length); Q2_outpa=Q2_outpa(1:min_length);
I3_outpa=I3_outpa(1:min_length); Q3_outpa=Q3_outpa(1:min_length); 


%% Offset Removal
avg_in1=10*log10(mean((abs(I1_inpa+1i*Q1_inpa).^2))/100)+30;
avg_out1=10*log10(mean((abs(I2_outpa+1i*Q2_outpa).^2))/100)+30;
avg_in2=10*log10(mean((abs(I2_inpa+1i*Q2_inpa).^2))/100)+30;
avg_out2=10*log10(mean((abs(I3_outpa+1i*Q3_outpa).^2))/100)+30;

I1_inpa=I1_inpa*10^((0-avg_in1)/20);
Q1_inpa=Q1_inpa*10^((0-avg_in1)/20);
I2_outpa=I2_outpa*10^((0-avg_out1)/20);
Q2_outpa=Q2_outpa*10^((0-avg_out1)/20);

I2_inpa=I2_inpa*10^((0-avg_in2)/20);
Q2_inpa=Q2_inpa*10^((0-avg_in2)/20);
I3_outpa=I3_outpa*10^((0-avg_out2)/20);
Q3_outpa=Q3_outpa*10^((0-avg_out2)/20);

avg_in1=10*log10(mean((abs(I1_inpa+1i*Q1_inpa).^2))/100)+30;
peak_in1=10*log10(max((abs(I1_inpa+1i*Q1_inpa).^2))/100)+30
PAPR_in1=peak_in1-avg_in1

avg_out1=10*log10(mean((abs(I2_outpa+1i*Q2_outpa).^2))/100)+30;
peak_out1=10*log10(max((abs(I2_outpa+1i*Q2_outpa).^2))/100)+30
PAPR_out1=peak_out1-avg_out1

avg_in2=10*log10(mean((abs(I2_inpa+1i*Q2_inpa).^2))/100)+30;
peak_in2=10*log10(max((abs(I2_inpa+1i*Q2_inpa).^2))/100)+30
PAPR_in2=peak_in2-avg_in2

avg_out2=10*log10(mean((abs(I3_outpa+1i*Q3_outpa).^2))/100)+30;
peak_out2=10*log10(max((abs(I3_outpa+1i*Q3_outpa).^2))/100)+30
PAPR_out2=peak_out2-avg_out2

%% phase synchronisation
% % % % x_in1=I1_inpa+1i*Q1_inpa;
% % % % y_out2=I2_outpa+1i*Q2_outpa;
% % % % Phaseout2=angle(y_out2)-angle(x_in1);
% % % % Ind = Phaseout2 > pi;
% % % % Phaseout2 = Phaseout2 - 2*Ind*pi;
% % % % Ind = Phaseout2 < -pi;
% % % % Phaseout2 = Phaseout2 + 2*Ind*pi;
% % % % 
% % % % AvgPhaseout2 = mean(Phaseout2)
% % % % y_out2 = y_out2 * exp(-1i*AvgPhaseout2) ;
% % % % % err2 = y_out2 - x_in1 ;
% % % % I2_outpa=real(y_out2);
% % % % Q2_outpa=imag(y_out2);
% % % % 
% % % % 
% % % % x_in2=I2_inpa+1i*Q2_inpa;
% % % % y_out3=I3_outpa+1i*Q3_outpa;
% % % % Phaseout3=angle(y_out3)-angle(x_in2);
% % % % Ind = Phaseout3 > pi;
% % % % Phaseout3 = Phaseout3 - 2*Ind*pi;
% % % % Ind = Phaseout3 < -pi;
% % % % Phaseout3 = Phaseout3 + 2*Ind*pi;
% % % % 
% % % % AvgPhaseout3 = mean(Phaseout3)
% % % % y_out3 = y_out3 * exp(-1i*AvgPhaseout3) ;
% % % % % err3 = y_out2 - x_in2 ;
% % % % I3_outpa=real(y_out3);
% % % % Q3_outpa=imag(y_out3);



%% find max and choose data
Pindb = 10*log10(abs(I2_inpa+1i*Q2_inpa).^2/100+abs(I1_inpa+1i*Q1_inpa).^2/100)+30;
Max = max(Pindb)
aux = find(Pindb == Max )
Pindb1 = 10*log10(abs(I1_inpa+1i*Q1_inpa).^2/100)+30;
Max1 = max(Pindb1)
aux1 = find(Pindb1 == Max1 )
Pindb2 = 10*log10(abs(I2_inpa+1i*Q2_inpa).^2/100)+30;
Max2 = max(Pindb2)
aux2 = find(Pindb2 == Max2 )
% Traning_data = (aux2-500):(aux2+traning_data_length-500);
Traning_data = (aux-traning_data_length/2):(aux+traning_data_length/2);
% Traning_data = (aux1-traning_data_length/2):(aux1+traning_data_length/2);
% Traning_data = (aux-traning_data_length):min_length;
% Traning_data = (aux-1000):aux+traning_data_length;
% Traning_data = (aux2-traning_data_length/2):(aux2+traning_data_length/2);
% Traning_data=1:length(I1_inpa);

%% Model identification
% % Data format
% x_in1=(I1_inpa(Traning_data)+1i*Q1_inpa(Traning_data));
% x_in2=(I2_inpa(Traning_data)+1i*Q2_inpa(Traning_data));
% y_out1=(I2_outpa(Traning_data)+1i*Q2_outpa(Traning_data));
% y_out2=(I3_outpa(Traning_data)+1i*Q3_outpa(Traning_data));

x_in1=(I1_inpa(1:end)+1i*Q1_inpa(1:end));
x_in2=(I2_inpa(1:end)+1i*Q2_inpa(1:end));
y_out1=(I2_outpa(1:end)+1i*Q2_outpa(1:end));
y_out2=(I3_outpa(1:end)+1i*Q3_outpa(1:end));

N=length(x_in1);

if strcmp(model, '2DMP')

    A1=[];
    for i=0:M
        A_temp=[];
        x1_no_delay=x_in1(1+M*m:N);
        x2_no_delay=x_in2(1+M*m:N);
        x1=x_in1(1+M*m-i*m:N-i*m);
        x2=x_in2(1+M*m-i*m:N-i*m);
%         size(x1)
        for j=0:1:NL-1
            A_temp=[A_temp x1.*(abs(abs(x1)+c1*abs(x2)).^j)];
        end
        A1=[A1 A_temp];        
    end


    A2=[];
    for i=0:M
        A_temp=[];
        x1_no_delay=x_in2(1+M*m:N);
        x2_no_delay=x_in2(1+M*m:N);
        x1=x_in1(1+M*m-i*m:N-i*m);
        x2=x_in2(1+M*m-i*m:N-i*m);
        for j=0:1:NL-1    
            A_temp=[A_temp x2.*(abs(abs(x2)+c2*abs(x1)).^j)]; 
        end
        A2=[A2 A_temp];
    end
end

if strcmp(model, 'Static_volterra')

    x1=x_in1(1+M*m:N);
    x2=x_in2(1+M*m:N);

    order1=(1/2)*x1;
    order3=(1/2^3)*(3*x1.*(abs(x1).^2)+6*x1.*(abs(x2).^2));
    order5=(1/2^5)*(20*x1.*(abs(x1).^4)+120*x1.*(abs(x1).^2).*(abs(x2).^2)+60*x1.*(abs(x2).^4));
%     order7=1/2*((1/2^7)*(70*x1.*(abs(x1).^6)+840*x1.*(abs(x1).^4).*(abs(x2).^2)+1260*x1.*(abs(x1).^2).*(abs(x2).^4)+280*x1.*(abs(x2).^6)));
    A1=[order1 order3 order5 ];
    

    order1=(1/2)*x2;
    order3=(1/2^3)*(3*x2.*(abs(x2).^2)+6*x1.*(abs(x1).^2));
    order5=(1/2^5)*(20*x2.*(abs(x2).^4)+120*x2.*(abs(x2).^2).*(abs(x1).^2)+60*x2.*(abs(x1).^4));
%     order7=1/2*((1/2^7)*(70*x2.*(abs(x2).^6)+840*x2.*(abs(x2).^4).*(abs(x1).^2)+1260*x2.*(abs(x2).^2).*(abs(x1).^4)+280*x2.*(abs(x1).^6)));
    A2=[order1 order3 order5 ];
    
end

if strcmp(model, '2DDPD')
    A1=[];
    for i=0:M
        A_temp=[];
        x1=x_in1(1+M*m-i*m:N-i*m);
        x2=x_in2(1+M*m-i*m:N-i*m);
        for j=0:jump:NL-1
            for k=0:jump:j
                A_temp=[A_temp x1.*((abs(x1)).^(j-k)).*(abs(x2).^k)];
            end            
        end
        A1=[A1 A_temp];
%         size_A1 = size(A1)
    end

    A2=[];
    for i=0:M
        A_temp=[];
        x1=x_in1(1+M*m-i*m:N-i*m);
        x2=x_in2(1+M*m-i*m:N-i*m);
        for j=0:jump:NL-1
            for k=0:jump:j
                A_temp=[A_temp x2.*((abs(x2)).^(j-k)).*(abs(x1).^k)];
            end            
        end
        A2=[A2 A_temp];
    end
end



x_in1=x_in1(1+M*m:N);
y_out1=y_out1(1+M*m:N);
x_in2=x_in2(1+M*m:N);
y_out2=y_out2(1+M*m:N);


% a_coef = (pinv(A, eps) * [y_out1; y_out2]); % Solution of matrix equation-->model
size(A1)
size(y_out1)
a_coef1 = (pinv(A1, eps) * [y_out1]); 
a_coef2 = (pinv(A2, eps) * [y_out2]); 


a_coef1
length(a_coef1)
a_coef2
length(a_coef2)

num_coef=length(a_coef1)
%% Validation

% Data format
x_in1=(I1_inpa+1i*Q1_inpa);
x_in2=(I2_inpa+1i*Q2_inpa);
y_out1=(I2_outpa+1i*Q2_outpa);
y_out2=(I3_outpa+1i*Q3_outpa);
N=length(x_in1);


% % % A1=[];
% % % for i=1:M
% % %     A_temp=[];
% % %     x1=x_in1(1+M*m-i*m:N-i*m);
% % %     x2=x_in2(1+M*m-i*m:N-i*m);
% % %     for j=0:2:NL-1
% % %         A_temp=[A_temp x1.*(abs(abs(x1)+c1*abs(x2)).^j)];
% % %     end
% % %     A1=[A1 A_temp];
% % % end
% % % 
% % % A2=[];
% % % for i=1:M
% % %     A_temp=[];
% % %     x1=x_in1(1+M*m-i*m:N-i*m);
% % %     x2=x_in2(1+M*m-i*m:N-i*m);
% % %     for j=0:2:NL-1    
% % %         A_temp=[A_temp x2.*(abs(abs(x2)+c2*abs(x1)).^j)]; 
% % %     end
% % %     A2=[A2 A_temp];
% % % end

if strcmp(model, '2DMP')
    A1=[];
    for i=0:M
        A_temp=[];
        x1_no_delay=x_in1(1+M*m:N);
        x2_no_delay=x_in2(1+M*m:N);
        x1=x_in1(1+M*m-i*m:N-i*m);
        x2=x_in2(1+M*m-i*m:N-i*m);
        for j=0:1:NL-1
            A_temp=[A_temp x1.*(abs(abs(x1)+c1*abs(x2)).^j)];
        end
        A1=[A1 A_temp];
    end


    A2=[];
    for i=0:M
        A_temp=[];
        x1_no_delay=x_in1(1+M*m:N);
        x2_no_delay=x_in2(1+M*m:N);
        x1=x_in1(1+M*m-i*m:N-i*m);
        x2=x_in2(1+M*m-i*m:N-i*m);
        for j=0:1:NL-1    
            A_temp=[A_temp x2.*(abs(abs(x2)+c2*abs(x1)).^j)]; 
        end
        A2=[A2 A_temp];
    end
end

if strcmp(model, 'Static_volterra')

    x1=x_in1(1+M*m:N);
    x2=x_in2(1+M*m:N);

    order1=(1/2)*x1;
    order3=(1/2^3)*(3*x1.*(abs(x1).^2)+6*x1.*(abs(x2).^2));
    order5=(1/2^5)*(20*x1.*(abs(x1).^4)+120*x1.*(abs(x1).^2).*(abs(x2).^2)+60*x1.*(abs(x2).^4));
%     order7=1/2*((1/2^7)*(70*x1.*(abs(x1).^6)+840*x1.*(abs(x1).^4).*(abs(x2).^2)+1260*x1.*(abs(x1).^2).*(abs(x2).^4)+280*x1.*(abs(x2).^6)));
    A1=[order1 order3 order5];    

    order1=(1/2)*x2;
    order3=(1/2^3)*(3*x2.*(abs(x2).^2)+6*x1.*(abs(x1).^2));
    order5=(1/2^5)*(20*x2.*(abs(x2).^4)+120*x2.*(abs(x2).^2).*(abs(x1).^2)+60*x2.*(abs(x1).^4));
%     order7=1/2*((1/2^7)*(70*x2.*(abs(x2).^6)+840*x2.*(abs(x2).^4).*(abs(x1).^2)+1260*x2.*(abs(x2).^2).*(abs(x1).^4)+280*x2.*(abs(x1).^6)));
    A2=[order1 order3 order5];
    
end

if strcmp(model, '2DDPD')
    A1=[];
    for i=0:M
        A_temp=[];
        x1=x_in1(1+M*m-i*m:N-i*m);
        x2=x_in2(1+M*m-i*m:N-i*m);
        for j=0:jump:NL-1
            for k=0:jump:j
                A_temp=[A_temp x1.*((abs(x1)).^(j-k)).*(abs(x2).^k)];
            end            
        end
        A1=[A1 A_temp];
    end

    A2=[];
    for i=0:M
        A_temp=[];
        x1=x_in1(1+M*m-i*m:N-i*m);
        x2=x_in2(1+M*m-i*m:N-i*m);
        for j=0:jump:NL-1
            for k=0:jump:j
                A_temp=[A_temp x2.*((abs(x2)).^(j-k)).*(abs(x1).^k)];
            end            
        end
        A2=[A2 A_temp];
    end
end


y_model1=(A1 * a_coef1);
y_model2=(A2 * a_coef2);




%% Validation



V1_in    = x_in1((1+M*m):end)     ;
V2_in    = x_in2((1+M*m):end)   ;
V2_out   = y_out1((1+M*m):end)   ;
V3_out   = y_out2((1+M*m):end)    ;
V2_outNN = y_model1;
V3_outNN = y_model2;
r1_in    = abs(V1_in)   ; t1_in    = angle(V1_in)   ;
r2_in    = abs(V2_in)   ; t2_in    = angle(V2_in)   ;
r2_out   = abs(V2_out)  ; t2_out   = angle(V2_out)  ;
r3_out   = abs(V3_out)  ; t3_out   = angle(V3_out)  ;
r2_outNN = abs(V2_outNN); t2_outNN = angle(V2_outNN);
r3_outNN = abs(V3_outNN); t3_outNN = angle(V3_outNN);

figure(12)
    hold on
        Fs    = 3.87e6      ;
        h    = spectrum.welch            ;
        h.OverlapPercent = 90            ;
        h.SegmentLength  = 2048         ;
        h.windowName  = 'Flat Top'       ;
        PSDMeasurement = plot(msspectrum(h,V2_out ,'centerdc',Fs))            ;

        PSDModel = plot(msspectrum(h,V2_outNN,'centerdc',Fs))                   ;
                   set(PSDModel,'Color','red');
        legend('PSD Measurement','PSD Model',2);

	hold off

figure(13)
    hold on
        Fs    = 3.87e6      ;
        h    = spectrum.welch            ;
        h.OverlapPercent = 90            ;
        h.SegmentLength  = 2048          ;
        h.windowName  = 'Flat Top'       ;
        PSDMeasurement = plot(msspectrum(h,V3_out ,'centerdc',Fs))            ;

        PSDModel = plot(msspectrum(h,V3_outNN,'centerdc',Fs))                   ;
                   set(PSDModel,'Color','red');
        legend('PSD Measurement','PSD Model','PSD error',2);

	hold off
    

%% NMSE

NMSE_error1 = 10*log10(mean(((abs(V2_out-V2_outNN).^2)/mean(abs(V2_out)).^2))); 
NMSE_error2 = 10*log10(mean(((abs(V3_out-V3_outNN).^2)/mean(abs(V3_out)).^2)));
display(['*******************************']);
display(['NMSE_error1  ',num2str(NMSE_error1)]);
display(['NMSE_error2  ',num2str(NMSE_error2)]); 
display(['*******************************']);

NMSE_abs1 = 10*log10(mean(((abs(V2_out)-abs(V2_outNN)).^2/mean(abs(V2_out)).^2))) 
NMSE_abs2 = 10*log10(mean(((abs(V3_out)-abs(V3_outNN)).^2/mean(abs(V3_out)).^2))) 

NMSE_pha1 = 10*log10(mean(((angle(V2_out)-angle(V2_outNN)).^2/mean(angle(V2_out).^2)))) 
NMSE_pha2 = 10*log10(mean(((angle(V3_out)-angle(V3_outNN)).^2/mean(angle(V3_out).^2))))        


NMSE1_I_and_Q1 = 0.5*(                                                           ...
                     10*log10(mean(((real(V2_out)-real(V2_outNN)).^2/mean(real(V2_out).^2)))) + ...
                     10*log10(mean(((imag(V2_out)-imag(V2_outNN)).^2/mean(imag(V2_out).^2))))   ...
                    )
NMSE2_I_and_Q2 = 0.5*(                                                           ...
                     10*log10(mean(((real(V3_out)-real(V3_outNN)).^2/mean(real(V3_out).^2)))) + ...
                     10*log10(mean(((imag(V3_out)-imag(V3_outNN)).^2/mean(imag(V3_out).^2))))   ...
                    )
                
                
%% AM/AM
figure(22)
   title('AM/AM Distortion');
    hold on
        plot(10*log10(r1_in.^2/100)+30,10*log10(r2_out.^2./r1_in.^2),'.' )  ;
        plot(10*log10(r1_in.^2/100)+30,10*log10(r2_outNN.^2./r1_in.^2),'ro');
        plot(10*log10(r1_in.^2/100)+30,10*log10(r1_in.^2./r1_in.^2) ,'g' )  ;
        legend('AM/AM Measurement','AM/AM Model',2)                   ;
    hold off
figure(23)
   title('AM/AM Distortion');
    hold on
        plot(10*log10(r2_in.^2/100)+30,10*log10(r3_out.^2./r2_in.^2),'.' )  ;
        plot(10*log10(r2_in.^2/100)+30,10*log10(r3_outNN.^2./r2_in.^2),'ro');
        plot(10*log10(r2_in.^2/100)+30,10*log10(r2_in.^2./r2_in.^2) ,'g' )  ;
        legend('AM/AM Measurement','AM/AM Model',2)                   ;
    hold off
    
    
    
    
%% AM/PM
figure(32)
    title('AM/PM Distortion');
    do  = t2_out-t1_in;
    dNN = t2_outNN-t1_in;
    for i=1:length(do)
        if do(i) > pi
            do(i) = do(i) - 2*pi;
        elseif do(i) < -pi
            do(i) = do(i) + 2*pi;
        end
        if dNN(i) > pi
            dNN(i) = dNN(i) - 2*pi;
        elseif dNN(i) < -pi
            dNN(i) = dNN(i) + 2*pi;
        end
    end
    hold on
        plot(10*log10(r1_in.^2/100)+30 ,do*180/pi  ,'.');
        plot(10*log10(r1_in.^2/100)+30 ,dNN*180/pi,'ro');
        legend('AM/PM Measurement','AM/PM Model',2)   ;        
    hold off
    
    figure(33)
    title('AM/PM Distortion');
    do  = t3_out-t2_in;
    dNN = t3_outNN-t2_in;
    for i=1:length(do)
        if do(i) > pi
            do(i) = do(i) - 2*pi;
        elseif do(i) < -pi
            do(i) = do(i) + 2*pi;
        end
        if dNN(i) > pi
            dNN(i) = dNN(i) - 2*pi;
        elseif dNN(i) < -pi
            dNN(i) = dNN(i) + 2*pi;
        end
    end
    hold on
        plot(10*log10(r2_in.^2/100)+30 ,do*180/pi  ,'.');
        plot(10*log10(r2_in.^2/100)+30 ,dNN*180/pi,'ro');
        legend('AM/PM Measurement','AM/PM Model',2)   ;        
    hold off



                  