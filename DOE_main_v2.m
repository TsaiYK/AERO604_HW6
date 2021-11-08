clear
clc
close all

nS = 10000; % # of sample
p = 5;
lb = [0.01,0.01,2,2,3];
ub = [0.1,0.1,10,10,20];
delta = ub-lb;
x_LHS = lhsdesign(nS,p);
xDesign = x_LHS.*repmat(delta,nS,1)+repmat(lb,nS,1);
xDesign(:,5) = round(xDesign(:,5));

%% DVs
% nS = 1;
% t_skin = 0.055;
% t_stiff = 0.05;
% h_stiff = 5;
% w_stiff = 4;
% n_stiff = 3;
% 
% xDesign = [t_skin, t_stiff, h_stiff, w_stiff, n_stiff];

%% Outputs
k = 1;
Feasible = zeros(1,nS);
for i = 1:nS
    [weight(i),A_skin(i),A_stiff(i)] = WeightCal(xDesign(i,:));
    [stress_stiff(i), stress_skin(i)] = StressCal(xDesign(i,:));
    [sigma_cr_stiff(i), sigma_cr_skin(i)] = BucklingCalcs(xDesign(i,:));
    buckleOrNot(i,:) = [stress_stiff(i)>sigma_cr_stiff(i), ...
        stress_skin(i)>sigma_cr_skin(i)];
    if size(find(buckleOrNot(i,:)==0),2)==2
        Feasible(i) = 1;
        xDesign_Feasible(k,:) = xDesign(i,:);
        k = k+1;
    end
end
fprintf('0 means no buckling while 1 means buckling happens\n')

