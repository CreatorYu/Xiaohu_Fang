classdef Driver < handle
% takes a driver data file generated from characterized_driver.m
    properties (SetAccess = private)
        data
    end
    methods
        % constructor
        function obj = Driver(data_file)
            S = load(data_file);
            obj.data = S.data;
        end
        
        % get frequencies available
        function output = freq(obj)
            output = [obj.data.frequency]';
        end
        
        % get driver info at frequency
        function output = info(obj, freq)
            f_idx = [obj.data.frequency] == freq;
            if any(f_idx)
                output = obj.data(f_idx);
            else
                error('Frequency %g Hz not calibrated', freq);
            end            
        end     
        
        % get signal generator power for the desired driver output power
        function output = sg_power_for(obj, freq, power)            
            f_idx = [obj.data.frequency] == freq;
            if any(f_idx)
                % for power request below p_min, use small signal gain
                if(power < obj.data(f_idx).p_min) 
                    output = power - obj.data(f_idx).ssg;
                elseif (power > obj.data(f_idx).p_max)
                    error('Requested power %g dBm at frequency %g Hz exceeds maximum calibrated power of %g dBm', power, freq, obj.data(f_idx).p_max);
                else
                    p_idx = obj.data(f_idx).table(:,3) == power;
                    if any(p_idx)
                        output = obj.data(f_idx).table(p_idx,1);            
                    else
                        error('Requested power %g dBm at frequency %g Hz not calibrated', power, freq);
                    end
                end
            else
                error('Frequency %g Hz not calibrated', freq);
            end
        end
    end    
end
