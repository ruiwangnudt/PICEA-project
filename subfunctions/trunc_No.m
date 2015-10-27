%
% TRUNC.M
%
% Truncation selection
%
% selected = trunc(fitness, threshold)
%
% Inputs: fitness   - fitness of each solution in population
%         noSelect -  number of  of population to be selected 
%
% Output: selected  - indices of selected solutions
%
% Wang rui, 1 July 2011
%
function selected = trunc_No(fitness, noSelect)

% Error checking on threshold.
if nargin<1
    error('at least 1 input');
elseif nargin<2
    return
elseif nargin<3
    [nsols, dummy] = size(fitness);
    if noSelect<1
        error('noSelect must be smaller than number of population');
    elseif noSelect> nsols
        noSelect = nsols;
    end
end
% Check size of population and convert threshold to an integer.
% Initialise return variable.
selected = [];
% Randomly permute the population to enable ties to be resolved
% randomly.
randI = randperm(nsols)';

% Sort randomised fitness values.
[sortedF sortedI] = sort(fitness(randI), 1, 'descend'); 

% Restore original ordering.
selected = randI(sortedI);

% Select the required quantity.
selected = selected(1:noSelect); 

end