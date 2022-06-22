function [X,lambda] = tikhonovRT(Y, A)

%function [X,X2] = tikhonovRT(Y, A, L)

% TIKHONOVRT    Tikhonov Regularization, uses Regularization toolbox

%addpath '.\..\..\RegTools'

nFrames = size(Y,2);
[U,s,V] = csvd(A);
%[U2,sm,XX,V2] = cgsvd(A,L);

% [lambda, lambda2] = deal(zeros(nFrames, 1));
lambda = zeros(nFrames, 1);
% 
% [X, X2] = deal(zeros(size(A,2), nFrames));
X = zeros(size(A,2), nFrames);

for fr = 1:nFrames,
   [lambda(fr),wi,wi1,wi2] = l_curve(U, s, Y(:,fr));
   if lambda(fr)>2
       if fr == 1,
           lambda(fr) = 0.05;
       else
           lambda(fr)=lambda(fr-1);
       end
   end
   if lambda(fr)<0.0005
       if fr == 1,
           lambda(fr) = 0.05;
       else
           lambda(fr)=lambda(fr-1);
       end
   end
   X(:,fr) = tikhonov(U,s,V,Y(:,fr),lambda(fr));
%    [lambda2(fr),wii,wii1,wii2] = l_curve(U2,sm,Y(:,fr),'Tikh',L,V2);
%    X2(:,fr) = tikhonov(U2,sm,V2,Y(:,fr),lambda2(fr));
end;
