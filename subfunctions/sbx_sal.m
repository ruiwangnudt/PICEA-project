%sbx.c
%Simulated Binary Crossover operator
%for real number representations.

function offspring = sbx_sal(parents, bounds, nc, option, xovProb, exchange, uniProb)
% Inputs: parents   - parent population (rows of individuals)
%         bounds    - decision variable bounds (lower; upper)
%         nc        - SBX parameter
%         option    - type of crossover
%                     (-1 = modify all, 0 = uniform, n = n-point)
%         xovProb   - probability of crossover between a pair
%         exchange  - flag to swap variables after SBX crossover
%                     with probability 0.5
%         uniProb   - probability of internal crossover in case of
%                     uniform crossover
% The default values:
% nc = 15.0; option = 1.0; xovProb = 0.7; exchange = 0.0; uniProb = 0.5;

% Output: offspring - the offspring resulting from the recombination

%Initialise output:

offspring = parents;
noVar = size(parents,2); % num of variables
noSols = size(parents,1); % num of solutions

% Algorithm.

%Depending on chosen option, set up a cross - don't cross array.
variablesToCross = zeros(1,noVar);

if ((xovProb ~= 0) & (option ~= 0))  | ((xovProb ~= 0) & (option == 0) & (uniProb ~= 0) ) 

    if (option == -1.0) || (option == 0.0) || (option == 1.0)
        parentSol = 1;
        while parentSol < noSols
            %Otherwise begin crossover procedure.

            %Roll a random number to see if crossover should occur.
            if rand <= xovProb

                if(option == 1)
                    % Single point crossover.
                    
                    %Determine crossover point.
                    %OUT = RANDINT(M,N,IRANGE) generates an M-by-N matrix of random integers.
                    crossoverPoint = randint(1,1,[1 noVar]);
                    
                    %Set up array.
                    for var = 1:crossoverPoint - 1
                        variablesToCross(var) = 0;
                    end
                    for var = crossoverPoint:noVar
                        variablesToCross(var) = 1;
                    end
                elseif option == 0
                    %Uniform crossover.
                    % Set up array.
                    for var = 1:noVar
                        if rand<= uniProb
                            variablesToCross(var) = 1;
                        else
                            variablesToCross(var) = 0;
                        end
                    end
                elseif(option == -1)
                    % Cross everything.
                    
                    % Set up array.
                    for var = 1:noVar
                        variablesToCross(var) = 1;
                    end
                end
                %all the above is to mark cross position
                
                %Do the crossover.
                for var = 1:noVar
                    %If this is a crossover site, perform crossover.
                    if variablesToCross(var) == 1

                        %Extract current parent values.
                        parent1 = parents(parentSol,var);
                        parent2 = parents(parentSol+1,var);

                        %Extract variable bounds.
                        uBound = bounds(2,var);
                        lBound = bounds(1,var);

                        %Compute parameter from distribution.
                        randNo = rand(1,1);
                        if randNo <= 0.5
                            xovParam = realpow(2.0 * randNo, 1.0 / (nc + 1.0) );
                        else
                            %???????/ why is the 2
                            xovParam = realpow(1.0 / (2 * (1.0 - randNo) ), 1.0 / (nc + 1.0) );
                        end

                        %Compute offspring values.
                        offspring1 = 0.5 * ( (1.0 + xovParam) * parent1 + (1.0 - xovParam) * parent2 );
                        offspring2 = 0.5 * ( (1.0 - xovParam) * parent1 + (1.0 + xovParam) * parent2 );

                        %If offspring are infeasible then set to boundary parameters.
                        if(offspring1 > uBound) offspring1 = uBound;end
                        if(offspring1 < lBound) offspring1 = lBound;end
                        if(offspring2 > uBound) offspring2 = uBound;end
                        if(offspring2 < lBound) offspring2 = lBound;end

                        %If the exchange option is activated, then perform the exchange with
                        %probability 0.5.
                        if (exchange == 1.0) & (rand() <= 0.5)
                            copyChild = offspring1;
                            offspring1 = offspring2;
                            offspring2 = copyChild;
                        end
                        %Store the results.
                        offspring(parentSol,var) = offspring1;
                        offspring(parentSol+1,var) = offspring2;
                    end
                end
                %Go to the next pair of parents.
                parentSol  = parentSol + 2;
            end
        end
    end
end