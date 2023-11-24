clc
clear all
close all
% figure;
% hold on;
% before using this file to characterize your PA, please make sure you have
% biased your amplifier and turn the power supplies ON. To minimize the
% possibility of damaging your device, we only take measurements from the 
% DC power supplies. We do not turn the power supplies ON or OFF.
%%
% single-ended or doherty amplifier measurement
is_doherty = 1;

% frequency settings 
f_start =4e9;
f_stop = 4.1e9;
f_step = 0.1e9;

% desired characterization power range (in dBm) at the output of the driver
p_c_start = 40;
p_c_stop = 21;
p_c_step = -1; % coarse step

p_f_start = 20;
p_f_stop = 15;
p_f_step = -1; % fine step

% it is important to set the signal generator's maximum allowable input to
% avoid damaging the driver and PA during the automatic sweep
% ESG_Add = num2str(19);
% ESG_max_power = 0;
SG = SignalGenerator_E8267D(19,0);

% create the power meter
PM = PowerMeter_N1911A(15);

% create the driver 
DR = Driver('driver_data_2015-02-23-18-57');


% create the output coupler/attenuator
ATN=Attenuator('Attenuator_Coupler_4_8GHz_2.s2p');
% ATN=Attenuator('Attenuator_WilkAeroflex_33dB_Oct31.s2p');

% create the main power supply
% PS_m_Add = num2str(5); % GPIB address for the main power source
PS_m = PowerSupply_F3643A(6);
PS_m_chan = 1; % channel to measure from

% create the auxiliary power supply
if(is_doherty)
%     PS_a_Add = num2str(6); % GPIB address for the aux power source
    PS_a = PowerSupply_F3643A(5);
end

% connect to the instruments
SG.connect;
PM.connect;
PS_m.connect;
if(is_doherty)
    PS_a.connect;
end

% preset the signal generator and power meter 
SG.preset;
PM.preset;

f_points = 1+(f_stop-f_start)/f_step;
p_c_points = 1+(p_c_stop-p_c_start)/p_c_step;
p_f_points = 1+(p_f_stop-p_f_start)/p_f_step;

% pre-allocate memory for the data
data(1:f_points) = struct( 'frequency', 0, 'table', zeros(p_c_points+p_f_points,10));

