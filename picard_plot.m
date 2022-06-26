function picard_plot(A,b,time_frame)
[U,s,V] = svd(A);
s = diag(s);
m = length(U);
figure
ratios = zeros(1,m);
prods = ratios;

for i = 1:m
    u = U(:,i);
    sigma = s(i);
    prods(i) = abs(u'*b);
    ratios(i) = prods(i)/sigma;
end
xaxis = 1:m;
loglog(xaxis,s,'Marker','*', 'MarkerFaceColor','red', 'LineStyle',':')
hold on 
loglog(xaxis,prods,'Marker','x', 'MarkerFaceColor','blue','LineStyle',':')
hold on 
loglog(xaxis,ratios,'Marker','o', 'MarkerFaceColor','black','LineStyle',':')
hold on 
xlabel('Singular value Index i of \sigma_{i}')
legend('$\sigma_i$','$u_i^Tb$','$\frac{u_i^Tb}{\sigma_i}$','interpreter','latex','Location','northwest','Fontsize',20)
title(['DPC Plot for t_k=',num2str(time_frame)])
end

