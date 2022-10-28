% File Name: explore.m
% Author: Floris Vleugels
% Contact: f.vleugels@student.maastrichtuniversity.nl
clc;clear; 
%% Loading the data
x= readtable('data_640_validated.csv'); % Ensure the data is in your working directory. 
desc= readtable('Data description_validated.xlsx');
% Remove some useless columns for analysis
x(:,1:2)=[]; %participant number and time of the interview, not relevant for what I am doing.
x.D7 = []; % Open answer question with no high count answers so leaving this out for now, 
% would just add extra variance to the data even though the open asnwers
% have similiar responses.
%% Fixing the categories for some variables
% Converting variables to categoricals (only converting the non numerical
% ones here, so its easier to perform other processing steps, they will be
% encoded to numerical values later on)
x = convertvars(x,@iscellstr,"string");

for i= 1: size(x,2)
    idx= isstring(x.(i));
    if idx== 1
        x.(i)= categorical(x.(i));
    else
       %x.(i)= categorical(x.(i));
       % do nothing
    end
end

summ= summary(x);

% Fixing A1_1, had a lot of 'duplicate' categories, so looping over all of
% them and assigning to a shared category.
id= categories(x.A1_1);

id(1,2)= {'Missing'};
id(2,2)= {'African American'};
id(3:10,2)= {'American'};
id(11:15,2)= id(11:15,1);
id(16:19,2)= {'British'};
id(20:21,2)= {'Canadian'};
id(22,2)= {'Spanish'};
id(23,2)= {'American'};
id(24:25,2)= {'Chinese'};
id(26,2)= {'American'};
id(27:29,2)= id(27:29,1);
id(30:31,2)= {'British'};
id(32:35,2)= {'Filipino'};
id(36,2)= {'French'};
id(37,2)= {'Missing'};
id(38:39,2)= {'German'};
id(40:46,2)= id(40:46,1);
id(47,2)= {'American'};
id(48,2)= {'Latina'};
id(49,2)= {'American'};
id(50:52,2)= {'Mixed'};
id(53,2)= id(53,1);
id(54:55,2)= {'New Zealander'};
id(56,2)= {'American'};
id(57,2)= {'Norwegian'};
id(58,2)= {'Filipino'};
id(59,2)= {'American'};
id(60,2)= {'Canadian'};
id(61,2)= {'Scottish'};
id(62:63,2)= {'Singaporean'};
id(64,2)= {'South Korean'};
id(65,2)= {'Taiwanese'};
id(66,2)= {'American'};
id(67,2)= {'British'};
id(68:75,2)= {'American'};
id(76:81,2)= {'Vietnamese'};
id(82:83,2)= {'Welsh'};
id(84:85,2)= {'American'};
id(86:87,2)= {'British'};
id(88,2)= {'American'};
id(89,2)= {'Canadian'};
id(90,2)= {'Filipino'};
id(91,2)= {'Indonesia'};
id(92,2)= {'American'};
id(93,2)= {'British'};
id(94:96,2)= {'American'};

for i= 1:length(id)
    x.A1_1(x.A1_1== id(i,1)) = id(i,2);
    disp(i)
end

x.A1_1(x.A1_1== {'Everyday'})= mode(x.A1_1); % very strange answer imputing 
% it to the mode. RUN THIS LINE MANUALLY (seems to get skipped if you run the
% entire script)

x.A1_1= removecats(x.A1_1); %removing the left over empty cats.

% Fixing D2, a lot of unique answers, and a small number of answers with a
% large number of counts. So reducing the categories to the most counted
% ones plus one category for the rest. But this is not really a good
% approach for this column, but fixing it properly would take to much time
% for now. 
id2= categories(x.D2);
counts =summ.D2.Counts;

for i= 1:length(id2)
    if counts(i) < mean(counts) 
        x.D2(x.D2 == id2(i,1)) = {'Other'};
    else 
        % do nothing
    end
end

x.D2= removecats(x.D2); %removing the left over empty cats.

% Fixing D4, average time played a day over the last 2 weeks in hours,
% people are not answering this consistently so have to fix it. 
id4= categories(x.D4);

