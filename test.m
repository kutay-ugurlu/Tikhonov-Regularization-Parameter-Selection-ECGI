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

%% Tikhonov Solution loop
show_plot = 0;

for ratio = [1,10,13,15]
    CC_list = zeros(2,l_files);
    RE_list = zeros(2,l_files);
    for i = 1:l_files
        display(['Now processing file ',num2str(i)])
        pause(0.1)
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
        [Xtikh_ADPC, lambda] = ADPC(A_inv,Y, ratio, 0, 1, ['gifs/TestBeat_',num2str(i),'_Ratio_',num2str(ratio),'.gif']);
        temp_struct.Xinv = Xtikh;
        [RE_nodes, ~, ~] = calculate_re(X_test',Xtikh_ADPC');
        CC_rowwise = calculate_cc(X_test',Xtikh_ADPC');
    
        [RE_nodes_Lcurve, ~, ~] = calculate_re(X_test',Xtikh');
        CC_rowwise_Lcurve = calculate_cc(X_test',Xtikh');
    
        % Replace bad lead stats with NaN
        CC_rowwise(test_bads) = median(CC_rowwise);
        RE_nodes(test_bads) = median(RE_nodes);
    
        if show_plot
            figure
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
                ['CC_{ADPC}:',num2str(round(median(CC_rowwise),3)),', RE_{ADPC}:',num2str(round(median(RE_nodes),3))], ...
                ['CC_{L-curve}:',num2str(round(median(CC_rowwise_Lcurve),3)),', RE_{L-curve}:',num2str(round(median(RE_nodes_Lcurve),3))]})
        end
        
        CC_list(1,i) = median(CC_rowwise);
        CC_list(2,i) = median(CC_rowwise_Lcurve);
        RE_list(1,i) = median(RE_nodes);
        RE_list(2,i) = median(RE_nodes_Lcurve);
    end
    GrammStruct = struct();
    GrammStruct.Metrics = [CC_list(:) ; RE_list(:)];
    GrammStruct.RegMethodNames = repmat(repelem(["ADPC";"L-Curve"],l_files,1),2,1);
    GrammStruct.RegMethodNumbers = strcmp(GrammStruct.RegMethodNames,"ADPC");
    GrammStruct.MetricNames = repelem({'CC';'RE'},2*l_files);
    GrammStruct.MethodNumbers = double(strcmp(GrammStruct.RegMethodNames, "ADPC"));
    GrammStruct.MetricNumbers = double(strcmp(GrammStruct.MetricNames, "C"));
    save(['ADPC_vs_LCurve_Results_Ratio_',num2str(ratio),'.mat'],"GrammStruct")
    draw_gramm(['ADPC_vs_LCurve_Results_Ratio_',num2str(ratio),'.mat'],'MetricNames','Metrics','RegMethodNames' ...
        ,['ADPC vs L-Curve Results for ADPC Ratio: ',(num2str(ratio))])
end
