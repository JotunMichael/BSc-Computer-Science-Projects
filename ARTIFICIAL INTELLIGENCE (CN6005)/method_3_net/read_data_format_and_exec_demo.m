% Read Wisconsin Breast Cancer database
% import Data
clear; clc; close all;

fid = fopen('data.csv','r');
Data = textscan(fid, ['%d,%[^,],',repmat('%f,',1,29),'%f\n'], 'HeaderLines',1);
fclose(fid);

n = length(Data);       % number of features + target
n = n-2;                % ignore first two attributes/Features (ID of patient, target of cancer Type)
P = length(Data{1});    % number of patterns/samples
%% prepare Data sets
x = zeros(P,n);
for pat=1:P
    for i=1:n
        x(pat,i) = double(Data{i+2}(pat)); % fill row by row entering Data cell variable
    end
end

%t = zeros(size(x,1),2); 
t = zeros(1,P); % targets % use this if uncommented line 21,24,27,31 and 20,25,28 commented or reverse it for the other way
for i=1:P
    if char(Data{2}(i)) == 'M'
        t(i) = 1; % Malignant
        %t(i,:) = [1 0];
    else
        t(i) = 0; %Benign ###### ----> cant use -1 why? i use [1] or [0] output instead of [1 0] [0 1] but cant [1] [-1]
        %t(i,:) = [0 1];
    end
end
t = t'; % or t = t.';

%% storage
%save('wdbc.mat', 'x', 't');
%load ('wdbc.mat');

%% Prepare Neural Network
hidden_layers_neurons = [10];
training_function = 'traingdx'; %trainscg trainrp  traingdx
net = patternnet(hidden_layers_neurons); %feedforwardnet
%net = setwb(net,rand(55,1));
%net = setwb(net,1);
%net.IW{1,1}
%net.b{1}
%net.b = [2 1; 1];
%view(net);
%net.divideFcn = 'dividerand';
net.trainFcn = training_function;
%net.trainParam.goal = 1e-2;
net.trainParam.epochs = 1500;
net.trainParam.show = 1;
net.performFcn = 'mse';

net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

net.trainParam.max_fail = 10;

% traingdx only
net.trainParam.lr = 0.1; %0.1 0.4;
net.trainParam.mc = 0.4; %0.4 0.9;

net = init(net);

x = x(1:569,1:10);
 x = x';
 t=t';
[net,tr] = train(net, x, t);

%% Average after 100 trains
outputs = net(x); % target expected - output that got from test data
%myGhostFigure = figure("Visible",false); % kane edw subplot? se figure opws sto libsvm? gia oxi draw?
confmatrix = figure, plotconfusion(t, outputs);
%close(findall(groot,'Type','figure'))
shoi='';
shoi_n=0;
%shoi = confmatrix.CurrentAxes.Children(4).String;
%shoi = regexprep(shoi,'[^?:\.A-Za-z1-9]',''); % keep only numbers with dot but not 0
%shoi_n = str2double(shoi); %shoi_n = str2num(['uint8(',shoi,')']);

for i=1:50
%confmatrix = plotconfusion(t, outputs);
outputs = net(x);
shoi = confmatrix.CurrentAxes.Children(4).String;
shoi = regexprep(shoi,'[^?:\.A-Za-z1-9]','');
shoi_n = shoi_n + str2double(shoi);
if (i~=50)
    %close(findall(groot,'Type','figure'))
end
end
shoi_n = shoi_n/100;

%% figures
%figure, plotperform(tr);
%figure, plotconfusion(t, outputs);
[c,cm] = confusion(t,outputs);
fprintf('Percentage Correct Classification   : %f%%\n', 100*(1-c));
fprintf('Percentage Incorrect Classification : %f%%\n', 100*c);
%plotroc(t,outputs);

%% CALCULATE MSE
Nepochs = tr.epoch(end); % Total epochs iteration of net train
N = length(x); % Proccessed input Data Length
for i_epoch = 1:Nepochs % iterations run (total number of epochs trained)
    for i_mse = 1:N %569
         mse(1) = mse(1) + mean((t(i_mse)-outputs(i_mse)).^2); % rmse or mse? % add in first col the previous mse + next the row-by-row actual target from Data - Data from output you got instead
    end
    mse(1) = mse(1)/N;
end

for i = 1:N-1
    %mse(i) = mean((y(i)-x(i)).^2)
    mse_graph(i) = mean((t(i)-outputs(i)).^2);
end
%plot(abs(mse_graph));
