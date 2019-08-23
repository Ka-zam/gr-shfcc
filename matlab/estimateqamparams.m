function [out_est,camp_hat] = estimateqamparams( x , input )

%Get an initial guess

Ntau = 51;
Neps = 21;

tau_vec = [0 input.sps Ntau];
eps_vec = [-.02 .02 Neps];

[eps_mat,tau_mat,err_mat] = fillqamerr(x,eps_vec,tau_vec,input);

max_pwr_idx = peakfit2d(real(err_mat)); %Power metric

eps_hat = interp1(linspace(eps_vec(1),eps_vec(2),eps_vec(3)), max_pwr_idx(2) );
tau_hat = interp1(linspace(tau_vec(1),tau_vec(2),tau_vec(3)), max_pwr_idx(1) );

%Get the best estimate for now
[err_vec,symbols_hat] = qammetric( x , eps_hat , tau_hat , input );

%Normalize power
mean_pwr_hat = symbols_hat*symbols_hat'/length(symbols_hat);
mean_pwr = input.constellation*input.constellation'/length(input.constellation);

amp_hat = sqrt( mean_pwr/mean_pwr_hat );

symbols_hat = symbols_hat*amp_hat;

%Pilot symbol error vector
%Find a pilot symbol pair

tmp_pwr =  symbols_hat.*conj(symbols_hat);
for k=1:length(tmp_pwr)-1
    if tmp_pwr(k) > 1.8 && tmp_pwr(k+1) > 1.8
        break;
    end
end

%Now rotate the constellation

pilot_sym = -1.5j;

phi_hat = pilot_sym/symbols_hat(k);
phi_hat = phi_hat/abs(phi_hat);

symbols_hat = symbols_hat*phi_hat;

camp_hat = amp_hat*phi_hat;

%Now we can calculate EVM
input.rot = camp_hat;
[eps_mat,tau_mat,err_mat] = fillqamerr(x,eps_vec,tau_vec,input);

%      FUN can be a parameterized function. Use an anonymous function to
%      capture the problem-dependent parameters:
%         f = @(x,c) x(1).^2+c.*x(2).^2;  % The parameterized function.
%         c = 1.5;                        % The parameter.
%         X = fminsearch(@(x) f(x,c),[0.3;1])

%my_fun = @( vars , x , input ) wrap_qam_err( vars , x , input );
%vars_min = fminsearch( @(vars) @my_fun(vars,x,input) ,  [eps_hat tau_hat amp_hat angle(phi_hat) ]  );

out_est(1) = eps_hat;
out_est(2) = tau_hat;


function evm = wrap_qam_err( vars , x , input )
eps = vars(1);
tau = vars(2);
amp = vars(3);
phi = vars(4);

input.rot = amp*exp(1j*phi);
err = qammetric( x , eps , tau , input );
evm = err(2);
