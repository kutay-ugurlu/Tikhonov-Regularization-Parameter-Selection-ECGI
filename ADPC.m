function [xlambda, lambda, time_elapsed] = ADPC(A,Y, ratio, show_plot, if_save, filename)
set(0,'DefaultFigureVisible','off');
if nargin<6
    filename = 'output.gif';
end

tic
[U,S,~] = svd(A);
[~, frames] = size(Y);
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
    [p5,s5,mu5] = polyfit(sv_idx,polynome,5);
    [p6,s6,mu6] = polyfit(sv_idx,polynome,6);
    [p7,s7,mu7] = polyfit(sv_idx,polynome,7);
    error5 = s5.normr;
    error6 = s6.normr;
    error7 = s7.normr;
    coef_container = {p5,p6,p7};
    mu_container = {mu5,mu6,mu7};
    errors = [error5 error6 error7];
    [~, min_idx] = min(errors);

    %% Now take derivative, find the roots, evaluate themi find maximum, using Fermat's theorem
    coefs = coef_container{min_idx};
    fitted_polynome = polyval(coefs, sv_idx,[],mu_container{min_idx}); 

    %% Draw
    
    if tk == 1
        f = figure;
    end
    clf
    plot(fitted_polynome)
    hold on
    plot(log_s)
    legend('Fitted Polynomial','log(\sigma_{i})')
    xlabel('SV index i')
    title('log(u_i^Tb) and \sigma_{i} for t_k = ',num2str(tk))

    if show_plot
        drawnow()
    end

    if if_save
        frame = getframe(f);
        im{tk} = frame2im(frame);
    end



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
time_elapsed = toc;

if if_save
    for idx = 1:length(im)
        [IMAGE,map] = rgb2ind(im{idx},256);
        if idx == 1
            imwrite(IMAGE,map,filename,'gif','LoopCount',Inf,'DelayTime',1);
        else
            imwrite(IMAGE,map,filename,'gif','WriteMode','append','DelayTime',0.01);
        end
    end
end

lambda = nanmedian(alphas);
% lambda = 0.05;
xlambda = tikhonovRT_singLam(Y, A, lambda);
set(0,'DefaultFigureVisible','on');
end
