function C = lapidoth(bw,snr_db,pn_var)

snr = 10^(snr_db*.1);
C = bw*( .5*log2(1+snr*.5) - .5*log2(exp(1)*pn_var/(2*pi)) )*1e-3;