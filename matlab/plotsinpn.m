function plotsinpn(N,deltavar)

fs=48e3;
fc = 3e3;

figure(99)
clf

[s,t]=sinepn(fc,fs,deltavar,N);

[pxx,f]=pwelch(s,[],[],[],fs);
pxx=db(pxx);
pxx = pxx - max(pxx);

subplot(2,1,1)
plot(t,s)
subplot(2,1,2)
semilogx(f,pxx)