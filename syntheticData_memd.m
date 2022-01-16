% apply MEMD to trivariate synthetic data and plot the resulting IMFs
%
% additionally, the univariate EMD is applied to each signal component
% individually to show the advantage of the MEMD with respect to the mode
% alignment property

clear 
close all
clc

addpath(strcat(pwd,'\functions\')) % add path where you saved to memd function 
save_path = strcat(pwd,'\figs\'); % path where you want to save your figures

% -------------------------------------------------------------------------------------------
% initialize the synthetic data
% -------------------------------------------------------------------------------------------

% define time vector
fs = 500;                % sampling frequency (samples per second/Hz) 
dt = 1/fs;               % seconds per sample 
stopTime = 5;            % length of signal in seconds 
t = (0:dt:stopTime-dt)'; % time vector in seconds 
stopTime_plot = 2;       % limit time axis for improved visualization 

% frequencies of all three signals
F_1 = 50;                % Hz
F_2 = 20;                % Hz
F_3 = 5;                 % Hz

% amplitudes of all signals
A_1 = 4;
A_2 = 5;
A_3 = 3;

% data, i.e., all three signals 
data_1 = A_1 + A_1*sin(2*pi*F_1*t) + A_1*sin(2*pi*F_2*t);
data_2 =       A_2*sin(2*pi*F_1*t) + A_2*sin(2*pi*F_3*t);
data_3 = A_3 + A_3*sin(2*pi*F_1*t) + A_3*sin(2*pi*F_2*t) + A_3*sin(2*pi*F_3*t);

data_combined = [data_1,data_2,data_3];

% -------------------------------------------------------------------------------------------
% parameters for memd algorithm
% -------------------------------------------------------------------------------------------

% advice: change these values to see how they influence your results 
k = 64;                        % projection directions
stopCrit = [0.075 0.75 0.075]; % stopping criteria

% -------------------------------------------------------------------------------------------

% pretty colors for plotting
blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
red = [0.6350 0.0780 0.1840];
violet = [0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
cyan = [0.3010 0.7450 0.9330];

% -------------------------------------------------------------------------------------------
% plot data 
% -------------------------------------------------------------------------------------------

figure
set(gcf,'color','w','Units','normalized','Position', [0.1, 0.2, 0.8, 0.5]);
tiledlayout(3,1)

% signal 1
nexttile
plot(t,data_1,'color',blue,'LineWidth',2);
xlabel('$t$','interpreter','latex');
ylabel('$g_1(t)$','interpreter','latex');
xlim([0 stopTime_plot])
ax = gca;
ax.FontSize = 16; 

%signal 2
nexttile
plot(t,data_2,'color',orange,'LineWidth',2);
xlabel('$t$','interpreter','latex');
ylabel('$g_2(t)$','interpreter','latex');
xlim([0 stopTime_plot])
ax = gca;
ax.FontSize = 16; 

% signal 3
nexttile
% fake plot of signal 1 and 2 outside the domain for legend
plot(t,400.*ones(length(t),1),'color',blue,'LineWidth',2);
hold on
plot(t,400.*ones(length(t),1),'color',orange,'LineWidth',2);
% third signal
plot(t,data_3,'color',green,'LineWidth',2);
xlabel('$t$','interpreter','latex');
ylabel('$g_3(t)$','interpreter','latex');
xlim([0 stopTime_plot])
ylim([-7 12])
ax = gca;
ax.FontSize = 16; 
legend('$g_1(t)$','$g_2(t)$','$g_3(t)$','interpreter','latex',...
    'location','southoutside','orientation','horizontal')
legend boxoff

saveas(gcf,strcat(save_path,'inputData.png'));

% -------------------------------------------------------------------------------------------
% plot as 3D visualization
% -------------------------------------------------------------------------------------------

figure
plot3(data_1,data_2,data_3,'color','k','LineWidth',1.5)
xlabel('$x$','interpreter','latex');
ylabel('$y$','interpreter','latex');
zlabel('$z$','interpreter','latex');
ax = gca;
ax.FontSize = 16; 
axis equal

saveas(gcf,strcat(save_path,'inputData_3Dview.png'));

% -------------------------------------------------------------------------------------------
% apply MEMD
% -------------------------------------------------------------------------------------------

% each column of data_combined is one variate 
% the dimension of the resulting imfs are [variates, imfs, time steps]
imfs = memd(data_combined,k,'stop',stopCrit);  

% -------------------------------------------------------------------------------------------
% plot IMFs
% -------------------------------------------------------------------------------------------

% limits for plotting each IMF       
bounds(1,1) = 4.5; bounds(1,2) = bounds(1,1); bounds(1,3) = bounds(1,1); bounds(1,4) = 0;  bounds(1,5) = 8; 
bounds(2,1) = 5.5; bounds(2,2) = 5.5; bounds(2,3) = bounds(2,2); bounds(2,4) = -bounds(2,2); bounds(2,5) = bounds(2,2);
bounds(3,1) = 3.5; bounds(3,2) = 3.5; bounds(3,3) = 3.5; bounds(3,4) = 0; bounds(3,5) = 6;

% plot IMFs in one figure
figure
set(gcf,'color','w','Units','normalized','Position', [0.1, 0.08, 0.8, 0.5]);
tiledlayout(size(imfs,1),4);

for i =1:size(imfs,1) % loop through all variates
    
    % assign colors
    if i == 1
        col = blue;
        name = '$g_1(t)$';
    elseif i == 2
        col = orange;
        name = '$g_2(t)$';
    elseif i == 3
        col = green;
        name = '$g_3(t)$';
    end
    
    for j = 1:3 % loop through IMFs
        nexttile
        plot(t,squeeze(imfs(i,j,:)),'color',col,'LineWidth',1.5)
        
        % assign labels
        if i == 1
            title(strcat(num2str(j),'. IMF'),'interpreter','latex')
        end
        if j == 1
            ylabel(name,'interpreter','latex');
        end
        xlabel('$t$','interpreter','latex');
        xlim([0 stopTime_plot])
        ylim([-bounds(i,j) bounds(i,j)])
        ax = gca;
        ax.FontSize = 12; 
    end
   
    % modes higher than the third can be added to build the residual since
    % they individually do not contain information that we need be separated
    nexttile
    dd = squeeze(sum(imfs(i,j+1:end,:)));
    plot(t,dd,'color',col,'LineWidth',1.5)
    xlabel('$t$','interpreter','latex');
    if i == 1
        title(strcat('res'),'interpreter','latex')
    end
    xlim([0 stopTime_plot])
    ylim([bounds(i,j+1) bounds(i,j+2)])
    ax = gca;
    ax.FontSize = 12; 
end

saveas(gcf,strcat(save_path,'imfs_memd.png'));

% -------------------------------------------------------------------------------------------
% apply univariate EMD
% -------------------------------------------------------------------------------------------

% univariate EMD is separately apply to each signal
imfs_1 = emd(data_1);
imfs_2 = emd(data_2);
imfs_3 = emd(data_3);

% -------------------------------------------------------------------------------------------
% plot resulting IMFs
% -------------------------------------------------------------------------------------------

figure
set(gcf,'color','w','Units','normalized','Position', [0.1, 0.08, 0.8, 0.5]);
tiledlayout(size(imfs,1),4);

% signal 1
i = 1;
for j = 1:3 % loop through IMFs
    nexttile
    plot(t,squeeze(imfs_1(:,j)),'color',blue,'LineWidth',1.5)
    title(strcat(num2str(j),'. IMF'),'interpreter','latex')
    if j == 1
        ylabel('$g_1(t)$','interpreter','latex');
    end        
    xlabel('$t$','interpreter','latex')
    xlim([0 stopTime_plot])
    ylim([-bounds(i,j) bounds(i,j)])
    ax = gca;
    ax.FontSize = 12; 
end

nexttile
dd = squeeze(sum(imfs_1(:,j+1:end),2));
plot(t,dd,'color',blue,'LineWidth',1.5)
title(strcat('res'),'interpreter','latex')
xlabel('$t$','interpreter','latex')   
xlim([0 stopTime_plot])
ylim([mean(dd)-2.01 mean(dd)+2.01])
ax = gca;
ax.FontSize = 12; 

% signal 2
i = 2;
for j = 1:3 
    nexttile
    plot(t,squeeze(imfs_2(:,j)),'color',orange,'LineWidth',1.5)
    if j == 1
        ylabel('$g_2(t)$','interpreter','latex');
    end  
    xlabel('$t$','interpreter','latex')
    xlim([0 stopTime_plot])
    ylim([-bounds(i,j) bounds(i,j)])
    ax = gca;
    ax.FontSize = 12; 
end

nexttile
dd = squeeze(sum(imfs_2(:,j+1:end),2));
plot(t,dd,'color',orange,'LineWidth',1.5)
xlabel('$t$','interpreter','latex')   
xlim([0 stopTime_plot])
ylim([mean(dd)-2.01 mean(dd)+2.01])
ax = gca;
ax.FontSize = 12; 

% signal 3
i = 3;
for j = 1:3 
    nexttile
    plot(t,squeeze(imfs_3(:,j)),'color',green,'LineWidth',1.5)
    if j == 1
        ylabel('$g_1(t)$','interpreter','latex');
    end  
    xlabel('$t$','interpreter','latex')
    xlim([0 stopTime_plot])
    ylim([-bounds(i,j) bounds(i,j)])
    ax = gca;
    ax.FontSize = 12; 
end

nexttile
dd = squeeze(sum(imfs_3(:,j+1:end),2));
plot(t,dd,'color',green,'LineWidth',1.5)
xlabel('$t$','interpreter','latex')   
xlim([0 stopTime_plot])
ylim([mean(dd)-2.01 mean(dd)+2.01])
ax = gca;
ax.FontSize = 12; 

saveas(gcf,strcat(save_path,'imfs_uniemd.png'));
