chdir('..')
addpath('AT')
chdir('Bayesian')
addpath('Geometries')
addpath('RESULTS')
files = dir('RESULTS\*.mat');
files = files((~endsWith({files.name}, 'Temporal.mat')) & (~endsWith({files.name}, 'Spatial.mat')) );
files = files((~startsWith({files.name},'ALL')));
folder = files(1).folder;
test_files = dir('TestData\EP\*.mat');
test_folder = test_files(1).folder;

%% Geometries

% Close 

% GEOM = load('epigeom490sock_closed_aligned_shifted.mat');
% GEOM = GEOM.(char(fieldnames(GEOM)));
% FAC = GEOM.fac;
% PTS = GEOM.pts;
% x = PTS(:,1);
% y = PTS(:,2);
% z = PTS(:,3);
% L = surface_laplacian(GEOM);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open 

GEOM = load('epigeom490corrected.mat');
GEOM = GEOM.(char(fieldnames(GEOM)));
FAC = GEOM.fac;
PTS = GEOM.pts;
x = PTS(:,1);
y = PTS(:,2);
z = PTS(:,3);
L = surface_laplacian(GEOM);


%% Create Error table 
data = load([folder,'\',files(1).name]);
table_data = cell(19,5);
table_data(:,1) = mat2cell((1:19)',ones(19,1));
TABLE  = cell2table(table_data, 'VariableNames', cat(1,'Test beat',fieldnames(data)));

%% Main Loop
% 10 11 12 14 are problematic
hlinks = {};
for i = 1:length(files)
    display(['Processing file ',num2str(i)])
    f = figure;
    sgtitle(['Test Beat: ',num2str(i)])
    file = files(i).name;
    data = load([folder,'\',file]);
    test_file = test_files(i).name;
    X_test = load([test_folder,'\',test_file]);
    real_paceLoc = X_test.ep.pacing;
    fnames = fieldnames(data);
    subplots = [];
    for j = 1:length(fieldnames(data))
        subplots(end+1) = subplot(2,2,j);
        subdata = data.(fnames{j});
        Xinv = subdata.Xinv;
        AT = ActivationTimeST(Xinv,L);
        estimated_pace_loc = find(AT == min(AT));
        Localization_Error = vecnorm(PTS(real_paceLoc,:)-PTS(estimated_pace_loc,:),2,2);
        h = trisurf(FAC,x,y,z,AT);
        hold on 
        scatter3(PTS(real_paceLoc,1),PTS(real_paceLoc,2),PTS(real_paceLoc,3),'black','filled');
        hold on 
        scatter3(PTS(estimated_pace_loc,1),PTS(estimated_pace_loc,2),PTS(estimated_pace_loc,3),'red','filled');

        % Grab the mean of pacelocs 
%         view_point = 0.5 * (PTS(estimated_pace_loc,:) + PTS(real_paceLoc,:));
%         [azimuth,elevation,r] = cart2sph(view_point(1),view_point(2),view_point(3));
%         view(azimuth,elevation)

        % Continue
        axis off 
        grid off 
        colorbar
        set(h,'Facecolor','Interp','EdgeColor','Interp')
        title({fnames{j},['Localization Error: ',num2str(Localization_Error)]})
        legend('AT','Real PaceLoc','Estimated PaceLoc')
        TABLE.(fnames{j})(i) = {Localization_Error};
    end
    allAxesInFigure = findall(f,'type','axes');
    hlinks{end+1} = linkprop(allAxesInFigure,{'CameraPosition','CameraUpVector'});
end
save('AT_Results.mat','TABLE')
MAT = cell2mat(TABLE{:,2:end});
mean(MAT)
table2latex(TABLE,'AT.tex')