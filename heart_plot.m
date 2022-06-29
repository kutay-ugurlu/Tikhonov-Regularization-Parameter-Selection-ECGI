%% heart plot 

format compact
close all; clc; clear;
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
X = PTS(:,1);
Y = PTS(:,2);
Z = PTS(:,3);

%% 
color_vec = zeros(490,1);
color_vec(LV) = 1;
trisurf(FAC,X,Y,Z,color_vec,'FaceColor','interp','FaceAlpha',0.7)
colormap hot
colormap autumn
axis off
hold on 
p(1) = patch(NaN,NaN,'red');
p(2) = patch(NaN,NaN,'yellow');
hold off
legend(p,'RV','LV')
title('Left and Right Ventricles of the Heart')