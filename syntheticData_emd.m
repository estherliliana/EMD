% apply EMD to synthetic data and plot the resulting IMFs

clear 
close all
clc

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

% create data
F_1 = 20;                % frequency, Hz
F_2 = 5;                 % frequency, Hz
A_1 = 4;                 % amplitude
A_2 = 7;                 % amplitude

data = A_1*sin(2*pi*F_1*t) + A_2*sin(2*pi*F_2*t);

% -------------------------------------------------------------------------------------------
% plot data 
% -------------------------------------------------------------------------------------------

figure
set(gcf,'color','w','Units','normalized','Position', [0.1, 0.2, 0.8, 0.5]);
plot(t,data,'LineWidth',2);
xlabel('$t$','interpreter','latex');
ylabel('$g(t)$','interpreter','latex');
xlim([0 stopTime_plot])
ax = gca;
ax.FontSize = 16; 

saveas(gcf,strcat(save_path,'inputData.png'));

% -------------------------------------------------------------------------------------------
% apply EMD
% -------------------------------------------------------------------------------------------

% dimension of imfs: [time, modes]
[imfs,res] = emd(data);  

% -------------------------------------------------------------------------------------------
% plot IMFs
% -------------------------------------------------------------------------------------------

figure
set(gcf,'color','w','Units','normalized','Position', [0.1, 0.15, 0.8, 0.5]);
tiledlayout(size(imfs,2)+1,1);

for i =1:size(imfs,2)  
    nexttile
    plot(t,squeeze(imfs(:,i)),'LineWidth',1.5)
    title(strcat(num2str(i),'. IMF'),'interpreter','latex')
    xlabel('$t$','interpreter','latex');
    xlim([0 stopTime_plot])
    ax = gca;
    ax.FontSize = 12; 
end

nexttile
plot(t,res,'LineWidth',1.5)
title('residual','interpreter','latex')
xlabel('$t$','interpreter','latex');
xlim([0 stopTime_plot])
ax = gca;
ax.FontSize = 12; 
    
saveas(gcf,strcat(save_path,'imfs_emd.png'));
