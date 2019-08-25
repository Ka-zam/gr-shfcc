function [out_est,symbols_hat] = estimateqamparams( x , input )

%Get an initial guess

Ntau = ceil(2*input.sps +1);
Neps = 21;

tau_vec = [0 input.sps Ntau];
eps_vec = [-10 10 Neps];

[eps_mat,tau_mat,err_mat] = fillqamerr(x,eps_vec,tau_vec,input);

max_pwr_idx = peakfit2d(real(err_mat)); %Power metric

eps_hat = interp1(linspace(eps_vec(1),eps_vec(2),eps_vec(3)), max_pwr_idx(2) );
tau_hat = interp1(linspace(tau_vec(1),tau_vec(2),tau_vec(3)), max_pwr_idx(1) );

%Get the best estimate for now
[err_vec,symbols_hat] = qammetric( x , eps_hat , tau_hat , input );

%Normalize power
mean_pwr_hat = symbols_hat*symbols_hat'/length(symbols_hat);
all_symbols = [ input.constellation input.pilotsymbols ];
mean_pwr = all_symbols*all_symbols'/length(all_symbols);

amp_hat = sqrt( mean_pwr/mean_pwr_hat );

%Find minimum EVM for phi
phi_vec = linspace(0,350,71);
evm_vec = zeros( size( phi_vec ) );
for k=1:length(phi_vec)
    input.rot = amp_hat*exp(1j*phi_vec(k)*pi/180);
    tmp = qammetric( x , eps_hat , tau_hat , input );
    evm_vec(k) = imag(tmp);
end

[~,idx] = min( evm_vec );
phi_hat = phi_vec( idx );

camp_hat = amp_hat*exp(1j*phi_hat*pi/180);

%Now we can calculate EVM
input.rot = camp_hat;

%[eps_mat,tau_mat,err_mat] = fillqamerr(x,eps_vec,tau_vec,input);

%      FUN can be a parameterized function. Use an anonymous function to
%      capture the problem-dependent parameters:
%         f = @(x,c) x(1).^2+c.*x(2).^2;  % The parameterized function.
%         c = 1.5;                        % The parameter.
%         X = fminsearch(@(x) f(x,c),[0.3;1])

%my_fun = @( vars , x , input ) wrap_qam_err( vars , x , input );
%vars_min = fminsearch( @(vars) my_fun(vars,x,input) ,  [eps_hat tau_hat amp_hat angle(phi_hat) ]  );

%my_fun = @( vars , x , input ) wrap_qam_err( vars , x , input );
vars_min = fminsearch( @(vars) wrap_qam_err(vars,x,input) ,  [eps_hat tau_hat amp_hat phi_hat ]  );


out_est(1) = vars_min(1);
out_est(2) = vars_min(2);
out_est(3) = vars_min(3)*exp(1j*vars_min(4)*pi/180);

input.rot = out_est(3);

[tmp,symbols_hat] = qammetric( x , vars_min(1) , vars_min(2) , input );
out_est(4) = tmp;

function evm = wrap_qam_err( vars , x , input )
eps = vars(1);
tau = vars(2);
amp = vars(3);
phi = vars(4);

input.rot = amp*exp(1j*phi*pi/180);
err = qammetric( x , eps , tau , input );
evm = imag(err);
