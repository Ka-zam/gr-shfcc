function [pxx,fxx] = plotsinpn(N,var0,var3)

fs=96e3;
fc = 3e3;

figure(99)
clf

[s,t]=sinepn(fc,fs,var0,var3,N);

[pxx,fxx]=pwelch(s,8192,0,[],fs);
pxx=db(pxx);
pxx = pxx - max(pxx);

%subplot(2,1,1)
%plot(t,s)
%subplot(2,1,2)
semilogx(fxx,pxx)
grid on