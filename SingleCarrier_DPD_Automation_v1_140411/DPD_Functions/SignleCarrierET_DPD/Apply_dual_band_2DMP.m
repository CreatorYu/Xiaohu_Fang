function [InI_pred1, InQ_pred1 ,InI_pred2, InQ_pred2]=Apply_dual_band_2DMP(InI1, InQ1,InI2, InQ2, a_coef1, a_coef2, Dualband_2DMP_Parameters , src_srate,c1,c2,data_length,model)


%external parameters
m=Dualband_2DMP_Parameters.memory_step;%=1; 
d=Dualband_2DMP_Parameters.memory_depth;%=3 ; 
M=d-1;
NL=Dualband_2DMP_Parameters.NL;%=7 ; 

%internal_coeff
power_backoff=0;%-0.35


%% Data pretreatment
% InI1  = InI1(:,1)'      ; InQ1  = InQ1(:,1)'        ;
% InI2  = InI2(:,1)'      ; InQ2  = InQ2(:,1)'        ;
% L = min( min(length(I1_inpa),length(I2_outpa)),min(length(I2_inpa),length(I3_outpa)) ); 
% InI1  = InI1(1:L) ; InQ1  = InQ1(1:L) ;
% InI2  = InI2(1:L) ; InQ2  = InQ2(1:L) ;

%%%%%%%%%%Offset removal

avg_in1=10*log10(mean((abs(InI1+1i*InQ1).^2))/100)+30;
InI1=InI1*10^((power_backoff-avg_in1)/20);
InQ1=InQ1*10^((power_backoff-avg_in1)/20);
avg_in1=10*log10(mean((abs(InI1+1i*InQ1).^2))/100)+30
peak_in1=10*log10(max((abs(InI1+1i*InQ1).^2))/100)+30
PAPR1=peak_in1-avg_in1

avg_in2=10*log10(mean((abs(InI2+1i*InQ2).^2))/100)+30;
InI2=InI2*10^((power_backoff-avg_in2)/20);
InQ2=InQ2*10^((power_backoff-avg_in2)/20);
avg_in2=10*log10(mean((abs(InI2+1i*InQ2).^2))/100)+30
peak_in2=10*log10(max((abs(InI2+1i*InQ2).^2))/100)+30
PAPR2=peak_in2-avg_in2

%% generate predistorted signal
x_in1=InI1+1i*InQ1;
x_in2=InI2+1i*InQ2;

a=x_in1;
b=x_in2;
N=length(x_in1);


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
%     order3=(1/2^3)*(3*x1.*(abs(x1).^2)+6*x1.*(abs(x2).^2));
%     order5_0=(1/2^5)*(20*x1.*(abs(x1).^4)+120*x1.*(abs(x1).^2).*(abs(x2).^2)+60*x1.*(abs(x2).^4));
%     order7=1/2*((1/2^7)*(70*x1.*(abs(x1).^6)+840*x1.*(abs(x1).^4).*(abs(x2).^2)+1260*x1.*(abs(x1).^2).*(abs(x2).^4)+280*x1.*(abs(x2).^6)));
%     A1=[order1 order3 order5 order7];
    order3_0=(1/2^3)*(3*x1.*(abs(x1).^2));
    order3_2=(1/2^3)*(6*x1.*(abs(x2).^2));
    order5_0=(1/2^5)*(20*x1.*(abs(x1).^4));
    order5_2=(1/2^5)*(120*x1.*(abs(x1).^2).*(abs(x2).^2));
    order5_4=(1/2^5)*(60*x1.*(abs(x2).^4));
    A1=[order1 order3_0 order3_2 order5_0 order5_2 order5_4];
    

    order1=(1/2)*x2;
%     order3=(1/2^3)*(3*x2.*(abs(x2).^2)+6*x1.*(abs(x1).^2));
%     order5=(1/2^5)*(20*x2.*(abs(x2).^4)+120*x2.*(abs(x2).^2).*(abs(x1).^2)+60*x2.*(abs(x1).^4));
%     order7=1/2*((1/2^7)*(70*x2.*(abs(x2).^6)+840*x2.*(abs(x2).^4).*(abs(x1).^2)+1260*x2.*(abs(x2).^2).*(abs(x1).^4)+280*x2.*(abs(x1).^6)));
%     A2=[order1 order3 order5 order7];
    order3_0=(1/2^3)*(3*x2.*(abs(x2).^2));
    order3_2=(1/2^3)*(6*x2.*(abs(x1).^2));
    order5_0=(1/2^5)*(20*x2.*(abs(x2).^4));
    order5_2=(1/2^5)*(120*x2.*(abs(x2).^2).*(abs(x1).^2));
    order5_4=(1/2^5)*(60*x2.*(abs(x1).^4));
    A2=[order1 order3_0 order3_2 order5_0 order5_2 order5_4];
    
end

if strcmp(model, '2DDPD')
    A1=[];
    for count1=0:M
        A_temp=[];
        x1=x_in1(1+M*m-count1*m:N-count1*m);
        x2=x_in2(1+M*m-count1*m:N-count1*m);
%         size(x1)
%         size(x2)        
        for count2=0:1:NL-1
            for k=0:count2
                A_temp=[A_temp x1.*((abs(x1)).^(count2-k)).*(abs(x2).^k)];
%                 size(A_temp)
            end            
        end
        A1=[A1 A_temp];
%         size(A1)
    end

    A2=[];
    for count1=0:M
        A_temp=[];
        x1=x_in1(1+M*m-count1*m:N-count1*m);
        x2=x_in2(1+M*m-count1*m:N-count1*m);
        for count2=0:1:NL-1
            for k=0:count2
                A_temp=[A_temp x2.*((abs(x2)).^(count2-k)).*(abs(x1).^k)];
            end            
        end
        A2=[A2 A_temp];
    end
end

% size(A1)
% size(A2)

% y_predistorted_1_2 = (A * a_coef);
% file_length=length(x_in1)-(M-1)*m;
% y_predistorted1=y_predistorted_1_2(1:file_length,1);
% y_predistorted2=y_predistorted_1_2(file_length+1:2*file_length,1);

y_predistorted1=(A1 * a_coef1);
y_predistorted2=(A2 * a_coef2);





InI_pred1=real(y_predistorted1);
InQ_pred1=imag(y_predistorted1);
InI_pred2=real(y_predistorted2);
InQ_pred2=imag(y_predistorted2);

% min_size=length(InI_pred1);
% InI_pred1 = [InI_pred1; zeros(data_length-min_size,1)];
% InQ_pred1 = [InQ_pred1; zeros(data_length-min_size,1)];
% InI_pred2 = [InI_pred2; zeros(data_length-min_size,1)];
% InQ_pred2 = [InQ_pred2; zeros(data_length-min_size,1)];
% display(['length of pred. signal',num2str(length(InI_pred1))]);

%% wirte signals to files

% fidIEH = fopen('I1_afterDPD.txt','wt');
% fprintf(fidIEH,'%12.20f\n',real(y_predistorted1));
% fclose(fidIEH);
% fidIEH = fopen('Q1_afterDPD.txt','wt');
% fprintf(fidIEH,'%12.20f\n',imag(y_predistorted1));
% fclose(fidIEH);
% fidIEH = fopen('I2_afterDPD.txt','wt');
% fprintf(fidIEH,'%12.20f\n',real(y_predistorted2));
% fclose(fidIEH);
% fidIEH = fopen('Q2_afterDPD.txt','wt');
% fprintf(fidIEH,'%12.20f\n',imag(y_predistorted2));
% fclose(fidIEH);


    
