% --- plot 3D of predicted whole model
cm = colormap(pink);
max_est = max(est);
colorSize = size(cm,1);
sur_thres = 0.007;
for i=1:size(est,1)
	if (est(i)==0)
		cid(i,:) = cm(1,:);
		vis{i} = 'on';
	elseif (est(i)>0)
		if (est(i)<=sur_thres)
			cid(i,:) = cm(ceil(est(i)/sur_thres*64),:);
			vis{i} = 'on';
		else
			cid(i,:) = cm(end,:);
			vis{i} = 'off';
		end
	else
		cid(i,:) = cm(end,:);
		vis{i} = 'off';
	end
end
markerSize = 25*ones(size(est,1),1);
scatter3(S(:,1),S(:,2),S(:,3),markerSize,cid,'.');

% --- Plot 3D of predicted and true model (show surface points ONLY)

cm = colormap(pink);
max_est = max(est);
sur_thres = 0.0001;
S_ = [];
for i=1:size(est,1)
	if (est(i)>=0&&est(i)<=sur_thres)
		S_ = [S_;S(i,:)];
	end
end
cid = repmat(cm(1,:),size(S_,1),1);
markerSize = 25*ones(size(S_,1),1);
scatter3(S_(:,1),S_(:,2),S_(:,3),markerSize,cid);

cid = repmat(cm(1,:),size(X,1),1);
markerSize = 25*ones(size(X,1),1);
figure(2)
scatter3(X(:,1),X(:,2),X(:,3),markerSize,cid);

% --- Test Yufei code about creating the field
Psi = [10 1 1 10]; % psi_1, psi_2x, psi_2y, sig_t
sig_w = 1e-5; % small number to avoid numerical problem
covfunc = {'covSum', {'covSEard','covNoise'}};
loghyper = [log(Psi(1));log(Psi(2));log(Psi(3));log(Psi(4));log(sig_w)];

num_grid = 21;
num_time = 30; % sec
ts = 1; % sampling time
XMIN = -2; XMAX = 2;
YMIN = -2; YMAX = 2;
ZMIN = -100; ZMAX = 100;
x_grid = linspace(XMIN,XMAX,num_grid)';
y_grid = linspace(YMIN,YMAX,num_grid)';
t_grid = 1:ts:ts*num_time;
s_grid = zeros(num_grid^2*num_time,3);

for i = 1:num_time
    s_grid((i-1)*num_grid^2+1:i*num_grid^2,1) = t_grid(i);
    for j = 1:num_grid
        s_grid((i-1)*num_grid^2+(j-1)*num_grid+1:(i-1)*num_grid^2+j*num_grid,2:3)...
            = [x_grid(j)*ones(num_grid,1) y_grid];
    end
end

Z_grid = reshape(chol(feval(covfunc{:},loghyper,s_grid))'...
    *randn(num_grid^2*num_time,1),num_grid,num_grid,num_time);
	
% --- Print file to .ply extension

% --- Read data from "Centerlines_J.xlsx" and merger on-surface and inner into .mat file
% --- J1
clear
fileDir = './Centerlines_J.xlsx';
sheetName = 'J1';
range = 'A2:D190';
[raw,dataName] = xlsread(fileDir,sheetName,range);
raw(:,end) = - raw(:,end);
load JJ1
data.on_surface = [JJ,zeros(size(JJ,1),1)];
data.inner_line = raw;
save('JJ1_inner','data');

% --- J2
clear
fileDir = './Centerlines_J.xlsx';
sheetName = 'J2';
range = 'A2:D246';
[raw,dataName] = xlsread(fileDir,sheetName,range);
raw(:,end) = - raw(:,end);
load JJ2
data.on_surface = [JJ,zeros(size(JJ,1),1)];
data.inner_line = raw;
save('JJ2_inner','data');

