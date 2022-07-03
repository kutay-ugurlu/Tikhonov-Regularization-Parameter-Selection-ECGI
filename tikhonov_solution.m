function [X2, lambda, time_elapsed] = tikhonov_solution(Y,A)
tic
[X,lambda] = tikhonovRT(Y, A);
lambda = median(lambda);
[X2] = tikhonovRT_singLam(Y, A, lambda);
time_elapsed = toc;
end

