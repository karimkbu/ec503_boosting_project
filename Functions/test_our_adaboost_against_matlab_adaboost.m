% This script runs MATLAB's built in AdaBoost through fitcensemble() and
% our AdaBoost function on three synthetic datasets and compares the
% test/train error rates.
Ts = [1,3,5,7,10,20,50,100,200];
clear
%% Decision Stump Separable Dataset
main_dir = dir('..');
main_dir = main_dir.folder;
data_dir = strcat(main_dir,  '\Datasets\synthetic\data_linear.mat');
load(data_dir); data_linear = dataset'; clear dataset;
% figure(1); gscatter(data_linear(:,1),data_linear(:,2),data_linear(:,3),'rb','+o');

%% Circular Dataset
main_dir = dir('..');
main_dir = main_dir.folder;
data_dir = strcat(main_dir,  '\Datasets\synthetic\circular_dataset.mat');
load(data_dir);
% figure(2); gscatter(data_circular(:,1),data_circular(:,2),data_circular(:,3),'rb','+o');

%% Linearaly Separable Not By Stump Dataset
main_dir = dir('..');
main_dir = main_dir.folder;
data_dir = strcat(main_dir,  '\Datasets\synthetic\linearly_separable_not_by_stump.mat');
load(data_dir); data_tilted = data; clear data;
% figure(3); gscatter(data_tilted(:,1),data_tilted(:,2),data_tilted(:,3),'rb','+o');

datasets = cell(3, 1);
datasets{1} = data_linear;
datasets{2} = data_circular;
datasets{3} = data_tilted;

dataset_classifiers = cell(3, 1);

dense_grids = cell(3, 1);
for grid_num = 1:2
    x1_min = min(datasets{grid_num}(:, 1));
    x1_max = max(datasets{grid_num}(:, 1));
    x2_min = min(datasets{grid_num}(:, 2));
    x2_max = max(datasets{grid_num}(:, 2));
    row_num = 1;
    for x1_coord = x1_min:.01:x1_max
        for x2_coord = x2_min:.01:x2_max
            dense_grids{grid_num}(row_num, :) = [x1_coord, x2_coord, 0];
            row_num = row_num+1;
        end       
    end
end

grid_num = 3;
x1_min = min(datasets{grid_num}(:, 1));
x1_max = max(datasets{grid_num}(:, 1));
x2_min = min(datasets{grid_num}(:, 2));
x2_max = max(datasets{grid_num}(:, 2));
row_num = 1;
for x1_coord = x1_min:1:x1_max
    for x2_coord = x2_min:1:x2_max
        dense_grids{grid_num}(row_num, :) = [x1_coord, x2_coord, 0];
        row_num = row_num+1;
    end       
end

%%

for dataset_num = 1:3
%    
       Ts = [1,3,5,7,10,20,50,100,200,500,1000];
       n_Ts = numel(Ts);
       for j = 1:n_Ts
%        dense_grid{dataset_num}(:, 4) = zeros(size(dense_grid{dataset_num}(:, 1), 1));
           data = datasets{dataset_num};
           feature_col_num = size(data, 2) - 1;

           n = size(data, 1);
           randOrder = randperm(n);
           train_end = round(.8*n);
           data_train = datasets{dataset_num}(randOrder(1:train_end),:);
           data_test = datasets{dataset_num}(randOrder(train_end+1:n),:);
           n_train = size(data_train, 1);
           t = templateTree('MaxNumSplits', 1);
           ens = fitcensemble(data_train(:, 1:end-1), data_train(:, end), 'Method', 'AdaBoostM1', ...
           'NumLearningCycles',Ts(j),'Learners',t);
           data_test(:, 4) = predict(ens,data_test(:, 1:2));
           data_train(:, 4) = predict(ens,data_train(:, 1:2));
           n_test = size(data_test, 1);
           train_ccrs(dataset_num, j) = sum(data_train(:, 3) == data_train(:, 4))/n_train;
           test_ccrs(dataset_num, j) = sum(data_test(:, 3) == data_test(:, 4))/n_test;
           fprintf('%d, %d\n', dataset_num, Ts(j));
           dense_grids{dataset_num}(:, 3) = predict(ens,dense_grids{dataset_num}(:, 1:2));
       end
%    end
end

%%
names = {"Stump Separable", "Circular", "Tilted"};
for i = 1:3
    figure(i)
    gscatter(dense_grids{i}(:, 1), dense_grids{i}(:, 2), dense_grids{i}(:, 3), 'rb')
    hold on
    gscatter(datasets{i}(:, 1), datasets{i}(:, 2), datasets{i}(:, 3), 'rb')
    title_str = "Decision Boundary of MATLAB''s Built-in AdaBoost " + "(" + names{i} + ")";
    title(title_str)
    xlabel('X1')
    ylabel('X2')
    legend('1', '-1')
    figure(i+3)
    semilogx(Ts,train_ccrs(i,:),'*-'); xlabel('T'); ylabel('CCR');
    hold on;
    semilogx(Ts,test_ccrs(i, :),'*-');
    legend('Train CCRs', 'Test CCRs','Location','east');
    title_str = "Dataset " + names{i} + " Train/Test Error (MATLAB AdaBoost)";
    title(title_str)
    xlabel('T')
    ylabel('Error')
    legend('Train', 'Test')
end



