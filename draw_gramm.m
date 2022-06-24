function draw_gramm(input_filename,x,y,color, Title)

data = load(input_filename);
f = fields(data);
data = data.(f{1});
%%% 
% Create a gramm object, provide x (year of production) and y (fuel economy) data,
% color grouping data (number of cylinders) and select a subset of the data
g=gramm('x',data.(x),'y',data.(y),'Color',categorical(data.(color)));%,'subset',cars.Cylinders~=3 & cars.Cylinders~=5);
%%% 
% Subdivide the data in subplots horizontally by region of origin using
% facet_grid()
% g.facet_grid([],data.Orders);
%%%
% Plot raw data as points
% % % % % % g.geom_point();
%%%
% Plot linear fits of the data with associated confidence intervals
% g.stat_glm();
%%%
% Set appropriate names for legends
% g.set_names('column','Origin','x','Datasets','y','SpatialRE','color','Training Data');
%%%
g.set_names('x','Metrics','y','Metric Values','color','Method Names');
g.set_color_options('map','matlab');
g.set_order_options('x',0,'color',1); %additional category is ignored
g.set_text_options('base_size',16);
% figure('Position',figPos);
% Set figure title
g.set_title({Title,['Simulations run on 16 different beats']});
%%%
% Do the actual drawing
figure('Position',[0 100 1800 600]);
g.stat_boxplot()
g.draw();
g.export('file_name',['images/',Title],'file_type','svg')
end

