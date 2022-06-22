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
    Xtikh = tikhonov_solution(Y,A_inv);
    temp_struct.Xinv = Xtikh;

    [RE_nodes, ~, ~] = calculate_re(X_test',Xtikh');
    CC_rowwise = calculate_cc(Xtikh',X_test');

    % Now, eliminate bad_rows
    test_valids = setdiff(1:490,test_bads);
    Xtest_filtered = X_test(test_valids,:);
    Xtikh = Xtikh(test_valids,:);
    [RE_frames, ~, ~] = calculate_re(Xtest_filtered,Xtikh);
    CC_columnwise = calculate_cc(Xtikh,Xtest_filtered);
    
    % Replace bad lead stats with NaN
    CC_rowwise(test_bads) = NaN;
    RE_nodes(test_bads) = NaN;
end