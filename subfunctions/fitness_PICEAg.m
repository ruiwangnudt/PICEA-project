% fitness_PICEAg function for co-evolved solutions and goals
% The university of Sheffield
% created by Rui 02/02/2011
% input: jointF: joint objective values of candidate solutions
%        jointP: joint candidate solutions
%        jointG: joint goal vectors
%        M: number of objectives
% output: scoreS: fitness of jointP
%         scoreG: fitness of jointG

function result = fitness_PICEAg(jointF,jointP,jointG,M);
jointFnum = size(jointF,1);
jointGnum = size(jointG,1);

goalMatrix = zeros(jointFnum,jointGnum);

for igoal = 1:jointGnum
    goalMatrix(:,igoal) = (sum(jointF<=rep(jointG(igoal,:),[jointFnum, 1]),2) == M);
end
gSolved = sum(goalMatrix,1);

% Compute score for each candidate solution
temp = (rep(gSolved, [jointFnum, 1]) .* goalMatrix);
scoreSmatrix = 1./ temp;
remInf = scoreSmatrix == Inf;
scoreSmatrix(remInf) = 0;
scoreS = sum(scoreSmatrix, 2);

% Compute score for goal vectors
scoreG = gSolved';
iNotSolved = find(scoreG == 0);
iSolved = find(scoreG > 0);
scoreG(iNotSolved) = 1;
scoreG(iSolved) = (scoreG(iSolved) - 1) / (jointFnum - 1);
scoreG = 1./(1+scoreG);
result = {scoreS,scoreG};
end
