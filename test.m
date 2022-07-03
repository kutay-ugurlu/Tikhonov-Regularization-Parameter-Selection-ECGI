format compact
close all; clc; clear;
addpath('..\Bayesian ECGI\Bayesian\Geometries\')
A = load('ForwMat_HLT.mat','Trf_HLT_leads');
A_for = A.Trf_HLT_leads;
A = load('ForwMat_HT.mat','Trf_HT_leads');
A_inv = A.Trf_HT_leads;
pause(0.1)

%% Geometry
GEOM = load('epigeom490sock_closed_aligned_shifted.mat');
FAC = GEOM.(char(fieldnames(GEOM))).fac;
PTS = GEOM.(char(fieldnames(GEOM))).pts;
LV = load('LV.mat');
LV = LV.LV;
RV = load('RV.mat');
RV = RV.RV;
number_of_nodes = size(PTS,1);
X = PTS(:,1);
Y = PTS(:,2);
Z = PTS(:,3);

%% Import AT Functions
addpath('../Bayesian ECGI/AT')
L = surface_laplacian(GEOM.(char(fieldnames(GEOM))));

%% Plot geometries
% 
% addpath('..\Utah Final Geom - Forward\geometries')
% lungs = struct2array(load('lungs_new_shifted.mat'));
% lungs_pts = lungs.pts;
% lungs_fac = lungs.fac;
% x = lungs_pts(:,1);
% y = lungs_pts(:,2);
% z = lungs_pts(:,3);
% torso_tank = struct2array(load('tank771_closed2_outw_struct.mat'));
% torso_pts = torso_tank.pts;
% torso_fac = torso_tank.fac;
% torso_x = torso_pts(:,1);
% torso_y = torso_pts(:,2);
% torso_z = torso_pts(:,3);
% 
% hlinks = {};
% f = figure;
% subplot(1,2,1)
% trisurf(FAC,X,Y,Z,zeros(size(X)));
% hold on 
% trisurf(lungs_fac,x,y,z,0.5*ones(size(x)))
% hold on 
% trisurf(torso_fac,torso_x,torso_y,torso_z,ones(size(torso_x)),'FaceAlpha',0.2)
% title('Forward Model')
% subplot(1,2,2)
% trisurf(FAC,X,Y,Z,zeros(size(X)));
% hold on 
% trisurf(torso_fac,torso_x,torso_y,torso_z,ones(size(torso_x)),'FaceAlpha',0.2)
% title('Inverse Model')
% sgtitle('Boundary Element Method')
% 
% allAxesInFigure = findall(f,'type','axes');
% hlinks{end+1} = linkprop(allAxesInFigure,{'CameraPosition','CameraUpVector'});
% 



%% Files
files = dir('..\Bayesian ECGI\Bayesian\TestData\EP\*.mat');
files = files(1:16);
l_files = length(files);
folder = files(1).folder;

%% Tikhonov Solution loop
show_plot = 0;
var_names = {'Test Beat ID','10', '12.5', '15', '17.5', '20'};
AT_TABLE_CC_L = cell2table(cell(17,6), 'VariableNames', var_names );
AT_TABLE_CC_ADPC = cell2table(cell(17,6), 'VariableNames', var_names);

AT_TABLE_CC_L.("Test Beat ID") = [1:17]';
AT_TABLE_CC_ADPC.("Test Beat ID") = [1:17]';

for ratio = [10,12.5,15,17.5,20]
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
        [Xtikh_ADPC, lambda] = ADPC(A_inv,Y, ratio, 0, 0, ['gifs/TestBeat_',num2str(i),'_Ratio_',num2str(ratio),'.gif']);
        temp_struct.Xinv = Xtikh;
        [RE_nodes, ~, ~] = calculate_re(X_test',Xtikh_ADPC');
        CC_rowwise = calculate_cc(X_test',Xtikh_ADPC');
    
        [RE_nodes_Lcurve, ~, ~] = calculate_re(X_test',Xtikh');
        CC_rowwise_Lcurve = calculate_cc(X_test',Xtikh');
    
        % Replace bad lead stats with the median
        CC_rowwise(test_bads) = median(CC_rowwise);
        RE_nodes(test_bads) = median(RE_nodes);
        CC_rowwise_Lcurve(test_bads) = median(CC_rowwise_Lcurve);
        RE_nodes_Lcurve(test_bads) = median(RE_nodes_Lcurve);

        %% AT metrics
        [CC_AT_L, RE_AT_L] = Generate_AT_CC_RE(X_test,Xtikh, L);
        [CC_AT_ADPC, RE_AT_ADPC] = Generate_AT_CC_RE(X_test, Xtikh_ADPC, L);
        AT_TABLE_CC_ADPC.(num2str(ratio)){i} = CC_AT_ADPC;
        AT_TABLE_CC_L.(num2str(ratio)){i} = CC_AT_L;

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

    temp_name = num2str(ratio);
    data = cell2mat(AT_TABLE_CC_L.(temp_name));
    AT_TABLE_CC_L.(temp_name){end} = median(data);
    data = cell2mat(AT_TABLE_CC_ADPC.(temp_name));
    AT_TABLE_CC_ADPC.(temp_name){end} = median(data);

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
    table2latex(AT_TABLE_CC_L,['L_Curve_AT_CC_Ratio_',num2str(ratio)])
    table2latex(AT_TABLE_CC_ADPC,['ADPC_AT_CC_Ratio_',num2str(ratio)])

end

