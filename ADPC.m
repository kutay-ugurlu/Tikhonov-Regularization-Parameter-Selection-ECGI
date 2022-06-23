function [xlambda, lambda] = ADPC(A,Y)

[U,S,V] = svd(A);
[nodes, frames] = size(Y);
s = diag(S);
log_s = log10(s);
m = length(s);
sv_idx = 1:m;
global_max = -inf;
alphas = zeros(1,frames);

for tk = 1:frames
    btk = Y(:,tk);
    polynome = zeros(1,m);

    for i = 1:m
        ui = U(:,i);
        polynome(i) = log10(abs(ui'*btk));
    end

    %% Fit the polynomial and select the best order and the regarding coefficients
    [p5,s5] = polyfit(sv_idx,polynome,5);
    [p6,s6] = polyfit(sv_idx,polynome,6);
    [p7,s7] = polyfit(sv_idx,polynome,7);
    error5 = s5.normr;
    error6 = s6.normr;
    error7 = s7.normr;
    coef_container = {p5,p6,p7};
    errors = [error5 error6 error7];
    [~, min_idx] = min(errors);

    %% Now take derivative, find the roots, evaluate themi find maximum, using Fermat's theorem
    coefs = coef_container{min_idx};
    coefs_prime = polyder(coefs);
    local_peaks_idx = roots(coefs_prime);
    peak = polyval(coefs,local_peaks_idx);
    peak = peak((imag(peak)==0)); 
    

    %% Find the golbal maximum of the polynomial
    global_max = max([peak; polyval(coefs,1); polyval(coefs,m)]);

    %% Find the nearest SV 
    [~, mi] = min(abs(log10(s)-global_max));
    alpha = s(mi);

    %% Assign alpha
    alphas(tk) = alpha;
end
lambda = median(alphas);
xlambda = tikhonovRT_singLam(Y, A, lambda);
end
