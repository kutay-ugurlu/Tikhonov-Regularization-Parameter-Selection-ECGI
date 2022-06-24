%% Polynomial fitting test 
%% Load params
format compact
close all; clc;
addpath('..\Bayesian ECGI\Bayesian\Geometries\')
A_for = struct2array(load('ForwMat_HLT.mat','Trf_HLT_leads'));
A_inv = struct2array(load('ForwMat_HT.mat','Trf_HT_leads'));


files = dir('..\Bayesian ECGI\Bayesian\TestData\EP\*.mat');
files = files(5);
folder = files(1).folder;

%% Tikhonov Solution loop
for i = 1:length(files)
    display(['Now processing file ',num2str(i)])
    fname = files(i).name;
    folder = files(i).folder;
    file = load([folder,'\',fname]);
    X_test = file.ep;
    PaceLoc = X_test.pacing;
    test_bads = X_test.badleads;
    X_test = X_test.potvals;
    Y = A_for*X_test;
    [Y, std_noise, N] = add_noise(Y, 30, 'SNR');
end

%% ADPC
[U,S,V] = svd(A_for);
[nodes, frames] = size(Y);
s = diag(S)';
log_s = log10(s);
m = length(s);
sv_idx = 1:m;
alphas = zeros(1,frames);
polynome = zeros(1,m);
for i = 1:m
    ui = U(:,i);
    polynome(i) = log10(abs(ui'*Y(:,80)));
end
[p5,s5,mu5] = polyfit(sv_idx,polynome,7);
[p_5,s_5] = polyfit(sv_idx,polynome,7);

figure
plot(polynome)
hold on 
P1 = polyval(p5,sv_idx,[],mu5);
P2 = polyval(p_5,sv_idx);
plot(sv_idx,P1)
hold on 
plot(sv_idx,P2)
legend('Polynomial','Scaled','Not Scaled')

