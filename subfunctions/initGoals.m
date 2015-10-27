% Generate goal vectors 
% input: Ngoal: the no. of goal vectors
%       fEasy: upper goal vector
%       fHard: upper goal vector
% output: goals: generated goal vectors

function goals = initGoals(Ngoal,fEasy,fHard)
objvNo = size(fEasy,2);
goals = rep(fEasy,[Ngoal,1])-rand(Ngoal, objvNo) .* rep((fEasy-fHard),[Ngoal,1]);
end
