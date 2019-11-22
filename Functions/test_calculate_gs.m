% test_calculate_gs

load('C:\Users\jsnea\Desktop\EC503\Project\ec503_boosting_project\Datasets\synthetic\data_linear.mat');

data = dataset';
all_gs = calculate_gs(data);

thresh1_x2 = linspace(min(data(:, 2)), max(data(:, 2)), 100)';
thresh2_x1 = linspace(min(data(:, 1)), max(data(:, 1)), 100)';

thresh1 = all_gs(1, 1).*ones(100, 1);
thresh2 = all_gs(2, 1).*ones(100, 1);

% figure(1)
% gscatter(data(:, 1), data(:, 2), data(:, 3), 'rb')
% gscatter(thresh1, thresh1_x2, data(:, 3), 'k')
% gscatter(thresh2, thresh2_x1, data(:, 3), 'k')
