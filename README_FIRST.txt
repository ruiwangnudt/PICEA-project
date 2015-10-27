This is the Matlab implementation for PICEA-g.
Created 2012,06,01 by Rui 
The university of Sheffield


PICEA-g is a multi/many objective evolutionary algorithm whose performance is 
demonstrated to outperform the well-known NSGA-II and MOEA/D on many-objective problems.

You can follow the following steps to use this code:

(1) Add the folder subfunctions into the working path
(2) In the folder subfunctions there are two C functions
	find_nd.c and l2matrix.c
    You will need to first complie these functions using the following commonds:
    mex find_nd.c
    mex l2matrix.c
(3) You need to change the following problem parameters according to your own problem
    k = 4;  l = 4; % the wfg problem parameters 
    nVar = k + l;  % number of decision variables
    bounds=[zeros(1, nVar); 2*(1:nVar)];  % bounds of decision varialbes
(3) Replace your own objective functions with the default function "wfg"
    F_P = wfg(P, objvNo, k, l, testNo); 
    F_C = wfg(C, objvNo, k, l, testNo);

Lastly, we provide two versions of PICEA-g, the main difference lies in the generation of goal vectors
PICEA-g v1: objectiv vectors of candidate solutions ARE NOT normalized, and so goal vector bounds are 
            set according to current objective vectors.  
            
            alpha = 1.2;  % alpha is suggested within [1,2]
            goalUpper = alpha*max(F_P,[],1); 
            goalLower = min(F_P,[],1); 
            Goal = initGoals(Ngoal,goalUpper,goalLower); 
            .... 
            goalUpper = alpha*max(jointF,[],1);
            goalLower = min([jointF;goalLower],[],1);
            GoalC = initGoals(Ngoal,goalUpper,goalLower); 
    
PICEA-g v2: objectiv vectors of candidate solutions ARE normalized within [0,1], and so goal vectors 
            are always within alpha*[0,1]
            
            alpha = 1.2; % suggested to be set within (1,2)
            goalUpper = scalingfactor*ones(1,objvNo); 
            goalLower = zeros(1,objvNo);
            Goal = initGoals(Ngoal,goalUpper,goalLower);
            .... 
            GoalC = initGoals(Ngoal,goalUpper,goalLower);

	