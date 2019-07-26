function [model_slg,model_ll,model_llg,model_lllg] = generatesvr(dssFile, nodes, elements)

addpath('libsvm-3.21/matlab'); % Agrego el path de libsvm
addpath('export_fig/');

% -------------- Inicializar variables ----------------------

% load train
trainX = load(fullfile('Data',dssFile,'trainX'));
trainX = trainX.trainX;
trainY = load(fullfile('Data',dssFile,'trainY'));
trainY = trainY.trainY;
trainfaultinfo = load(fullfile('Data',dssFile,'trainfaultinfo'));
trainfaultinfo = trainfaultinfo.trainfaultinfo;

% load test
testX = load(fullfile('Data',dssFile,'testX'));
testX = testX.testX;
testY = load(fullfile('Data',dssFile,'testY'));
testY = testY.testY;
testfaultinfo = load(fullfile('Data',dssFile,'testfaultinfo'));
testfaultinfo = testfaultinfo.testfaultinfo;
    
% load cab
cab = load(fullfile('Data',dssFile,'cabecera'));
cab = cab.cab;

% ------------- Obtener datos ------------------------------

columns = [];
for node = nodes
    columns = [columns, find(strcmp(cab, node))];
end;

for element = elements
    columns = [columns, find(strcmp(cab, element))];
end;

trainX = trainX(:,columns);
trainX = [trainX trainY];
testX = testX(:,columns);
testX = [testX testY];

% ------------- Entrenar --------------------------------------

% [trainX, minimums, ranges] = scale_data(trainX);
% testX = (testX - repmat(minimums, size(testX, 1), 1)) ./ repmat(ranges, size(testX, 1), 1);

disp('------------------------------SLG----------------------------------')

trainX_slg = trainX(trainfaultinfo(:,7) == 1,:);
testX_slg = testX(testfaultinfo(:,7) == 1,:);

trainY_slg = trainfaultinfo(trainfaultinfo(:,7) == 1,8);
testY_slg = testfaultinfo(testfaultinfo(:,7) == 1,8);

disp('-------------');
disp('Training.....');
disp('-------------');

%[bestc,bestg,bestp] = cross_validation_regresion(trainX_slg, trainY_slg, 1, 14, -7, -1, -7, -1);
%cmd = ['-s 3 -c ', num2str(bestc), ' -g ', num2str(bestg), ' -p ', num2str(bestp)];
%model_slg = svmtrain(trainY_slg, sparse(trainX_slg), cmd);

model_slg = svmtrain(trainY_slg, sparse(trainX_slg), '-s 3 -c 16384 -g 0.5 -e 0.5');

disp('-------------')
disp('Testing.....');
disp('-------------');

tic;
%ty = testY_slg(1);
%tx = sparse(testX_slg(1,:));
[pred, ac, decv] = svmpredict(ty, tx, model_slg);
toc;

% aux = pred - testY_slg;
% pred(abs(aux)>1) = 0;
immse(testY_slg,pred)
mae(testY_slg-pred);

figure('rend','painters','pos',[600 600 1000 180])

test_slg = testY(testfaultinfo(:,7) == 1,:);
[ii,~,kk]=unique(test_slg,'rows','stable');
out=[ii,accumarray(kk,1)];
vertLine = cumsum(accumarray(unique(test_slg),out(:,2)));

plot(1:vertLine(end-1),testY_slg(1:vertLine(end-1)), 'LineWidth', 3, 'color', [0.75,0.75,0.75]); hold on;
plot(1:vertLine(end-1),pred(1:vertLine(end-1)), 'color', 'k');
save('testY_slg.mat','testY_slg');
save('pred_slg.mat','pred');
xlabel('Samples')
ylabel('Distance')
l = legend('Real Distance','Estimated Distance');
rect = [0.80, 0.45, .05, .05];
set(l, 'Position', rect)

vertLine = vertLine(1:end-1);
x=[vertLine,vertLine];
y=[0,6000];
plot(x,y,'--','color',[0.75,0.75,0.75])
drawnow

