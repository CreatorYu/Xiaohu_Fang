classdef SignalGenerator_E8267D < handle
    
    properties (SetAccess = private, Hidden)    
        socket % io socket
    end 

    properties (SetAccess = private)
        GPIB_addr  
        max_power_allowed % The signal generator will not accept  
                          % input power value above max_power_allowed,
                          % specified in dBm.
    end

    methods
        % constructor
        function obj = SignalGenerator_E8267D(GPIB_addr, max_power_allowed)
            %TCPIP0::192.168.1.103::5025::SOCKET
            obj.GPIB_addr = GPIB_addr;
            obj.max_power_allowed = max_power_allowed;
        end 
    
        % connect to signal generator
        function connect(obj)
            %old_obj = instrfind('PrimaryAddress', obj.GPIB_addr);  %use GPIB
            old_obj = instrfind('PrimaryAddress', obj.GPIB_addr);   %use LAN
            delete(old_obj);
            %visa_str = sprintf('GPIB0::%d::INSTR', obj.GPIB_addr);  %use GPIB
            visa_str = sprintf('TCPIP0::%s::5025::SOCKET', obj.GPIB_addr);  %use LAN
            obj.socket = visa('agilent', visa_str);
            fopen(obj.socket);
            ident = query(obj.socket, '*IDN?');
            fprintf('Connected to signal generator: %s\n', ident);                            
        end 
    
        % disconnect from signal generator
        function disconnect(obj)               
            fclose(obj.socket);
            fprintf('Disconnected from signal generator\n');                       
        end 
    
        % preset instrument
        function preset(obj)
            fprintf(obj.socket, '*RST');
        %    fprintf(deviceObject,':OUTPut:MODulation:STATe OFF')
        end
        % Modulation OFF or ON
        function modulation_off(obj)
%            fprintf(obj.socket, '*RST');
            fprintf(obj.socket,':OUTPut:MODulation:STATe OFF');
        end
        % Modulation OFF or ON
        function modulation_on(obj)
%            fprintf(obj.socket, '*RST');
            fprintf(obj.socket,':OUTPut:MODulation:STATe ON');
        end
    
        % set/get frequency           
        function output = frequency(obj, freq)
            if(nargin == 1)
                output = query(obj.socket, ':FREQuency?', '%s\n', '%g');
            else
                fprintf(obj.socket, ':FREQuency %d Hz', freq);
            end       
        end 
    
        % set/get power           
        function output = power(obj, power)       
            if(nargin == 1)
                output = query(obj.socket, ':POWer?', '%s\n', '%g');
            else
                if(power > obj.max_power_allowed)
                    error('Attempt to set signal generator power to %g dBm is denied\nbecause it exceeds %g dBm, the maximum allowable power level\n.', power, obj.max_power_allowed);
                else
                    fprintf(obj.socket, ':POWer %d dBm', power);
                end
            end       
        end
    
        % RF on/off
        function output = rf(obj, status)
            if(nargin == 1)
                output = query(obj.socket, ':OUTPut?', '%s\n', '%g');
            else
                fprintf(obj.socket, ':OUTPut %d', status);
            end
        end           
    end   
end           
