function X2 = tikhonov_solution(Y,A)
[X,lambda] = tikhonovRT(Y, A);
[X2] = tikhonovRT_singLam(Y, A, median(lambda));
end

