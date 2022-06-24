data = load('SPATIAL_GRAMM_RESULTS_NEW.mat');
data = data.SPATIALDATA;
%%% 
% Create a gramm object, provide x (year of production) and y (fuel economy) data,
% color grouping data (number of cylinders) and select a subset of the data
g=gramm('x',data.TestSetChar,'y',data.spatialCC,'color',data.TrainingData_sorted);%,'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
%%% 
% Subdivide the data in subplots horizontally by region of origin using
% facet_grid()
% g.facet_grid([],data.Orders);
%%%
% Plot raw data as points
% g.geom_point();
%%%
% Plot linear fits of the data with associated confidence intervals
% g.stat_glm();
%%%
% Set appropriate names for legends
g.set_names('column','Origin','x','Datasets','y','SpatialCC','color','Training Data');
%%%
% Set figure title
g.set_title('Spatial CC of simulations run on different datasets with training data');
%%%
% Do the actual drawing
figure('Position',[100 100 800 400]);
g.stat_boxplot()
g.draw();
