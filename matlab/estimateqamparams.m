function [epsilon,tau,A] = estimateqamparams( x , input )

%Get an initial guess

Ntau = 51;
Neps = 21;

tau_vec = linspace(0,10,Ntau);
eps_vec = linspace(-.02,.02,Neps);

[eps_mat,tau_mat,err_mat] = fillqamerr(x,eps_vec,tau_vec,input);

max_pwr_idx = peakfit2d(err_mat);

epsilon = interp1(eps_vec, max_pwr_idx(2) );
tau     = interp1(tau_vec, max_pwr_idx(1) );