id4(1,2)= {'<=2 hours'};
id4(2:11,2)= {'10+ hours'};
id4(12,2)= {'2-5 hours'};
id4(13:16,2)= {'10+ hours'};
id4(17:18,2)= {'2-5 hours'};
id4(19:21,2)= {'<=2 hours'};
id4(22:29,2)= {'2-5 hours'};
id4(30,2)= {'5-10 hours'};
id4(31:35,2)= {'2-5 hours'};
id4(36:42,2)= {'5-10 hours'};
id4(43:47,2)= {'2-5 hours'};
id4(48:73,2)= {'5-10 hours'};
id4(74,2)= {'<=2 hours'};
id4(75:82,2)= {'5-10 hours'};
id4(83:87,2)= {'2-5 hours'};
id4(88:91,2)= {'5-10 hours'};
id4(92,2)= {'0 hours'};
id4(93:94,2)= {'2-5 hours'};
id4(95,2)= {'5-10 hours'};
id4(96:98,2)= {'2-5 hours'};
id4(99,2)= {'5-10 hours'};
id4(100,2)= {'2-5 hours'};
id4(101:102,2)= {'5-10 hours'};

for i= 1:length(id4)
    x.D4(x.D4== id4(i,1)) = id4(i,2);
    disp(i)
end

x.D4= removecats(x.D4); %removing the left over empty cats.

% Fixing D6, same approach and motivation as for D2
id6= categories(x.D6);
counts6 =summ.D6.Counts;

for i= 1:length(id6)
    if counts6(i) < mean(counts6) 
        x.D6(x.D6 == id6(i,1)) = {'Other'};
    else 
        % do nothing
    end
end

x.D6= removecats(x.D6); %removing the left over empty cats.
%% Outliers
% Performing isolation forest later showed no strong outliers by
% looking at the anomaly scores. Therefore, I will not be removing any
% samples ( no outliers could be seen on PCA plots either)
%% Fixing missing values
% Finding the columns and positions of the missing values, and filling in
% the value from the excel sheet, or imputing missing values. Would prefer
% knn imputation but dont have time to implement it
for i= 1:width(x)
    disp(i)
    find(ismissing(x(:,i)))
end

% Column 6 had some values withstring component so imported to matlab as NaN
x(639,6)= table(30); 
x(640,6)= table(28); 

% Colum 28 had some missing values, imputing them to the mode of the column 
j= find(ismissing(x(:,28)));
for i= 1:length(j)
    x(j(i),28)= table(mode(x.D1));
end

% Column 29 had some missing values, imputing them to the mode of the column 
j= find(ismissing(x(:,29)));
for i= 1:length(j)
    x(j(i),29)= table(mode(x.D2));
end

% Column 30 had one missing value, imputing in same way
x(444,30)= table(mode(x.D3));

%Column 1 too (I called the countries that had weird answers missing
%earlier)
x.A1_1(x.A1_1=={'Missing'})= mode(x.D3);
%% Simple Visualisation of the data
% Some Histograms 
subplot(2,2,1);
histogram(x.A1_1);title("Participant Nationality");ylabel("Frequency");
subplot(2,2,2);
histogram(x.A1_2);title("Participant Continent");ylabel("Frequency");
subplot(2,2,3);
histogram(x.A2);title("Participant Sex");ylabel("Frequency");
subplot(2,2,4);
histogram(x.A4);title("'Do you have a pet or a garden at home?'");ylabel("Frequency");
% Boxplots 
figure;
boxplot(x.A5,x.A1_2);ylabel("Age (years)");title("Participants Age in years");

%% Splitting the data 
% Removing the columns that stored participant info and were not
% participant answers to the survey, as Im only interested in using the
% answers to the questions to perform PCA and URF etc. 
meta= x(:,1:12);
x(:,1:12)= [];

%% Exporting the data to xlsx for other steps in python
% (I have mostly abandoned the python part to focus on this, as it was incorrect anyway. 
% But leaving it in for myself)
%filename = 'Data_clean.xlsx';
%writetable(x,filename,'Sheet',1)
%% Unsupervised Random forest
% Encode data to numerical value
x_num= zeros(640,81);
for j= 1:width(x)
    b= unique(x.(j));
        for i = 1:height(b)
            x_num((x.(j) == b(i)),j) = i;
        end
end
% Encode meta data part to numerical (for plotting purposes later)
meta_num= zeros(640,12);
for j= 1:width(meta)
    c= unique(meta.(j));
        for i = 1:height(c)
            meta_num((meta.(j) == c(i)),j) = i;
        end
end

% Turn the numerical data into categorical 
x_num_cat= x_num;
x_num_cat= array2table(x_num);

