function [outputV,outputI] = fun_PowerSupply_N6705A_Lan(Lan_addr,chan)
% clc
% clear
% close all
% Lan_addr='192.168.1.107';
% chan=1;
visa_str = sprintf('TCPIP0::%s::hislip0::INSTR', Lan_addr); 
            obj.socket = visa('agilent', visa_str);
            fopen(obj.socket);
            ident = query(obj.socket, '*IDN?');
            fprintf('Connected to power supply: %s\n', ident);                            

        
            outputV = query(obj.socket, ['MEASure:VOLTage? ' '(@' num2str(chan) ')'], '%s\n', '%g');    

            outputI = query(obj.socket, ['MEASure:CURRent? ' '(@' num2str(chan) ')'], '%s\n', '%g');       
    fclose(obj.socket);
   fprintf('Disconnected from power supply\n');    
end

        
