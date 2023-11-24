function phase_driver_array=fun_phase_array_SBP(fre,p_min,p_max)

f_start =24e9;
f_stop =30e9;
f_step =0.5e9;
fre_idx=1+(fre-f_start)/f_step;
% desired characterization power range (in dBm) at the output of the PA
%p_min = -36;
%p_max = -9;
p_step = 1;
f_points = 1+(f_stop-f_start)/f_step;
p_points = 1+(p_max-p_min)/p_step;
phase_driver_array=zeros(p_points,f_points);
for freq=f_start:f_step:f_stop
    f_idx = 1+(freq-f_start)/f_step;
    for pin=p_min:p_step:p_max
        p_idx=1+(pin-p_min)/p_step;
    phase_driver_array(p_idx,f_idx) = fun_Driver_SBP_in2phase(pin,freq);
    end
end
phase_driver_array=phase_driver_array(:,fre_idx);
end