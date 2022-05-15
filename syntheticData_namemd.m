% 1D NA-MEMD with synthetic trivariate data and increasing number of noise
% channels (fixed noise variance)

clear 
close all
clc

addpath(strcat(pwd,'\functions\')) % add path where you saved to memd function 
save_path = strcat(pwd,'\figs\'); % path where you want to save your figures

% -------------------------------------------------------------------------------------------
% initialize the synthetic data
% -------------------------------------------------------------------------------------------

Fs = 500;          % Sampling frequency                    
dt = 1/Fs;         % Sampling increments      
L = 10;            % signal length (seconds)
t = (0:dt:L-dt);   % Time vector
len = length(t);   % signal length (data points)
t1 = 1258;         % time step where data composition changes
t2 = 2515;

% frequencies [Hz]
F1 = 1;   
F2 = 6;  
F3 = 12; 

% amplitudes
A(1) = 5; 
A(2) = 8; 
A(3) = 10; 

% data
data_all(:,1) = A(1).*sin(2*pi*F1*t);  

data_all(:,2) = A(2).*sin(2*pi*F1*t); 
data_all(t1:end,2) = A(2).*sin(2*pi*F2*t(t1:end)); 

data_all(:,3) = A(3).*sin(2*pi*F2*t);  
data_all(t2:end,3) = A(3).*sin(2*pi*F2*t(t2:end)) + A(3).*sin(2*pi*F3*t(t2:end)); 

data_all = data_all';

% -------------------------------------------------------------------------------------------
% parameters for memd algorithm
% -------------------------------------------------------------------------------------------

% advice: change these values to see how they influence your results 
k = 64;                        % projection directions
stopCrit = [0.075 0.75 0.075]; % stopping criteria

% noise parameters (number of noise channels is progressively increased)
rng('default')  % ensure reproducability
var_WGN = 0.05; % proportion of data variance that is taken as noise variance

% -------------------------------------------------------------------------------------------

%colors
col(:,1) = [0 0.4470 0.7410];
col(:,2) = [0.8500 0.3250 0.0980];
col(:,3) = [0.6350 0.0780 0.1840];
col(:,4) = [0.4940 0.1840 0.5560];
col(:,5) = [0.4660 0.6740 0.1880];
col(:,6) = [0.3010 0.7450 0.9330];
col(:,7) = [0.5 0.5 0.5];
col(:,8) = [1 1 1];

% -------------------------------------------------------------------------------------------
% adding increasing number of noise channels to data decomposition

for numNC = 0:1:5 % increasing number of noise channels

    % -------------------------------------------------------------------------------------------
    % generate random noise
    noise = rand(numNC,len)*2 - 1; %rand generates values [0 1] -> [-1 1]
    noise = noise - mean(noise,2); % zero mean

    % scale WGN with respect to variance of data to obtain desired std
    std_noise = sqrt(std(data_all(:))^2*var_WGN);
    scaledNoise = std_noise*(noise./std(noise,0,2));
    
    % compose final signal
    data_na = [data_all;scaledNoise];

    % -------------------------------------------------------------------------------------------
    % plot input data
    fig1 = figure;
    set(gcf,'color','k','Units','normalized','Position', [0.08, 0.08, 0.8, 0.8]);
    tiledlayout(size(data_na,1),1)

    for i = 1:size(data_na,1)
        nexttile
        plot(t,data_na(i,:),'color',col(:,i),'LineWidth',2);
        hx = xlabel('$t$','interpreter','latex');
        hx.FontSize = 18;
        hy = ylabel(strcat('$g_',num2str(i),'(t)$'),'interpreter','latex');
        hy.FontSize = 18;
        ax = gca;
        ax.FontSize = 16;             
        set(gca, 'Color','k', 'XColor','w', 'YColor','w')
    end
    
    fig1.InvertHardcopy = 'off'; 
    saveas(gcf,strcat(save_path,'\input_numNC',num2str(numNC),'.png'));  

    % -------------------------------------------------------------------------------------------
    % perform MEMD 
    % each column of data_combined is one variate 
    % the dimension of the resulting imfs are [variates, imfs, time steps]
    imfs_na = memd(data_na,k,'stop',stopCrit);  

    % -------------------------------------------------------------------------------------------
    % plot IMFs 
    fig2 = figure;
    set(gcf,'color','k','Units','normalized','Position', [0.08, 0.08, 0.8, 0.8]);
    
        if numNC == 0
            jstart = 1;
            jend = 4;
        elseif numNC < 2
            jstart = 4;
            jend = 8;
        else
            jstart = 5;
            jend = 9;            
        end
        
    tiledlayout((jend-jstart+1),size(imfs_na,1)-numNC);

    for i =1:size(imfs_na,1)-numNC % variates   
        
        for j = jstart:jend % modes
            nexttile(i+(size(imfs_na,1)-numNC).*(j-jstart))
            plot(t,squeeze(imfs_na(i,j,:)),'color',col(:,i),'LineWidth',1.5)
            if j == jstart
                title(strcat('$g_',num2str(i),'(t)$'),'interpreter','latex','color','w')
            end
            if i == 1
                hy = ylabel(strcat(num2str(j),'. IMF'),'interpreter','latex');
                hy.FontSize = 12;
            end
            ylim([-A(i) A(i)])
            hx = xlabel('$t$','interpreter','latex');
            hx.FontSize = 12;
            ax = gca;
            ax.FontSize = 12; 
            set(gca, 'Color','k', 'XColor','w', 'YColor','w')
        end
    end
    
    fig2.InvertHardcopy = 'off'; % to preserve black background in save
    saveas(gcf,strcat(save_path,'\imfs_wNoise_numNC',num2str(numNC),'.png'));
end
