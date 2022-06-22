function [X2] = tikhonovRT_singLam(Y, A, singLambda)

% Uses a single (median) lambda value at all times
% TIKHONOVRT    Tikhonov Regularization, uses Regularization toolbox

nFrames = size(Y,2);
[U,s,V] = csvd(A);
%[U2,sm,XX,V2] = cgsvd(A,L);

X2 = zeros(size(A,2), nFrames);

for fr = 1:nFrames
    X2(:,fr) = tikhonov(U,s,V,Y(:,fr),singLambda);
end
