function kbps = shannon(bw,snr_db)

snr = 10^(snr_db/10);

kbps = bw*log2(1+snr)*1e-3;