% --- J3
clear
fileDir = './Centerlines_J.xlsx';
sheetName = 'J3';
range = 'A2:D251';
[raw,dataName] = xlsread(fileDir,sheetName,range);
raw(:,end) = - raw(:,end);
load JJ3
data.on_surface = [JJ,zeros(size(JJ,1),1)];
data.inner_line = raw;
save('JJ3_inner','data');

% --- J4
clear
fileDir = './Centerlines_J.xlsx';
sheetName = 'J2';
range = 'A2:D252';
[raw,dataName] = xlsread(fileDir,sheetName,range);
raw(:,end) = - raw(:,end);
load JJ4
data.on_surface = [JJ,zeros(size(JJ,1),1)];
data.inner_line = raw;
save('JJ4_inner','data');


% --- Compute Hausdorff distance
[hd,~] = HausdorffDist(S_,X(1:cutoff,:));


% --- Test Hausdorff function
X =[0,0,0;1,0,0;1,1,0;0,1,0];
Y =[0,0,1;1,0,1;1,0,0;0,2,0];
scatter3(X(:,1),X(:,2),X(:,3),'r');
hold on
scatter3(Y(:,1),Y(:,2),Y(:,3),'b*');
hold off
[hd,~] = HausdorffDist(X,Y)



scatter3(S_test_est(:,1),S_test_est(:,2),S_test_est(:,3))
scatter3(S_est(:,1),S_est(:,2),S_est(:,3))

figure(3)
hold on
plot(est_train)
plot([0 7e4],[thres_train_min thres_train_min],'k-')

figure(4)
hold on
plot(est_test,'r')
plot(est_train,'b')
plot([0 7e4],[thres_train_min thres_train_min],'k-')
plot([0 7e4],[thres_train_min+thres_offset thres_train_min+thres_offset],'k--')


a = 1;
hold on
plot(predict(a).est_test,'r')
plot(predict(a).est_train,'b')
plot([0 7e4],[predict(a).thres_train predict(a).thres_train],'k-')

% --- Plot a slice of 3-D organ
z_slice = 2000;
a = 1;
index_slice = find(predict(a).S_est(:,3)==predict(a).S_est(z_slice,3));
S_plot = predict(a).S_est(index_slice,:);
scatter3(S_plot(:,1),S_plot(:,2),S_plot(:,3));

z_slice = 2000;
a = 1;
index_slice = find(S_est_min_(:,3)==S_est_min_(z_slice,3));
S_plot = S_est_min_(index_slice,:);
scatter3(S_plot(:,1),S_plot(:,2),S_plot(:,3));


% --- show convex hull and k-mean cluster (patient BB)
z_slice = 1000; % 650: two segments
a = 1;
index_slice = find(S_test_est(:,3)==S_test_est(z_slice,3));
S_plot = S_test_est(index_slice,:);
plot(S_plot(:,1),S_plot(:,2),'bo');
S_xy = S_plot(:,1:2);
T = kmeans(S_xy,2);
group1 = [];
group2 = [];
pts_thres = 3;
ch_pts1 = [];
ch_pts2 = [];
hold on
for j=1:size(T,1)
	if (T(j)==1)
		group1 = [group1;S_xy(j,:)];
	else
		group2 = [group2;S_xy(j,:)];
	end
end
plot(group1(:,1),group1(:,2),'b*');
plot(group2(:,1),group2(:,2),'r*');
if (size(group1,1)>pts_thres&&size(group2,1)>pts_thres)
	temp1 = boundary_select(group1);
	temp2 = boundary_select(group2);
	%xy_temp = [temp1;temp2];
	ch_pts1 = [ch_pts1;temp1];
	ch_pts2 = [ch_pts2;temp2];
elseif(size(group1,1)<=pts_thres&&size(group2,1)>pts_thres)
	xy_temp = boundary_select(group2);
	ch_pts2 = [ch_pts2;xy_temp];
elseif (size(group2,1)<=pts_thres&&size(group1,1)>pts_thres)
	xy_temp = boundary_select(group1);
	ch_pts1 = [ch_pts1;xy_temp];
