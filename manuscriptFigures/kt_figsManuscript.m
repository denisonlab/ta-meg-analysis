% manuscript figures 

% November 2021
% Karen 

%% settings
saveFigs = 0; 

%% Paths
addpath(genpath(pwd))

%% load ITPC data 
load('/Users/kantian/Dropbox/github/ta-meg-analysis2/unused/groupA_ITPCspectrogram_byAtt.mat')
p = meg_params('TANoise_ITPCsession8');

%% Normalized ITPC TS by Cue 
% December 16, 2021 

% --- Data ---
foi = 20; 
[sessionNames,subjectNames,ITPCsubject,ITPCsession] = meg_sessions('TANoise');
downerIdx = find(ITPCsubject==-1); 
val_cueT1 = squeeze(A.cueT1.normSubject(foi,:,:)); 
val_cueT2 = squeeze(A.cueT2.normSubject(foi,:,:)); 
val_cueT1(:,downerIdx) = val_cueT1(:,downerIdx)*-1; 
val_cueT2(:,downerIdx) = val_cueT2(:,downerIdx)*-1; 
includeIdx = [1,2,3,4,6,7,8,9,10]; % 9 subjects 

% --- Figure ---
figure
set(gcf,'Position',[100 100 600 400])
hold on 
plotErrorBars = 1; 
sampling = 1:10:7001;

% -- Error Bars --- 
% Requires https://www.mathworks.com/matlabcentral/fileexchange/26311-raacampbell-shadederrorbar 
plotErrorBars = 1; 
errorBarType = 'EB-TS-SED'; % 'EB-TS' 'EB-fit' 'EB-TS-baselineNorm' 'EB-TS-SED'
if plotErrorBars
    includeIdx = 1:10;
    switch errorBarType
        case 'EB-TS-SED'
            t = p.t(sampling);
            sed = vals_cueT1-vals_cueT2;
            sed = std(sed(:,includeIdx),[],2)/sqrt(numel(includeIdx));
            % --- Precue T1 ---
            line_precueT1 = shadedErrorBar(t,mean(val_cueT1(sampling,includeIdx),2), sed(sampling),...
                'lineProps', {'MarkerFaceColor',p.cueColors(1,:), 'LineWidth', 0.2, 'Color',p.cueColors(1,:)}, 'transparent',1);
            % --- Precue T2 ---
            line_precueT2 = shadedErrorBar(t,mean(val_cueT2(sampling,includeIdx),2), sed(sampling),...
                'lineProps', {'MarkerFaceColor',p.cueColors(2,:), 'LineWidth', 0.2, 'Color',p.cueColors(2,:)}, 'transparent',1);
    end
end

% -- Plot data lines --- 
plot(p.t(sampling),mean(val_cueT1(sampling,includeIdx),2),'Color',[p.cueColors(1,:)],'LineWidth',3);
plot(p.t(sampling),mean(val_cueT2(sampling,includeIdx),2),'Color',[p.cueColors(2,:)],'LineWidth',3); 

% --- Plot event lines --- 
for i = 1:numel(p.eventTimes)
    xline(p.eventTimes(i),'Color',[0.5 0.5 0.5],'LineWidth',1,'LineStyle','-')
end
yline(0,'Color',[0.5 0.5 0.5],'LineWidth',1,'LineStyle','-')

% --- Format --- 
meg_figureStyle
xlabel('Time (ms)')
ylabel('Normalized ITPC')
xlim([-100 2400])
if plotErrorBars
    ylim([-0.07 0.13])
else
    ylim([-0.04 0.1])
end

% --- Save fig --- 
if saveFigs 
    figTitle = 'ITPC_TS_normalized'; 
    saveas(gcf,sprintf('%s.svg', figTitle)) 
end

