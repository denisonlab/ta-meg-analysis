% meg_runGroup 

%% setup
user = 'mcq'; % 'mcq','karen'
expt = 'TA2';

%% get session names
switch expt
    case 'TANoise'
        sessionNames = {'R0817_20171212','R0817_20171213',...
            'R1187_20180105','R1187_20180108',...
            'R0983_20180111','R0983_20180112',...
            'R0898_20180112','R0898_20180116',...
            'R1021_20180208','R1021_20180212',...
            'R1103_20180213','R1103_20180215',...
            'R0959_20180219','R0959_20180306',...
        	'R1373_20190723','R1373_20190725',...
            'R1452_20190717','R1452_20190718',...
            'R1507_20190702','R1507_20190705'}; % N=10 x 2 sessions TANoise

    case 'TA2'
        sessionNames = {'R0817_20181120', 'R0817_20190625',...
            'R0898_20190723', 'R0898_20190724',...
            'R0959_20181128', 'R0959_20190703',...
            'R0983_20190722', 'R0983_20190723',...
            'R1103_20181121', 'R1103_20190710',...
            'R1187_20181119', 'R1187_20190703',...
            'R1373_20181128', 'R1373_20190708',...
            'R1452_20181119', 'R1452_20190711',...
            'R1507_20190621', 'R1507_20190627',...
            'R1547_20190729', 'R1547_20190730'}; % N=10 x 2 sessions TA2
end

%% run analysis 
for i=1:numel(sessionNames)
    sessionDir = sessionNames{i}; 
    disp(sessionDir)
    meg_runAnalysis(exptName, sessionDir, user); 
end

%% alpha finder
for i=1:numel(sessionNames)
    sessionDir = sessionNames{i}; 
    disp(sessionDir)
    meg_selectChannels(sessionDir)
    close all
end