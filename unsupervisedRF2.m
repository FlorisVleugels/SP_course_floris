function [b_tree_3_classes2,proximity_notTransformed]=unsupervisedRF2(num_trees,real_data,class)

%% the input of the function is data matrix(real_data) and original class (class) vector and number of trees (num_trees)
%% output is Random Forest tree, pca scores (pcaParams) and proximity matrix
%% unsupervised RF

%%permute the columns of the real data
% real_data=Data_center([trial0;trial60;trial90;trial120;trial240;trial360;trial480],:);
[r,c]=size(real_data);

% max_vars = max(real_data, [], 1); % Maximum of each column 

% min_vars = min(real_data, [], 1); % Minimum of each column 
% range_vars = max_vars - min_vars;
% mean_var=mean(real_data);
% artificial_data = zeros(r,c);
% % r = a + (b-a).*rand(N,1);
% 
% for var_nr = 1:c
%     max_var = max_vars(var_nr);
%     min_var = min_vars(var_nr);
% %     range_var = range_vars(var_nr);
%     
%     pseuso_var = min_var+(max_var-min_var).*rand(r,1);
% %     [min_var:(1/(r-1))*range_var:max_var]';
%     
%     artificial_data(:,var_nr) = pseuso_var;
% end
% I create here artificial data by permuting the values of each variable
% between different samples
options = statset('UseParallel', 'Always');
artificial_data=[];
for i=1:c
    bla=randperm(r);
   artificial_data=[artificial_data,real_data(bla,i)];
end

Data_for_RF=[real_data;artificial_data];
class_data_RF=[ones(r,1)*1;ones(r,1)*2];
% [Data_for_RF]=zscore(Data_for_RF);
%%RF --> this part is implemented in Matlab. I use here 2000 trees and
%%randomly samplesquare root of nr of variables
tic,b_tree_3_classes2 = TreeBagger(num_trees,Data_for_RF,class_data_RF,'oobpred','on','Surrogate', 'on', 'OOBVarImp','on','Method','classification','Options',options,'NVarToSample',round(sqrt(c))),toc;
%figure,plot(b_tree_3_classes2.oobError);%% here I plot out-off-bag error
b_tree_3_classes2=fillProximities(b_tree_3_classes2); %% I create the proximity matrix within Random Forest

proximity_notTransformed = b_tree_3_classes2.Proximity(1:r,1:r); %%%%% MY ADDITION SO I CAN GET THE NON_TRANSFORMED PROXIMITY MATRIX %%%%%

%proximity_realdata=(b_tree_3_classes2.Proximity(1:r,1:r));
%[pcaParams,s,v,d,pr]=PCAszybka(doublecentering(1-b_tree_3_classes2.Proximity(1:r,1:r))); %%PCA analysis performed on proximity matrix but only containing the real data
%figure,gscatter(pcaParams(:,1),pcaParams(:,2),class) %% I plot the outcomse of PCA analysis --> PCA scor eplot and I colorcode the samples with respect to class membership