for freq=f_start:f_step:f_stop
    f_idx = 1+(freq-f_start)/f_step;
    fprintf('Frequency is %g Hz (%d of %d)\n', freq, f_idx, f_points);
    SG.frequency(freq);
    PM.frequency(freq);
    PM.offset(ATN.attenuation(freq));
    fprintf('Attenuation at %g Hz is %g dB\n', freq, ATN.attenuation(freq));
    PM.offset(0);
    PM.zero_and_cal;
        
    data(f_idx).frequency = freq;   
    
    % coarse power sweep
    for p_in=p_c_start:p_c_step:p_c_stop
        p_idx = 1+(p_in-p_c_start)/p_c_step;                
        
        p_sg = DR.sg_power_for(freq, p_in);
        SG.power(p_sg);
        p_sg = SG.power; % read what the actual signal generator power is
        fprintf('SG power is %02.2f \n', p_sg);
        fprintf('p_in is %02.2f \n', p_in);
                
        SG.rf(1); % measurement start       
        V_m = PS_m.voltage;
        I_m = PS_m.current;
        if(is_doherty)
            V_a = PS_a.voltage;
            I_a = PS_a.current;
        end
        p_out = PM.measure;
        SG.rf(0); % measurement end
        
        fprintf('P_out is %2.4f \n', p_out);
        fprintf('I_m is %2.4f \n', I_m);
        
        if(is_doherty)
            fprintf('I_a is %2.4f \n', I_a);                        
        else
            V_a = 0;
            I_a = 0;
        end

        gain = p_out-p_in;
        fprintf('Gain is %2.4f \n', gain);
        p_out_w = 10^((p_out-30)/10); % p_out in Watts
        p_in_w = 10^((p_in-30)/10); % p_in in Watts
        p_dc = (V_m*I_m+V_a*I_a);
        DE = 100*p_out_w/p_dc;
        fprintf('DE is %3.2f\n', DE);
        fprintf('---------------\n');
        PAE = 100*(p_out_w - p_in_w)/p_dc;
        
        
        % create the data table
        data(f_idx).table(p_idx,1) = p_sg;     % signal generator power level
        data(f_idx).table(p_idx,2) = p_in;  % PA_in (a.k.a Driver_out)
        data(f_idx).table(p_idx,3) = p_out; % PA_out
        data(f_idx).table(p_idx,4) = gain;     % gain
        data(f_idx).table(p_idx,5) = V_m;      % main voltage
        data(f_idx).table(p_idx,6) = I_m;      % main current
        data(f_idx).table(p_idx,7) = V_a;      % auxiliary voltage
        data(f_idx).table(p_idx,8) = I_a;      % auxiliary current
        data(f_idx).table(p_idx,9) = PAE;      % PAE
        data(f_idx).table(p_idx,10) = DE;      % drain efficiency    
        %pause(2);
    end
    
    
    % fine power sweep
    for p_in=p_f_start:p_f_step:p_f_stop
        p_idx = 1+(p_in-p_f_start)/p_f_step + p_c_points; % index accounts for coarse data points
        
        p_sg = DR.sg_power_for(freq, p_in);
        SG.power(p_sg);
        p_sg = SG.power; % read what the actual signal generator power is
        fprintf('SG power is %02.2f \n', p_sg);
        fprintf('p_in is %02.2f \n', p_in);
                
        SG.rf(1); % measurement start       
        V_m = PS_m.voltage;
        I_m = PS_m.current;
        if(is_doherty)
            V_a = PS_a.voltage;
            I_a = PS_a.current;
        end
        p_out = PM.measure;
        SG.rf(0); % measurement end
        
        fprintf('p_out is %2.4f \n', p_out);
        fprintf('I_m is %2.4f \n', I_m);
        
        if(is_doherty)
            fprintf('I_a is %2.4f \n', I_a);                        
        else
            V_a = 0;
            I_a = 0;
        end

        gain = p_out-p_in;
        fprintf('Gain is %2.4f \n', gain);
        p_out_w = 10^((p_out-30)/10); % p_out in Watts
        p_in_w = 10^((p_in-30)/10); % p_in in Watts
        p_dc = (V_m*I_m+V_a*I_a);
        DE = 100*p_out_w/p_dc;
        fprintf('DE is %3.2f\n', DE); 
        fprintf('---------------\n');
        PAE = 100*(p_out_w - p_in_w)/p_dc;
        
        
        % create the data table
        data(f_idx).table(p_idx,1) = p_sg;     % signal generator power level
        data(f_idx).table(p_idx,2) = p_in;  % PA_in (a.k.a Driver_out)
        data(f_idx).table(p_idx,3) = p_out; % PA_out
        data(f_idx).table(p_idx,4) = gain;     % gain
        data(f_idx).table(p_idx,5) = V_m;      % main voltage
        data(f_idx).table(p_idx,6) = I_m;      % main current
        data(f_idx).table(p_idx,7) = V_a;      % auxiliary voltage
        data(f_idx).table(p_idx,8) = I_a;      % auxiliary current
        data(f_idx).table(p_idx,9) = PAE;      % PAE
        data(f_idx).table(p_idx,10) = DE;      % drain efficiency       
        %pause(2);
    end
end
i_m = data(f_idx).table(:,6);
pin = data(f_idx).table(:,2);
vin = 10.^((pin-30)/20);
figure; plot(data(f_idx).table(:,3),data(f_idx).table(:,10))
figure; plot(data(f_idx).table(:,3),data(f_idx).table(:,4))
figure; plot(vin,i_m)
% hold off;
data_file_name = [ 'PA_data_' datestr(now,'yyyy-mm-dd-HH-MM' )];
save(data_file_name, 'data');


% PS_m=PowerSupply_N6705A(2);
% PS_a=PowerSupply_N5770A(5);
% 
% PS_m=PowerSupply_F3643A(6);
% PS_a=PowerSupply_F3643A(5);
% 
% PS_m.connect;
% PS_a.connect;


