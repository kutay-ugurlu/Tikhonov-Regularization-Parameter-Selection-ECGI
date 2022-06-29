function neighbours = build_nbours(triangles, nLeads)

% BUILD_NBOURS   Find the 1st order neighbours of every lead
%
% Usage: 
%        neighbours = build_nbours(triangles, nLeads);
%
% Inputs:
%   triangles   geom.fac (size: (numOfTri x 3); 
%               node indexing should start with 1, not 0)
%   nLeads      Number of leads on the surface
%
% Output:
%   neighbours  (1st order) neighours matrix:
%                1st column: lead index, 
%                2nd column: number of neighbours
%                3rd-last column: lead indices of neighbours
% 

num_nbours = zeros(nLeads,1);

for desired_node = 1:nLeads,
	[r, c] = find(triangles == desired_node);
	a = triangles(r,:);
	a = a(:);
	num_nbours(desired_node) = length(union(a, a))-1;
end

neighbours = zeros(nLeads, max(num_nbours)+2);
neighbours(:,1) = (1:nLeads)';
neighbours(:,2) = num_nbours;

for desired_node = 1:nLeads,
	[r, c] = find(triangles == desired_node);
	a = triangles(r,:);
	a = a(:);
	a = union(a,a);
	a = a(find(a ~= desired_node));
	neighbours(desired_node, 3:length(a)+2) = a';
end


