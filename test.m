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
files = files(5);
folder = files(1).folder;

%% Tikhonov Solution loop
ratio = 10;
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
    [Y, std_noise, N] = add_noise(Y, 40, 'SNR');
    [Xtikh, lambda_L] = tikhonov_solution(Y,A_inv);
    [Xtikh_ADPC, lambda] = ADPC(A_for,Y, ratio);
    temp_struct.Xinv = Xtikh;
    figure
    [RE_nodes, ~, ~] = calculate_re(X_test',Xtikh_ADPC');
    CC_rowwise = calculate_cc(X_test',Xtikh_ADPC');

    % Replace bad lead stats with NaN
    CC_rowwise(test_bads) = median(CC_rowwise);
    RE_nodes(test_bads) = median(RE_nodes);

    subplot(1,3,1)
    plot(Xtikh')
    title('L Curve')
    subplot(1,3,2)
    plot(Xtikh_ADPC')
    title('ADPC')
    subplot(1,3,3)
    plot(X_test')
    title('X_{test}')
    sgtitle({['Test Data ',num2str(i)], ...
    ['\lambda_{ADPC} = ',num2str(lambda),', ADPC Ratio: ',num2str(ratio), ', \lambda_{L} = ',num2str(lambda_L)], ...
        ['CC:',num2str(round(median(CC_rowwise),3)),', RE:',num2str(round(median(RE_nodes),3))]})

end