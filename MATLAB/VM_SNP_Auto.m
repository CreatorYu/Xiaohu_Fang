function VM_SNP_Auto
    close all;
    clear;
    instrreset;
    %instrhwinfo('gpib','agilent')
    PNA=gpib('agilent', 7, 16);
    PS1port=gpib('agilent', 7, 5); % The bottom one
    PS2port=gpib('agilent', 7, 9);
    DriverMDD = [pwd '\Instrument_Functions\PowerSupply_E3631A\agilent_e3631a.mdd'];
    SaveDir = 'D:\Measurements\VM\';
    PS1 = icdevice(DriverMDD, PS1port);
    PS2 = icdevice(DriverMDD, PS2port);
    
    fopen(PNA);
    connect(PS1);
    connect(PS2);

    PS1.Output(1).Enabled='on';
    PS2.Output(1).Enabled='on';
    %fprintf(PNA, '*RST');
    Vcom1 = 0.805;
    Vos1 = 0.005;
    Vcom2 = 0.820;
    Vos2 = -0.020;
    Count = 0;
    %query(PNA, 'STAT:OPER:COND?')
    fprintf(PNA, 'CALC:PAR:SEL "CH1_S11_1"');
    
    for IC=-0.55:0.1:0.55
        PS2.Output(1).VoltageLevel=Vcom1 + IC + Vos1;
        PS2.Output(2).VoltageLevel=Vcom1 - IC - Vos1;
        for QC = -0.55:0.1:0.55
            PS1.Output(1).VoltageLevel=Vcom2 + QC - Vos2+0.002;
            PS1.Output(2).VoltageLevel=Vcom2 - QC + Vos2;

            pause(1);
            %query(PNA, 'CALC:DATA:SNP:PORTs? "1,2,3,4" ')

            Path = [SaveDir num2str(Count) '.s4p'];
            fprintf(PNA, 'CALC:DATA:SNP:PORTs:SAVE "1,2,3,4", "%s"', Path);
            query(PNA, '*OPC?');
            Count = Count + 1;
        end
    end
    
    invoke(PS1.System, 'beep');
    fclose(PNA);
end

