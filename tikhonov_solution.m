function [X2, lambda] = tikhonov_solution(Y,A)
[X,lambda] = tikhonovRT(Y, A);
lambda = median(lambda);
[X2] = tikhonovRT_singLam(Y, A, lambda);
end

