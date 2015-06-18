function out = surface_refiner(points)
%% Use k-mean clustering and convex hull to extract ONLY the surface points
% points: 3-D coordinates
out = [];
z_line = unique(points(:,end),'rows','stable');
n = size(points,1);
nz = size(z_line,1);
for i=1:nz
    pts(i).z = z_line(i);
    pts(i).xy = [];
end
for i=1:n
    ix = find(z_line==points(i,end));
    pts(ix).xy = [pts(ix).xy;points(i,1:2)];
end

%% scan through each layer
z_temp = [];
for i=1:nz
    
    T = kmeans(pts(i).xy,2);
    group1 = [];
    group2 = [];
    for j=1:size(T,1)
        if (T(j)==1)
            group1 = [group1;pts(i).xy(j,:)];
        else
            group2 = [group2;pts(i).xy(j,:)];
        end
    end
    
    K1 = convhull(group1(:,1),group1(:,2));
    K2 = convhull(group2(:,1),group2(:,2));
    xy_temp = [group1(K1,:);group2(K2,:)];
    z_temp = pts(i).z*ones(size(xy_temp,1),1);
    out = [out;[xy_temp z_temp]];
end

end