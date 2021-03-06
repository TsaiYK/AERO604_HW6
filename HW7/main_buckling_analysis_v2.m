clear
clc
close all

%% Define the filename for eigenvalue info
filename_eigenVal = 'PostData_HW7_buckling_eigenVal.txt';
% Delete if the previous one exists
if exist(filename_eigenVal, 'file')==2
    delete(filename_eigenVal);
end
%% Full factorial DOE
num_level = 3;
p = 5;
lb = [0.001,0.001,0.75,0.75,3];
ub = [0.1,0.1,5,5,15];
for i = 1:p
    xSample(:,i) = linspace(lb(i),ub(i),num_level)';
end

k = 1;
for i1 = 1:num_level
    for i2 = 1:num_level
        for i3 = 1:num_level
            for i4 = 1:num_level
                for i5 = 1:num_level
                    xDesign(k,:) = [xSample(i1,1),xSample(i2,2),...
                        xSample(i3,3),xSample(i4,4),xSample(i5,5)];
                    k = k+1;
                end
            end
        end
    end
end

xDesign(:,5) = round(xDesign(:,5));

nS = size(xDesign,1);

%% Main loop for running Abaqus

% Define arrays of zeros for the min eigenvalue and weight for each set
min_eigenVal = zeros(1,nS);
design_weight = zeros(1,nS);

%Loops for each set of DVs and runs Abaqus code, calculates min eigenvalue
%and weight for each set and populates arrays
for i = 1:nS
    % Delete if the previous one exists
    if exist('DesignVariables.txt', 'file')==2
        delete('DesignVariables.txt');
    end
    fileDV = fopen('DesignVariables.txt','w');
    
    % Call out python code and run FEA
    fprintf(fileDV,'%.4f\n',xDesign(i,:));
    system('cd C:\Users\petermyers\OneDrive - Texas A&M University\AERO 405\HW 7');
    disp('Starting FEA analysis in Abaqus...')
    tic
    system('abaqus cae noGUI=buckling_sim_new3.py');
    disp('Done!')
    toc
    
    % Read the data
    fileID = fopen(filename_eigenVal,'r');
    eigenVal = fscanf(fileID,'%f');
    min_eigenVal(i) = min(eigenVal);
    fclose(fileID);
    design_weight(i) = WeightCal(xDesign(i,:));
end
fclose(fileDV);

%% Outputs

[min_weight, min_index] = min(design_weight);
t_skin_final = xDesign(min_index,1);
t_stiff_final = xDesign(min_index,2);
h_stiff_final = xDesign(min_index,3);
w_stiff_final = xDesign(min_index,4);
n_stiff_final = xDesign(min_index,5);
eigenvalue_final = min_eigenVal(min_index);

fprintf('Lowest weight: %.4f\n',min_weight,' in')
fprintf('T_skin: %.4f\n',t_skin_final,' in')
fprintf('T_stiff: %.4f\n',t_stiff_final,' in')
fprintf('H_stiff: %.4f\n',h_stiff_final,' in')
fprintf('W_stiff: %.4f\n',w_stiff_final,' in')
fprintf('N_stiff: %.4f\n',n_stiff_final)
fprintf('Eigenvalue: %.4f\n',eigenvalue_final)

% fprintf('Design variables:\n')
% fprintf('t_skin: %.4f in\n',xDesign(1))
% fprintf('t_stiff: %.4f in\n',xDesign(2))
% fprintf('h_stiff: %.4f in\n',xDesign(3))
% fprintf('w_stiff: %.4f in\n',xDesign(4))
% fprintf('n_stiff: %d\n',xDesign(5))

% final_eigenVal = min(min_eigenVal);
% fprintf('Eigenvalue for buckling: %.4f\n',final_eigenVal)