textLines = unique(cab(find(not(cellfun('isempty',strfind(cab,'Line'))))),'stable');
textLines = textLines(1:end-1);
text((vertLine + [0;vertLine(1:end-1)])/2,ones(size(vertLine))*5000,textLines,'HorizontalAlignment','right','Rotation',90);

export_fig('slg_regression.eps','-transparent','-eps','-painters');

disp('------------------------------LL----------------------------------')

trainX_ll = trainX(trainfaultinfo(:,7) == 2,:);
testX_ll = testX(testfaultinfo(:,7) == 2,:);

trainY_ll = trainfaultinfo(trainfaultinfo(:,7) == 2,8);
testY_ll = testfaultinfo(testfaultinfo(:,7) == 2,8);

disp('-------------')
disp('Training.....');
disp('-------------');

%[bestc,bestg,bestp] = cross_validation_regresion(trainX_ll, trainY_ll, 1, 14, -7, -1, -7, -1);
%cmd = ['-s 3 -c ', num2str(bestc), ' -g ', num2str(bestg), ' -p ', num2str(bestp)];
%model_ll = svmtrain(trainY_ll, sparse(trainX_ll), cmd);

model_ll = svmtrain(trainY_ll, sparse(trainX_ll), '-s 3 -c 16384 -g 0.125 -e 0.007');

disp('-------------')
disp('Testing.....');
disp('-------------');
[pred, ac, decv] = svmpredict(testY_ll, sparse(testX_ll), model_ll);

figure('rend','painters','pos',[600 600 1000 180])

test_ll = testY(testfaultinfo(:,7) == 2,:);
[ii,~,kk]=unique(test_ll,'rows','stable');
out=[ii,accumarray(kk,1)];
vertLine = cumsum(out(:,2));

%subplot(4, 1, 2)
plot(1:vertLine(end-1),testY_ll(1:vertLine(end-1)), 'LineWidth', 3, 'color', [0.75,0.75,0.75]); hold on;
plot(1:vertLine(end-1),pred(1:vertLine(end-1)), 'color', 'k');
save('testY_ll.mat','testY_ll');
save('pred_ll.mat','pred');
xlabel('Samples')
ylabel('Distance')
l = legend('Real Distance','Estimated Distance');
rect = [0.80, 0.45, .05, .05];
set(l, 'Position', rect)

vertLine = vertLine(1:end-1);
x=[vertLine,vertLine];
y=[0,6000];
plot(x,y,'--','color',[0.75,0.75,0.75])
drawnow

textLines = unique(cab(find(not(cellfun('isempty',strfind(cab,'Line'))))),'stable');
textLines = textLines(1:end-3);
text((vertLine + [0;vertLine(1:end-1)])/2,ones(size(vertLine))*5000,textLines,'HorizontalAlignment','right','Rotation',90);

export_fig('ll_regression.eps','-transparent','-eps','-painters');

disp('------------------------------LLG----------------------------------')

trainX_llg = trainX(trainfaultinfo(:,7) == 3,:);
testX_llg = testX(testfaultinfo(:,7) == 3,:);

trainY_llg = trainfaultinfo(trainfaultinfo(:,7) == 3,8);
testY_llg = testfaultinfo(testfaultinfo(:,7) == 3,8);

disp('-------------')
disp('Training.....');
disp('-------------');

%[bestc,bestg,bestp] = cross_validation_regresion(trainX_llg, trainY_llg, 1, 14, -7, -1, -7, -1);
%cmd = ['-s 3 -c ', num2str(bestc), ' -g ', num2str(bestg), ' -p ', num2str(bestp)];
%model_llg = svmtrain(trainY_llg, sparse(trainX_llg), cmd);

model_llg = svmtrain(trainY_llg, sparse(trainX_llg), '-s 3 -c 16384 -g 0.5 -e 0.03125');

disp('-------------')
disp('Testing.....');
disp('-------------');
[pred, ac, decv] = svmpredict(testY_llg, sparse(testX_llg), model_llg);

