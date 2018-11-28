function [pxx,fxx] = plotsinpn(N,deltavar)

fs=96e3;
fc = 3e3;

figure(99)
clf

[s,t]=sinepn(fc,fs,deltavar,N);

[pxx,fxx]=pwelch(s,8192,0,[],fs);
pxx=db(pxx);
pxx = pxx - max(pxx);

subplot(2,1,1)
plot(t,s)
subplot(2,1,2)
plot(fxx,pxx)