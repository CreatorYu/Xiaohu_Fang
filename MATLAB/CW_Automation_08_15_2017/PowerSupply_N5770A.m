classdef PowerSupply_N5770A < handle
    properties (SetAccess = private, Hidden)    
        socket % io socket
    end
    
    properties (SetAccess = private)
        GPIB_addr
    end
    
    methods
        % constructor
        function obj = PowerSupply_N5770A(GPIB_addr)
            obj.GPIB_addr = GPIB_addr;            
        end 
 
        % connect to the power supply
        function connect(obj)            
            old_obj = instrfind('PrimaryAddress', obj.GPIB_addr);
            delete(old_obj);
            visa_str = sprintf('GPIB0::%d::INSTR', obj.GPIB_addr);        
            obj.socket = visa('agilent', visa_str);
            fopen(obj.socket);
            ident = query(obj.socket, '*IDN?');
            fprintf('Connected to power supply: %s\n', ident);                            
        end
       
        % disconnect from power supply
        function disconnect(obj)               
            fclose(obj.socket);
            fprintf('Disconnected from power supply\n');                       
        end 
           
        % measure voltage     
        function output = voltage(obj)
            output = query(obj.socket, 'MEASure:VOLTage?', '%s\n', '%f');
        end 
        
        % measure current
        function output = current(obj)
            output = query(obj.socket, 'MEASure:CURRent?', '%s\n', '%g');
        end
    end
end
        
