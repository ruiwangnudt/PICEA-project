% Polynomial mutation operator
% for real number representations.

function postMute = polymut_sal(preMute, bounds, nm, mutProb);
% Inputs: preMute   - parent population (rows of individuals)
%         bounds    - decision variable bounds (lower; upper)
%         nm        - mutation parameter
%         mutProb   - probability of mutation of a single phenotype
%
% Output: postMute  - offspring population
%
% Reference: Deb, K. and Goyal, M., 1996, 'A combined genetic
%            adaptive search (GeneAS) for engineering design',
%            Computer Science and Informatics, 26(4), pp30-45.

% Initialise output:
postMute = preMute;
[noSols,noVar] = size(preMute);
% Only do stuff if mutation probability is greater than zero.
if mutProb > 0
    % Algorithm.
    % Loop round every element of preMute and test for mutation.
    for individual = 1:noSols
        for var = 1:noVar
            if rand <= mutProb
                % *** APPLY MUTATION ***
                % Obtain the necessary variables.
                r = rand;
                oldVal = preMute(individual,var);
                lBound = bounds(1,var);
                uBound = bounds(2,var);
                % Do the mutation, ensuring that variable bounds are not breached.
                if(r < 0.5)
                    delta = realpow(2.0 * r, 1.0 / (nm + 1.0)) - 1.0;
                    postMute(individual,var) = oldVal + (oldVal - lBound) * delta;
                else
                    delta = 1 - realpow(2.0 * (1.0 - r), 1.0 / (nm + 1.0));
                    postMute(individual,var) = oldVal + (uBound - oldVal) * delta;
                end
            end
        end
    end
end

