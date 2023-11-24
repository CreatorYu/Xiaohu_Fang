% in step2, the testing are conducted including the driver
clc
clear
clear all;

% frequency settings 
f_start =4.8e9;
f_stop =5.3e9;
f_step =0.1e9;

% desired characterization power range (in dBm) at the output of the driver
p_min = -35;
p_max = -30;
p_step = 1;
p_epsilon = 0.1; % error tolerance

% the driver's approximate gain
gain_est = -1;

% it is important to set the signal generator's maximum allowable input to
% avoid damaging the driver during the automatic sweep
%
SG=SignalGenerator_E8267D(19,-15);
% create the power meter
PM=PowerMeter_N1911A(15);
% create the attenuator
ATN=Attenuator('Attenuator_Coupler_4_8GHz_2.s2p');
% ATN=Attenuator('Attenuator_WilkAeroflex_33dB_Oct31.s2p');

% connect to the instruments
SG.connect;
PM.connect;

% preset the instruments
% SG.preset;
PM.preset;

f_points = 1+(f_stop-f_start)/f_step;
p_points = 1+(p_max-p_min)/p_step;

% pre-allocate memory for the data
data(1:f_points) = struct( 'frequency', 0, 'ssg', 0, 'p_max', p_max, 'p_min', p_min, 'p_step', p_step, 'table', zeros(p_points,4));

for freq=f_start:f_step:f_stop
    f_idx = 1+(freq-f_start)/f_step;
    fprintf('Frequency is %g Hz (%d of %d)\n', freq, f_idx, f_points);
    SG.frequency(freq);
    PM.frequency(freq);
    PM.offset(ATN.attenuation(freq));
    fprintf('Attenuation at %g Hz is %g dB\n', freq, ATN.attenuation(freq));
    %PM.offset(0);
   %  PM.zero_and_cal;
    
    
    data(f_idx).frequency = freq;
    %   gain = gain_est; % set initial gain to the driver gain estimate
    %SG.power(0);
    %SG.rf(1);
    for p_target=p_min:p_step:p_max
        p_idx = 1+(p_target-p_min)/p_step;
        p_sg=p_target;
        SG.power(p_sg);
        p_in = SG.power; % read what the actual input power is 
        fprintf('SG power is %02.2f ', p_in);
        SG.rf(1);
        pause(0.5)
        p_out = PM.measure;
        SG.rf(0);
        fprintf('p_out is %2.4f\n ',p_out);
        gain = p_out-p_in;
%         
        % create the data table
        data(f_idx).table(p_idx,1) = p_in;
        data(f_idx).table(p_idx,2) = p_out;
        data(f_idx).table(p_idx,3) = p_target;
        data(f_idx).table(p_idx,4) = gain; 
    end
        % determine the small signal gain from first 10 gain values
     data(f_idx).ssg = mean(data(f_idx).table(1:2,4));     
end
data_file_name = [ 'driver_data_step1_' datestr(now,'yyyy-mm-dd-HH-MM' )];
save(data_file_name, 'data');        
%     for p_target=p_min:p_step:p_max
%         p_idx = 1+(p_target-p_min)/p_step;
%         err = 1000;
%         p_sg = p_target-gain;
%         
%         max_tries = 15;
%         tries = 0;
%         while (abs(err) > p_epsilon)
%             SG.power(p_sg);
%             p_in = SG.power; % read what the actual input power is 
%             fprintf('SG power is %02.2f ', p_in);
%             SG.rf(1);
%             p_out = PM.measure;
%             SG.rf(0);
%             fprintf('p_out is %2.4f ',p_out);
%             err = p_out-p_target;
%             fprintf('error is %+1.6f\n',err);
%             
%             if(tries > 5)
%                 fprintf('NOTICE: see-sawing detected! slow converage system activated!\n');
%                 p_sg = p_in-err/2; % to counter see-sawing effect
%             else
%                 p_sg = p_in-err;            
%             end
%             
%             tries = tries+1;
%             if(tries > max_tries)
%                 error('maximum attempts exceeded while trying to obtain power level = %g dBm at frequency %g.\nDriver may be unstable', p_target, freq);
%             end
%         end
%         gain = p_out-p_in;
%         
%         % create the data table
%         data(f_idx).table(p_idx,1) = p_in;
%         data(f_idx).table(p_idx,2) = p_out;
%         data(f_idx).table(p_idx,3) = p_target;
%         data(f_idx).table(p_idx,4) = gain;                          
%     end
%     % determine the small signal gain from first 10 gain values
%     data(f_idx).ssg = mean(data(f_idx).table(1:10,4));
% end
% 
% data_file_name = [ 'driver_data_' datestr(now,'yyyy-mm-dd-HH-MM' )];
% save(data_file_name, 'data');