end
plot(ch_pts1(:,1),ch_pts1(:,2),'k--','LineWidth',1.5);
plot(ch_pts2(:,1),ch_pts2(:,2),'k--','LineWidth',1.5);
xlabel('(mm)');
ylabel('(mm)');
set(gca,'FontSize',16);



	
	
plot(est_test,'r')
hold on
plot([0 7e4],[thres_min thres_min],'k-')
plot(est_train)
plot([0 7e4],[opt_thres opt_thres],'r-')

plot(predict.est_test,'r')
hold on
plot([0 7e4],[predict.thres_test predict.thres_test],'r-','LineWidth',2)
plot(predict.est_train)
plot([0 7e4],[predict.thres_train.up predict.thres_train.up],'b-','LineWidth',2)

% test surface_refiner.m
load PP13_test
out = surface_refiner(predict.S_est);


scatter3(predict.S_est(:,1),predict.S_est(:,2),predict.S_est(:,3))
hold on
scatter3(predict.S_true(:,1),predict.S_true(:,2),predict.S_true(:,3),'ro')



% Write result to text file
fid = fopen('./cloud_point.txt','w');
for i=1:size(predict.S_est,1)
	 fprintf(fid,[num2str(predict.S_est(i,1)) ',' ...
				  num2str(predict.S_est(i,2)) ',' ...
				  num2str(predict.S_est(i,3))]);
     fprintf(fid,'\n');
end
fclose(fid);

% Plot the mesh
load run_all_061815
h = pointCloud2mesh(predict.S_est,[0 0 1],0.2);
coord = h.vertices;
conn = h.triangles;


hold on;
for i=1:size(conn,1)
	plot3(coord(conn(i,[1 2]),1),coord(conn(i,[1 2]),2),coord(conn(i,[1 2]),3),'b*-');
	plot3(coord(conn(i,[2 3]),1),coord(conn(i,[2 3]),2),coord(conn(i,[2 3]),3),'b*-');
	plot3(coord(conn(i,[1 3]),1),coord(conn(i,[1 3]),2),coord(conn(i,[1 3]),3),'b*-');
end
scatter3(predict.S_est(:,1),predict.S_est(:,2),predict.S_est(:,3),'ro');
hold off

% -----------------------
t = 0:pi/10:2*pi;
[x,y,z] = cylinder(sin(pi/10*t));
coord = [reshape(x,[],1) reshape(y,[],1) reshape(z,[],1)];
h = pointCloud2mesh(coord,[0 0 1],0.6);
conn = h.triangles;

hold on;
for i=1:size(conn,1)
	plot3(coord(conn(i,[1 2]),1),coord(conn(i,[1 2]),2),coord(conn(i,[1 2]),3),'b*-');
	plot3(coord(conn(i,[2 3]),1),coord(conn(i,[2 3]),2),coord(conn(i,[2 3]),3),'b*-');
	plot3(coord(conn(i,[1 3]),1),coord(conn(i,[1 3]),2),coord(conn(i,[1 3]),3),'b*-');
end
hold off


% --------------
load ./results/HH_HPCC_est051115

[S1,S2,S3] = meshgrid(option.x_mesh,option.y_mesh,option.z_mesh); % [middle shortest longest]
S_temp = [S1(:),S2(:),S3(:)];
S_test = [];
thres_min = 1.6;
for j=1:size(est,1)
	if (est(j,1)>=0&&est(j,1)<=thres_min)
		S_test = [S_test;S_temp(j,:)];
	end
	fprintf('Process:%0.2f%%\n',j/size(est,1)*100);
end
S_est = surface_refiner(S_est);


% --------------
load ./Patient_Data/AA1

temp = AA(:,1);
AA(:,1) = AA(:,3);
AA(:,3) = temp;

h = pointCloud2mesh(AA,[0 0 1],0.2);
coord = h.vertices;
conn = h.triangles;

