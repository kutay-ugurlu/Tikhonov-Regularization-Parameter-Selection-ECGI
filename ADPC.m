function [xlambda, lambda] = ADPC(A,Y, ratio)

[U,S,V] = svd(A);
[nodes, frames] = size(Y);
s = diag(S)';
log_s = log10(s);
m = length(s);
sv_idx = 1:m;
alphas = zeros(1,frames);

for tk = 1:frames
    btk = Y(:,tk);
    polynome = zeros(1,m);

    for i = 1:m
        ui = U(:,i);
        polynome(i) = log10(abs(ui'*btk)/ratio);
    end

    %% Fit the polynomial and select the best order and the regarding coefficients
    [p5,s5,mu5] = polyfit(sv_idx,polynome,35);
    [p6,s6,mu6] = polyfit(sv_idx,polynome,40);
    [p7,s7,mu7] = polyfit(sv_idx,polynome,45);
    error5 = s5.normr;
    error6 = s6.normr;
    error7 = s7.normr;
    coef_container = {p5,p6,p7};
    mu_container = {mu5,mu6,mu7};
    errors = [error5 error6 error7];
    [~, min_idx] = min(errors);

    %% Now take derivative, find the roots, evaluate themi find maximum, using Fermat's theorem
%     coefs = coef_container{min_idx};
    coefs = p7;
    fitted_polynome = polyval(coefs, sv_idx,[],mu_container{min_idx}); % coefs = p5;

    %% Draw
    clf
    plot(fitted_polynome)
    hold on
    plot(log_s)
    legend('F','s')

    %% Find the nearest SV 
    [~, mi] = find(log_s>fitted_polynome,1,'last');
    if isempty(mi)
        alpha = nan;
    else
        alpha = s(mi);
    end

    %% Assign alpha
    alphas(tk) = alpha;

end
lambda = nanmedian(alphas);
% lambda = 0.05;
xlambda = tikhonovRT_singLam(Y, A, lambda);
end