for i= 1: size(x_num_cat,2)
    x_num_cat.(i)= categorical(x_num_cat.(i));
end

% Unsupervised Random Forest (URF), and obtaining the proximities of the
% leafs, and creating y label for real data
y(1:size(x,1),1)=0;
[b_tree_3_classes22,proximity_notTransformed]=unsupervisedRF2(100,x_num_cat,y); % takes a while with 1000 trees

% Double centering (substract row and column mean but add back overall
% mean)
scaled= proximity_notTransformed - repmat(mean(proximity_notTransformed),size(x,1),1)- repmat(mean(proximity_notTransformed,2),1,size(x,1))...
    + repmat(mean(mean(proximity_notTransformed)),size(x,1),size(x,1));
%% Perform PCA on the scaled proximities from the URF 
% Peform PCA on the Double centered proximities
[coeff,score,latent,~,explained] = pca(scaled);

% Plot the scores 
figure;
scatter3(score((meta.A2=='Male'),1),score((meta.A2=='Male'),2),score((meta.A2=='Male'),3),20); xlabel("PC1 (" + explained(1)+"%)"); ylabel("PC2 (" + explained(2)+"%)");zlabel("PC3 (" + explained(3)+"%)");title('URF PCA');
hold on;
scatter3(score((meta.A2=='Female'),1),score((meta.A2=='Female'),2),score((meta.A2=='Female'),3),20);legend("Male","Female",'Location','northeast')

% Plotting the proximities (unclustered)
figure;
imagesc(scaled), colormap(hot)
xlabel('First Sample No.'); ylabel('Second Sample No.');title('Proximity between pairs of URF samples after double centering')
colorbar

figure;
imagesc(proximity_notTransformed),colormap(hot)
xlabel('First Sample No.'); ylabel('Second Sample No.');title('Proximity between pairs of URF samples before double centering')
colorbar

% Feature importance URF (kind of no meaning but was curious)
top5= maxk(b_tree_3_classes22.OOBPermutedPredictorDeltaError,5); % top 5 important features for the trees

for i=1:5
    nma(i)= find(b_tree_3_classes22.OOBPermutedPredictorDeltaError==top5(i));
    name(i,:)= b_tree_3_classes22.PredictorNames(nma(i));
end
%% Perform Clustering and colour PCA based on the clusters
% Euclidian distance, ward linkage 
Z=linkage(scaled, 'ward');
T = cluster(Z,'maxclust',3);
cutoff = median([Z(end-2,3) Z(end-1,3)]);
dendrogram(Z,'ColorThreshold',cutoff)
crosstab(T, meta.A2) % Shows the males and females in each cluster

figure;
scatter3(score((T==1),1),score((T==1),2),score((T==1),3),20); xlabel("PC1 (" + explained(1)+"%)"); ylabel("PC2 (" + explained(2)+"%)");zlabel("PC3 (" + explained(3)+"%)");title('URF PCA');hold on;
scatter3(score((T==2),1),score((T==2),2),score((T==2),3),20);
scatter3(score((T==3),1),score((T==3),2),score((T==3),3),20);legend("Cluster 1","Cluster 2","Cluster 3",'Location','northeast')
%% Plotting the proximities with cluster structure
% fix the cluster linkages
cg= clustergram(scaled,'linkage','ward');
titlexd= addTitle(cg,'URF Clustered Proximities','Color','black');
addXLabel(cg,'Participants','FontSize',24);
addYLabel(cg,'Participants','FontSize',24);
%% Isolation Forest and plotting the anomaly scores
% Isolation forest
[forest,tf,anomaly] = iforest(x, 'NumLearners',1000);
outlier= isanomaly(forest,x);
% Distribution of anomaly scores
figure;
histogram(anomaly);xlabel("Anomaly Score");ylabel("Frequency");title("Isolation Forest Anomaly Scores");
xline(forest.ScoreThreshold,"r-",join(["Threshold" forest.ScoreThreshold]));
%% Pseudo sampling technique to create biplots for the URF PCA
% To note, I think there was some issues with the function since it wasnt
% working on the encoded categorical data, even though it was numerical.
% Also some manual inputs are required on the command window after the RFPS
% function. 
[b_tree_3_classes22,proximity_notTransformed]=unsupervisedRF2(100,x_num,y);
rfps(x_num,b_tree_3_classes22,20,proximity_notTransformed,1,2,meta_num(:,3),['Male','Female'])

% END 