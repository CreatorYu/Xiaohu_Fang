function pout_gc = gain_compression(pout, gain)

gain_ss = mean(gain(1:5));
gain_comp = gain_ss - 1;

ind = 1;

comp_ind = find(gain<gain_comp,1);
pout_gc = pout(comp_ind);

end