hold on;
for i=1:size(conn,1)
	plot3(coord(conn(i,[1 2]),1),coord(conn(i,[1 2]),2),coord(conn(i,[1 2]),3),'b*-');
	plot3(coord(conn(i,[2 3]),1),coord(conn(i,[2 3]),2),coord(conn(i,[2 3]),3),'b*-');
	plot3(coord(conn(i,[1 3]),1),coord(conn(i,[1 3]),2),coord(conn(i,[1 3]),3),'b*-');
end
hold off

% -------------
load ./Patient_Data/AA1
[the,rho,z] = cart2pol(AA(:,1),AA(:,2),AA(:,3));
scatter3(the,rho,z);


% ---------------
plot(predict(1).est_train,'b.');
axis tight
hold on
plot([1 7e4],[predict(1).thres_train.up predict(1).thres_train.up],'k-','LineWidth',1.5);
set(gca,'FontSize',16);
xlabel('points on the grid');
ylabel('posterior mean');

% ---------------
plot(predict(1).est_train,'b.');
axis tight
hold on
plot(predict(1).est_test,'r.');
plot([1 7e4],[predict(1).thres_train.up predict(1).thres_train.up],'k-','LineWidth',1.5);
plot([1 7e4],[predict(1).thres_test predict(1).thres_test],'k--','LineWidth',1.5);
set(gca,'FontSize',16);
xlabel('points on the grid');
ylabel('posterior mean');


% ----------------
field = reshape(predict(1).est_train,option.gridsize,option.gridsize,option.gridsize);


% ---------- Create contour plot include +std and -std
z_line = unique(predict.S_est(:,end),'rows','stable');
index = [5 10 15 20 25];
slice_list = z_line(index);
hold on
rec = [30 30;140 30;140 100;30 100;30 30];
for i=1:size(slice_list,1)
	ix = find(predict.S_est(:,3)==slice_list(i));
	xy = predict.S_est(ix,1:2);
	xy = boundary_select(xy);
	z = slice_list(i)*ones(size(xy,1),1);
	plot3(xy(:,1),xy(:,2),z,'r-','LineWidth',2);
	plot3(rec(:,1),rec(:,2),slice_list(i)*ones(size(rec,1),1),'k','LineWidth',1);
	
	ix = find(predict.S_est_up(:,3)==slice_list(i));
	xy = predict.S_est_up(ix,1:2);
	xy = boundary_select(xy);
	z = slice_list(i)*ones(size(xy,1),1);
	plot3(xy(:,1),xy(:,2),z,'b-.','LineWidth',2);
	
	ix = find(predict.S_est_down(:,3)==slice_list(i));
	xy = predict.S_est_down(ix,1:2);
	xy = boundary_select(xy);
	z = slice_list(i)*ones(size(xy,1),1);
	plot3(xy(:,1),xy(:,2),z,'g--','LineWidth',2);
	
end
hold off
set(gca,'Fontsize',16);

% --------- Print result to screen
hold on
fprintf('name band_f band_t band_x band_y band_z Haust_dist\n');
for i=1:size(predict,2)
	fprintf('%s ',predict(i).name);
	fprintf('%.1f ',predict(i).band_f);
	fprintf('%.1f ',predict(i).band_t);
	fprintf('%.1f ',predict(i).band_x);
	fprintf('%.1f ',predict(i).band_y);
	fprintf('%.1f ',predict(i).band_z);
	fprintf('%.1f ',predict(i).Haus_dist);
	fprintf('\n');
	plot(Pat_list(i).numScan,predict(i).Haus_dist,'ks','LineWidth',2);
	text(Pat_list(i).numScan+0.2,predict(i).Haus_dist+0.2,Pat_list(i).name(2:end));
	error(i) = predict(i).Haus_dist;
end
fprintf('Mean of Haus dist: %f\n',mean(error));
fprintf('Std of Haus dist: %f\n',sqrt(var(error)));
xlim([2 8]);
xlabel('No of scans');
ylabel('Hausdoff distance');
box on
set(gca,'FontSize',16);



