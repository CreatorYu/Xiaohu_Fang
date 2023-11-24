turn_on = 0;

if turn_on == 1
    AWG_M8190A_Output_ON(1);
    AWG_M8190A_Output_ON(2);
else
    AWG_M8190A_Output_OFF(1);
    AWG_M8190A_Output_OFF(2);
end