%% PICEA-g MATLAB code
%**************************************************************************
% Main Idea:
% PICEA-g is developed to solve multi/many-objective problems. It co-evolves
% candidate solutions with a set of goal vectors during the seach progress. 
% Candiate solutions are guided twoards the Pareto optimal front by goal vectors.
% Goal vectors gain fitness by offering comparablity to the candidate solutions

% The PICEA-g employs the "mu+lamada" elitist framework, that is, select
% the best N solutions from a union of parent (N) and offspring (N) 
% population
%**************************************************************************
% Reference: 
% R. Wang, R. Purshouse, and P. Fleming, Preference-inspired
% coevolutionary algorithms for many-objective optimisation, IEEE Trans.
% Evol. Comput., 2013. In press.
%**************************************************************************
%
% <1> Note that in this version, goal vector bounds are estimated as follows  
%     goalUpper = alpha*max(jointF,[],1);
%     goalLower = min([jointF;goalLower],[],1);
%     where jointF is the combined population in the current generation

% <2> As the effect of Pareto dominance check is not significant
%     for many-objective problems, the Pareto dominance check specifed 
%     in the paper is not applied here. Also the fitness assignment used in
%     PICEA-g is weak Pareto dominace complied.

% <3> Note that this code demonstrates the performance of PICEA-g on 
%     2-objective WFG4 problem
%**************************************************************************

% Author:     Rui Wang     The University of Sheffield, UK & 
%                          National University of Defense Technology, P.R.China 
% History:    02.OCT.2011  file created
%             04.SEP.2015  clean up
  
% Feel free to contact me if you have any questions on this algorithm
% Dr. Rui Wang,   Email: ruiwangnudt@gmail.com
% Copyright reserved by the authors

%% ************************************************
% The number of objectives
objvNo = 2;
% testNo: test problem
testNo = 4;  
% The population size of candidate solutions and goal vectors
N = 100; Ngoal = 100; 
% The maximum number of generations
maxGen = 100;

%% create figure
hf = figure;
%% parameters for decision variables. 
% ******** Note that this might need to changed to follow your own problem ****** %
k = 4;  l = 4; % the wfg problem parameters
nVar = k + l;  % number of decision variables
bounds=[zeros(1, nVar); 2*(1:nVar)];  % bounds of decision varialbes

%% initialise offline archive
% To store the best so far Pareto optimal front
bestobjv = Inf*ones(1,objvNo);
% To store the best so far Pareto optimal set 
bestphen = NaN*ones(1,nVar);

%% initialize candidate solutions
P = crtrp(N,bounds);

%% compute objective values of P
% ******** Note that you can replace "wfg" with your own objective functions *******%
F_P = wfg(P, objvNo, k, l, testNo); 
 
%% generate goal vectors within goal vector bounds
alpha = 1.2; % suggested to be within (1,2)
goalUpper = alpha*max(F_P,[],1); 
goalLower = min(F_P,[],1); 
Goal = initGoals(Ngoal,goalUpper,goalLower); 

%% Evolution process
for gen = 1:maxGen
    %% obtain new solutions by crossover and mutation
    % shuffle candidate solutions first
    numn = size(P,1);  rx = randperm(numn); C = P(rx,:);
    % apply crrossover (SBX) and mutation (PM) operators to generate new offspring 
    % Note that SBX and PM is only for real-number optimization.  You might need to 
    % design your own crossover and mutation operators
    C= sbx_sal(C, bounds, 15, 0, 1, 1,0.5);
    C = polymut_sal(C, bounds, 20, 1/nVar);
    
    %% Compute objective values for the new offspring 
    % For your problem you should also replace "wfg" with your own objective functions 
    F_C = wfg(C, objvNo, k, l, testNo);
    
    %% combine the parent and offspring population for candidate solutions
    jointP = [P;C]; jointF = [F_P;F_C];
    
    %% Update the goal vector bounds, and generate new goal vectors
    goalUpper = alpha*max(jointF,[],1);
    goalLower = min([jointF;goalLower],[],1);
    GoalC = initGoals(Ngoal,goalUpper,goalLower); 
    
    %%  combine the parent and offspring population for goal vectors
    jointG = [Goal; GoalC];
    
    %% fitness assignment <the core part of the PICEA-g>
    result = fitness_PICEAg(jointF,jointP,jointG,objvNo);
    scoreS = result{1};  scoreG = result{2};
    
    %% select the best N candidate solutions and Ngoal goal vectors
    ixS = trunc_No(scoreS,N);
    P = jointP(ixS,:);
    F_P = jointF(ixS,:);
    ix = trunc_No(scoreG,Ngoal);
    Goal = jointG(ix,:);
  
    %% Offline archive
    % store all non-dominated solutions found so far
    [ix,bestix] = find_nd(F_P,bestobjv);
    bestobjv = [bestobjv(logical(bestix),:) ; F_P(logical(ix),:)];
    bestphen = [bestphen(logical(bestix),:) ; P(logical(ix),:)];
    % if more than N solutions are in the archive, use the SPEA clustering
    % method to obtain a set of well distributed solutions
    if size(bestobjv,1)>N
        [bestobjv,index] = reducer(bestobjv, objvNo, N);
        bestphen = bestphen(index,:);
    end
    
    %% Plot the results
    CurrentPF=bestobjv;
    CurrentPS=bestphen;
    plot(CurrentPF(:,1),CurrentPF(:,2),'b*',Goal(:,1),Goal(:,2),'ro');
    legend('Pareto optimal front','Goal vectors')
    title({['TestNo: ',num2str(testNo)],['Generation: ',num2str(gen)]})
    drawnow
end