figure('rend','painters','pos',[600 600 1000 180])

test_llg = testY(testfaultinfo(:,7) == 3,:);
[ii,~,kk]=unique(test_llg,'rows','stable');
out=[ii,accumarray(kk,1)];
vertLine = cumsum(out(:,2));

plot(1:vertLine(end-1),testY_llg(1:vertLine(end-1)), 'LineWidth', 3, 'color', [0.75,0.75,0.75]); hold on;
plot(1:vertLine(end-1),pred(1:vertLine(end-1)), 'color', 'k');
save('testY_llg.mat','testY_llg');
save('pred_llg.mat','pred');
xlabel('Samples')
ylabel('Distance')
l = legend('Real Distance','Estimated Distance');
rect = [0.80, 0.45, .05, .05];
set(l, 'Position', rect)

vertLine = vertLine(1:end-1);
x=[vertLine,vertLine];
y=[0,6000];
plot(x,y,'--','color',[0.75,0.75,0.75])
drawnow

textLines = unique(cab(find(not(cellfun('isempty',strfind(cab,'Line'))))),'stable');
textLines = textLines(1:end-3);
text((vertLine + [0;vertLine(1:end-1)])/2,ones(size(vertLine))*5000,textLines,'HorizontalAlignment','right','Rotation',90);

export_fig('llg_regression.eps','-transparent','-eps','-painters');

disp('------------------------------LLLG----------------------------------')

trainX_lllg = trainX(trainfaultinfo(:,7) == 4,:);
testX_lllg = testX(testfaultinfo(:,7) == 4,:);

trainY_lllg = trainfaultinfo(trainfaultinfo(:,7) == 4,8);
testY_lllg = testfaultinfo(testfaultinfo(:,7) == 4,8);

disp('-------------')
disp('Training.....');
disp('-------------');

%[bestc,bestg,bestp] = cross_validation_regresion(trainX_lllg, trainY_lllg, 1, 14, -7, -1, -7, -1);
%cmd = ['-s 3 -c ', num2str(bestc), ' -g ', num2str(bestg), ' -p ', num2str(bestp)];
%model_lllg = svmtrain(trainY_lllg, sparse(trainX_lllg), cmd);

model_lllg = svmtrain(trainY_lllg, sparse(trainX_lllg), '-s 3 -c 16384 -g 0.5 -e 0.5');

disp('-------------')
disp('Testing.....');
disp('-------------');
[pred, ac, decv] = svmpredict(testY_lllg, sparse(testX_lllg), model_lllg);

figure('rend','painters','pos',[600 600 1000 180])

test_lllg = testY(testfaultinfo(:,7) == 4,:);
[ii,~,kk]=unique(test_lllg,'rows','stable');
out=[ii,accumarray(kk,1)];
vertLine = cumsum(out(:,2));

plot(1:vertLine(end-1),testY_lllg(1:vertLine(end-1)), 'LineWidth', 3, 'color', [0.75,0.75,0.75]); hold on;
plot(1:vertLine(end-1),pred(1:vertLine(end-1)), 'color', 'k');
save('testY_lllg.mat','testY_lllg');
save('pred_lllg.mat','pred');

xlabel('Samples')
ylabel('Distance')
l = legend('Real Distance','Estimated Distance');
rect = [0.80, 0.45, .05, .05];
set(l, 'Position', rect)

vertLine = vertLine(1:end-1);
x=[vertLine,vertLine];
y=[0,6000];
plot(x,y,'--','color',[0.75,0.75,0.75])
drawnow

textLines = unique(cab(find(not(cellfun('isempty',strfind(cab,'Line'))))),'stable');
textLines = textLines(1:end-6);
text((vertLine + [0;vertLine(1:end-1)])/2,ones(size(vertLine))*5000,textLines,'HorizontalAlignment','right','Rotation',90);

export_fig('lllg_regression.eps','-transparent','-eps','-painters');

end