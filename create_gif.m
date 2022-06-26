% create gif
format compact
close all; clc;
addpath('..\Bayesian ECGI\Bayesian\Geometries\')
A = load('ForwMat_HLT.mat','Trf_HLT_leads');
A_for = A.Trf_HLT_leads;
A = load('ForwMat_HT.mat','Trf_HT_leads');
A_inv = A.Trf_HT_leads;

%% Geometry
GEOM = load('epigeom490corrected.mat');
FAC = GEOM.(char(fieldnames(GEOM))).fac;
PTS = GEOM.(char(fieldnames(GEOM))).pts;
LV = load('LV.mat');
LV = LV.LV;
RV = load('RV.mat');
RV = RV.RV;
number_of_nodes = size(PTS,1);

%% Files
files = dir('..\Bayesian ECGI\Bayesian\TestData\EP\*.mat');
files = files(1:16);
l_files = length(files);
folder = files(1).folder;
n = 1:0.01:5;
nImages = length(n);

%%
for i = 1:l_files

    im = {};
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
    [Xtikh, lambda_L] = tikhonov_solution(Y,A_inv);
    f = fig;
    [Xtikh_ADPC, lambda] = ADPC(A_inv,Y, ratio, 1, 1, ['TestBeat_',num2str(i),'.gif']);



end


fig = figure;
for idx = 1:nImages
    
end
close;

filename = 'testAnimated.gif'; % Specify the output file name