% --- Point wise ttest ---
% for i = 1:7001
%     v1 = val_cueT1(i,:); 
%     v2 = val_cueT2(i,:); 
%     if sum(isnan(v1))==0 && sum(isnan(v2))==0 
%         [h_t(i),p_t(i)] = ttest(v1,v2); 
%     else
%         h_t(i) = NaN; 
%         p_t(i) = NaN; 
%     end
% end
% idxSig = find(h_t==1); 
% % --- Plot Sig Times --- 
% for i = 1:numel(idxSig)
%     xline(t(idxSig(i)),'Color',[0.5 0.5 0.5],'LineWidth',1)
% end

%% FIG: 20 Hz ITPC whole time series, average across all trials, temporal expectation fit 

% setup 
sampling = 1:10:7001;
freq = 20; 

% --- Figure ---
figure
set(gcf,'Position',[100 100 600 400])
hold on 

% --- Fit settings ---
toi = abs(p.tstart)+p.eventTimes(1):abs(p.tstart)+p.eventTimes(2); % preCue:T1
toi = toi(1):toi(end)-paddingBefore; % select timing for fit 
% --- All trials --- 
vals = squeeze(A.all.subject(freq,:,:));  % frequency x time x subject (from avg sessions)
groupVals = squeeze(mean(vals,2)); % average across subject 
% --- Do fit (on subjects, for error bars) ---
for i = 1:size(vals,2)
    [c_subs(i).fit, c_subs(i).error] = polyfit(toi,vals(toi,i)',1);
    [c_subs(i).y1_est, c_subs(i).delta] = polyval(c_subs(i).fit,toi,c_subs(i).error);
end
% --- Do fit (on group averaged, for visualization) ---
[c1,error1] = polyfit(toi,groupVals(toi),1);
[y1_est,delta1] = polyval(c1,toi,error1);
% --- Plot fit --- 
p1_fit = plot(p.t(toi),y1_est,'Color',[0.3 0.3 0.3],'LineWidth',2); 
% --- Downsample ---
% groupVals = groupVals(sampling); 

% -- Error Bars (TS) --- 
plotErrorBars = 1; 
errorBarType = 'EB-TS-baselineNorm'; % 'EB-TS' 'EB-fit' 'EB-TS-baselineNorm'
if plotErrorBars
    includeIdx = 1:10;
    switch errorBarType
        case 'EB-TS'
            t = p.t(sampling);
            line_allTrials = shadedErrorBar(t, groupVals(sampling), std(vals(sampling,includeIdx),[],2)/sqrt(numel(includeIdx)),...
                'lineProps', {'MarkerFaceColor','k', 'LineWidth', 0.2, 'Color','k'}, 'transparent',1);
        case 'EB-TS-baselineNorm'
            baselineTOI = -200:-1; 
            baselineTOIIdx = find(p.t==baselineTOI(1)):find(p.t==baselineTOI(end)); 
            for i = 1:size(vals,2) % average per subject 
                baselineS(i) = mean(vals(baselineTOIIdx,i),1);
                normVals(:,i) = vals(:,i)./baselineS(i); 
            end
            % sem in units of percent change 
            sem = std(normVals(sampling,includeIdx),[],2)/sqrt(numel(includeIdx)); 
            % scale sem back to ITPC units 
            baselineG = mean(groupVals(baselineTOIIdx)); 
            semScaled = sem*baselineG; 
            % Plot 
            t = p.t(sampling);
            line_allTrials = shadedErrorBar(t, groupVals(sampling), semScaled,...
                'lineProps', {'MarkerFaceColor','k', 'LineWidth', 0.2, 'Color','k'}, 'transparent',1);
        case 'EB-fit'
            t = p.t(toi); 
            % Collect subject-level fits into single matrix 
            for i = 1:numel(c_subs)
                sub_fits(:,i) = c_subs(i).y1_est; 
            end
            line_allTrials = shadedErrorBar(t, y1_est, std(sub_fits(:,includeIdx),[],2)/sqrt(numel(includeIdx)),...
                'lineProps', {'MarkerFaceColor','k', 'LineWidth', 0.2, 'Color','k'}, 'transparent',1);
    end
end

% --- Plot TS ---
t = p.t(sampling); 
plot(t, groupVals(sampling),'LineWidth',3,'Color',[0.3 0.3 0.3])

% --- Plot event lines ---
for i = 1:numel(p.eventTimes)
    xline(p.eventTimes(i),'Color',[0.5 0.5 0.5],'LineWidth',1)
end

% --- Format ---
meg_figureStyle
xlabel('Time (ms)')
ylabel('ITPC')
xlim([-100 2400])
ylim([0.25 0.4])

% December 10 timing check 
% [~,afterCushion] = min(groupVals(0+200:20+200)); 
% xline(afterCushion*10) 
% [~,beforeCushion] = max(groupVals(90+200:100+200)); 
% xline((100-beforeCushion)*10) 

if saveFigs 
    figTitle = sprintf('temporalExpectation_allTrials_TS_fit_%s',errorBarType); 
    saveas(gcf,sprintf('%s.svg', figTitle)) 
end

%% FIG: 20 Hz ITPC slope by ITI 
% December 20, 2021 
% load separate data? 

% --- Figure ---
figure
set(gcf,'Position',[100 100 300 400])
hold on 
meg_figureStyle

ITIs = 500:200:1500; 
for i = 1:numel(ITIs)
    fieldname = sprintf('ITI%d',ITIs(i));
    y = A.(fieldname).slopes' * 1000; 
end

xITI = 1:6; 
for i = 1:numel(ITIs) 
    fieldname = sprintf('ITI%d',ITIs(i));
    y = A.(fieldname).slopes' * 1000; 
    ste = std(y)/sqrt(20); 
    meany = mean(y); 
    x = repmat(xITI(i),[20,1]); 
    scatter(x,y,'filled','MarkerFaceColor',p.cueColors(i,:),'MarkerFaceAlpha',0.5)
    errorbar(xITI(i),meany,ste,'Marker','.','MarkerSize',40,'MarkerFaceColor',p.cueColors(i,:),'MarkerEdgeColor',p.cueColors(i,:),...
        'Color',p.cueColors(i,:),'LineWidth',2); 
end
xlim([0 7])
xticks(xITI)
xticklabels({'500','700','900','1100','1300','1500'})
ylabel('Slope (delta ITPC/s')
xlabel('Jitter (ms)')

figTitle = 'temporalExpectation-jitter';
if saveFigs 
    saveas(gcf,sprintf('%s.svg', figTitle)) 
end

%% FIG: 20 Hz ITPC peaks T1 and T2 
% December 20, 2021 
% something isn't right w these vals... 

load('/Users/kantian/Dropbox/Data/TANoise/fromRachel/itpcNorm_TS_Peaks_N10_20211225_workspace.mat')

% peak data 
% att (precue T1 precue T2, peak T1 T2, subject, session
peakDataAve = mean(peakData,4); 

p = meg_params('TANoise_ITPCsession8'); 

% --- Figure ---
figure
set(gcf,'Position',[100 100 300 400])
hold on 
meg_figureStyle
xJitter = 0.2; 
idxPeaks = 1:10; 
idxPeaks(5) = []; 

% cue x target x subject x session
% peakDataAveAve = mean(peakDataAve,1); % average sessions 
peak_T1 = squeeze(peakDataAve(1,:,:));
peak_T2 = squeeze(peakDataAve(2,:,:));

% T1 
% valid 
x_valid = repmat(1-xJitter,[9,1]);
scatter(x_valid,peak_T1(1,idxPeaks),'filled','MarkerFaceColor',p.cueColors(1,:),'MarkerFaceAlpha',0.5)
% standard error 
% errorbar(x_valid(1),mean(peak_T1(1,idxPeaks)),std(peak_T1(1,idxPeaks))/sqrt(10),'Marker','.','MarkerSize',40,'MarkerFaceColor',p.cueColors(1,:),'MarkerEdgeColor',p.cueColors(1,:),...
%     'Color',p.cueColors(1,:),'LineWidth',2);
% standard error of difference 
errorbar(x_valid(1),mean(peak_T1(1,idxPeaks)),peakDiffSte(1),'Marker','.','MarkerSize',40,'MarkerFaceColor',p.cueColors(1,:),'MarkerEdgeColor',p.cueColors(1,:),...
    'Color',p.cueColors(1,:),'LineWidth',2);
% invalid 
x_valid = repmat(1+xJitter,[9,1]);
scatter(x_valid,peak_T1(2,idxPeaks),'filled','MarkerFaceColor',p.cueColors(2,:),'MarkerFaceAlpha',0.5)
% errorbar(x_valid(1),mean(peak_T1(2,idxPeaks)),std(peak_T1(2,idxPeaks))/sqrt(10),'Marker','.','MarkerSize',40,'MarkerFaceColor',p.cueColors(2,:),'MarkerEdgeColor',p.cueColors(2,:),...
%     'Color',p.cueColors(2,:),'LineWidth',2);
errorbar(x_valid(1),mean(peak_T1(2,idxPeaks)),peakDiffSte(1),'Marker','.','MarkerSize',40,'MarkerFaceColor',p.cueColors(2,:),'MarkerEdgeColor',p.cueColors(2,:),...
    'Color',p.cueColors(2,:),'LineWidth',2);

% T2 
% valid 
x_valid = repmat(2-xJitter,[9,1]);
scatter(x_valid,peak_T2(2,idxPeaks),'filled','MarkerFaceColor',p.cueColors(1,:),'MarkerFaceAlpha',0.5)
% errorbar(x_valid(1),mean(peak_T2(2,idxPeaks)),std(peak_T2(2,idxPeaks))/sqrt(10),'Marker','.','MarkerSize',40,'MarkerFaceColor',p.cueColors(1,:),'MarkerEdgeColor',p.cueColors(1,:),...
%     'Color',p.cueColors(1,:),'LineWidth',2);
errorbar(x_valid(1),mean(peak_T2(2,idxPeaks)),peakDiffSte(2),'Marker','.','MarkerSize',40,'MarkerFaceColor',p.cueColors(1,:),'MarkerEdgeColor',p.cueColors(1,:),...
    'Color',p.cueColors(1,:),'LineWidth',2);
% invalid 
x_valid = repmat(2+xJitter,[9,1]);
scatter(x_valid,peak_T2(1,idxPeaks),'filled','MarkerFaceColor',p.cueColors(2,:),'MarkerFaceAlpha',0.5)
% errorbar(x_valid(1),mean(peak_T2(1,idxPeaks)),std(peak_T2(1,idxPeaks))/sqrt(10),'Marker','.','MarkerSize',40,'MarkerFaceColor',p.cueColors(2,:),'MarkerEdgeColor',p.cueColors(2,:),...
%     'Color',p.cueColors(2,:),'LineWidth',2);
errorbar(x_valid(1),mean(peak_T2(1,idxPeaks)),peakDiffSte(2),'Marker','.','MarkerSize',40,'MarkerFaceColor',p.cueColors(2,:),'MarkerEdgeColor',p.cueColors(2,:),...
    'Color',p.cueColors(2,:),'LineWidth',2);

xlim([0 3])
xticks([1,2])
xticklabels({'T1','T2'}); 
ylabel('ITPC')

% figure
% val = mean(peakData,4,'omitnan'); 
% val = val(:,1,1,1,1); 
% plot(val)

%% FIG: 20 Hz ITPC time series, average across all trials, check individual derivative 0 before T1 
% December 13, 2021 sanity check 

% setup 
sampling = 1:10:7001;
freq = 20; 
vals = squeeze(A.all.subject(freq,:,:));  % frequency x time x subject (from avg sessions)
groupVals = squeeze(mean(vals,2)); % average across subject 
groupVals = groupVals(sampling); 
t = p.t(sampling); 

% figure 
figure
% set(gcf,'Position',[100 100 600 300])
hold on 
plot(t, groupVals,'LineWidth',3,'Color',[0.3 0.3 0.3])
for i = 1:10
    subplot(10,1,i)
    plot(t, vals(sampling,i),'LineWidth',1)
    xlim([-100 1100])
    meg_figureStyle
end

for i = 1:numel(p.eventTimes)
    xline(p.eventTimes(i),'Color',[0.5 0.5 0.5],'LineWidth',1)
end
xlabel('Time (ms)')
ylabel('ITPC')
title('Group raw ITPC time series')
figTitle = 'GroupRawITPC-ts'; 

xlim([-100 1100])
% [~,afterCushion] = min(groupVals(0+200:20+200)); 
% xline(afterCushion*10) 
% [~,beforeCushion] = max(groupVals(90+200:100+200)); 
% xline((100-beforeCushion)*10) 

if saveFigs 
    saveas(gcf,sprintf('%s.svg', figTitle)) 
end

%% FIG: 20 Hz ITPC time series by precue with fit 

% setup 
sampling = 1:10:7001;
freq = 20; 
t = p.t(sampling); 

% --- Figure ---
figure
set(gcf,'Position',[100 100 600 400])
hold on 

% --- Fit settings ---
paddingBefore = 80; % check 
toi = abs(p.tstart)+p.eventTimes(1):abs(p.tstart)+p.eventTimes(2); % preCue:T1
toi = toi(1):toi(end)-paddingBefore; % select timing for fit 
% --- Cue T1 --- 
vals = []; 
vals_cueT1 = squeeze(A.cueT1.subject(freq,:,:));  % frequency x time x subject (from avg sessions)
groupVals_cueT1 = squeeze(mean(vals_cueT1,2)); % average across subject 
% do fit 
[c1,error1] = polyfit(toi,groupVals_cueT1(toi),1);
[y1_est,delta1] = polyval(c1,toi,error1);
p1_fit = plot(p.t(toi),y1_est,'Color',p.cueColors(1,:),'LineWidth',2); 

% --- Cue T2 --- 
vals = []; 
vals_cueT2 = squeeze(A.cueT2.subject(freq,:,:));  % frequency x time x subject (from avg sessions)
groupVals_cueT2 = squeeze(mean(vals_cueT2,2)); % average across subject 
% do fit 
[c2,error2] = polyfit(toi,groupVals_cueT2(toi),1);
[y2_est,delta2] = polyval(c2,toi,error2);
p2_fit = plot(p.t(toi),y2_est,'Color',p.cueColors(2,:),'LineWidth',2); 

% -- Error Bars (TS) --- 
plotErrorBars = 1; 
errorBarType = 'EB-TS-SED'; % 'EB-TS' 'EB-fit' 'EB-TS-baselineNorm' 'EB-TS-SED'
if plotErrorBars
    includeIdx = 1:10;
    switch errorBarType
        case 'EB-TS-SED'
            t = p.t(sampling);
            sed = vals_cueT1-vals_cueT2;
            sed = std(sed(:,includeIdx),[],2)/sqrt(numel(includeIdx));
            % --- Precue T1 ---
            line_precueT1 = shadedErrorBar(t,groupVals_cueT1(sampling), sed(sampling),...
                'lineProps', {'MarkerFaceColor',p.cueColors(1,:), 'LineWidth', 0.2, 'Color',p.cueColors(1,:)}, 'transparent',1);
            % --- Precue T2 ---
            line_precueT2 = shadedErrorBar(t,groupVals_cueT2(sampling), sed(sampling),...
                'lineProps', {'MarkerFaceColor',p.cueColors(2,:), 'LineWidth', 0.2, 'Color',p.cueColors(2,:)}, 'transparent',1);
    end
end

% --- Plot T1 T2 TS --- 
plot(t, groupVals_cueT1(sampling),'LineWidth',3,'Color',p.cueColors(1,:))
plot(t, groupVals_cueT2(sampling),'LineWidth',3,'Color',p.cueColors(2,:))

% --- Plot event lines --- 
for i = 1:numel(p.eventTimes)
    xline(p.eventTimes(i),'Color',[0.5 0.5 0.5],'LineWidth',1)
end

% --- Formatting --- 
meg_figureStyle
xlim([-100 2400])
ylim([0.25 0.4])
xlabel('Time (ms)')
ylabel('ITPC')

if saveFigs 
    figTitle = 'temporalExpectation_TS_byPrecue_errorBarSED'; 
    saveas(gcf,sprintf('%s.svg', figTitle)) 
end


%% FIG: 20 Hz ITPC by jitter
% run kt_ITPCbyITI.m to load and prepare data, variableOI =
% groupITP_ITI.group

% setup 
sampling = 1:10:7001;

% figure 
figure
set(gcf,'Position',[100 100 800 400])

hold on
for iField = 1:numel(fields)
    pLine(iField) = plot(toi(sampling),groupITPC_ITI.group.(fields{iField})(foi,sampling),'Color',[p.cueColors(iField,:) 0.8],'LineWidth',2,...
        'DisplayName',fields{iField},'LineWidth',2);
    pause(1)
end
% xlim([toi(1) toi(end)])
xlim([-1600 2350])
ylim([0 0.4])
yticks(0:0.1:0.4)
set(gca,'TickDir','out');
ax = gca;
ax.LineWidth = 1.5;
ax.XColor = 'black';
ax.YColor = 'black';
ax.FontSize = 12;
xlabel('Time (ms)')
ylabel('ITPC')
legend([pLine(1) pLine(2) pLine(3) pLine(4) pLine(5) pLine(6)],fields)
legend('Location','northeastoutside','NumColumns',1)
legend('boxoff')
box off
for iEv = 1:numel(p.eventTimes) % plot event times
    xline(p.eventTimes(iEv),'k','LineWidth',1,'HandleVisibility','off');
end
for iEv = 1:numel(fields) % plot ITI times
    ITIs = [-500,-700,-900,-1100,-1300,-1500];
    xline(ITIs(iEv),'-','Color',p.cueColors(iEv,:),'LineWidth',1,'HandleVisibility','off');
end
figTitle = 'ITPCbyITI'; 
meg_figureStyle
% yline(0,'k','LineWidth',0.5)
if saveFigs
    saveas(gcf,sprintf('%s.svg', figTitle)) 
end

%% ITPC spectrogram by cue 
% December 16, 2021 

% --- Data ---
toi = (-100:2400) + abs(p.tstart); 
val_cueT1 = mean(A.cueT1.session(:,toi,:),3); 
val_cueT2 = mean(A.cueT2.session(:,toi,:),3); 
val_diff = val_cueT1 - val_cueT2; 

% --- Figure ---
figure
set(gcf,'Position',[100 100 1500 300])
toi = (-100:2400); 
foi = 1:50;
ytick = 10:10:numel(foi);
xtick = 1:500:numel(toi);
xlims = [size(toi,1),size(toi,2)]; 
ylims = [1 50];

subplot 131 
hold on 
imagesc(val_cueT1)
xlim(xlims)
ylim(ylims)
meg_timeFreqPlotLabels(toi,foi,xtick,ytick,p.eventTimes+100)
meg_figureStyle
colorbar 
caxis([0 0.4])

subplot 132
hold on 
imagesc(val_cueT2)
xlim(xlims)
ylim(ylims)
meg_timeFreqPlotLabels(toi,foi,xtick,ytick,p.eventTimes+100)
meg_figureStyle
colorbar 
caxis([0 0.4])

subplot 133
hold on 
imagesc(val_diff)
xlim(xlims)
ylim(ylims)
meg_timeFreqPlotLabels(toi,foi,xtick,ytick,p.eventTimes+100)
meg_figureStyle
colorbar 