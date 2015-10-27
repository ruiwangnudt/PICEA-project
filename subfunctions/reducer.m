%
% REDUCER.M
%
% [newArchive, newIndex] = reducer(oldArchive, n, maxSize)
%
% SPEA2 clustering procedure.
% Reduces the number of solutions in the archive to
% a fixed maximum.
% according to the distance (density) of solutions
%
% This is an M-File for MATLAB.
% Written by Robin Purshouse, 08-Oct-2001
%
% Inputs: oldArchive - non-dominated archive population
%         n          - first n columns used for clustering 
%         maxSize    - the limit on the archive size
%
% Output: newArchive - the new, filtered, archive
%         newIndex   - (optional) surviving original indices
%
% Reference: Zitzler, E., Laumanns, M., and Thiele, L.,
%            2001, 'SPEA2: Improving the Strength Pareto
%            Evolutionary Algorithm', TIK-Report 103,
%            ETH Zurich.

function [newArchive, newIndex] = reducer(oldArchive, n, maxSize)

if nargout > 1
  newIndex = [];
end
  
% Handle the case of no data.
if isempty(oldArchive)
   newArchive = [];
   return
end

% Get the part of the archive used for clustering.
useArchive = oldArchive(:,1:n);

% Determine the current size of the archive.
[inds, dim] = size(useArchive);

% If the archive is to be totally wiped, do it now.
if(maxSize <= 0)
   newArchive=[];
   return
end

% Original indexing.
if nargout > 1
  newIndex = [1:inds]';
end

% If the archive is below the limit, return unchanged.
if(inds <= maxSize)
  newArchive = oldArchive;
  return
end

% Initialise new archive.
newArchive = oldArchive;

% Initialise the current size of the (new) archive.
currentSize = inds;

% Out of data flag - stop looking when we're reduced to just infinities.
outOfData = 0;

% Determine the Euclidean distances between solutions.
eucmat = l2matrix(useArchive);

% Ignore the leading diagonal (closest nearest neighbour of
% a solution is not itself).
eucmat(find(eye(inds)==1))=Inf;

% Keep identifying solutions to remove until the new archive is small enough.
while currentSize > maxSize

  % Work with a temporary copy of the L2 matrix.
  eucmatCopy = eucmat;
   % New vector to remove, so clear the decks.
  toRemove = 0;
  % First compare nearest neighbours, then next-nearest neighbours, then .. etc
  for k = 1:currentSize
    % Identify nearest neighbour to each solution (reading across the row)
    minInd = min(eucmatCopy, [], 2);
    % Identify the shortest of these.
    minVal = min(minInd);
    % Find the individuals who have this distance.
    minQuantity = find(minInd == minVal);
    % Find out how many there are for minimize value
    [minSize, dummy] = size(minQuantity);
    
        % If there's only one, then we've found the individual to remove.
    if minSize == 1  
      % We've found the one   Store the index of the individual to remove.
      toRemove = minQuantity;
      % No need to consider the next nearest neighbour.
      break;
    elseif minVal==Inf & k==1
      % No more comparisons possible.
      outOfData = 1;
      break;
      % Otherwise, we need to consider things at the next-nearest neighbour level.
    else
      % Perform twin check - no need to go checking any more levles if
      % all the remaining  arvectorse identical - we could possibly
      % consider this earlier to make things go even faster.
      if k > 1
        % Check for an all-twin situation.
        evalString = 'eucmatCopy(minQuantity(1),:) == eucmatCopy(minQuantity(2),:)';
        if(minSize > 2)
         for bitString = 2:minSize-1
             evalString = [evalString, ' & eucmatCopy(minQuantity(' num2str(bitString) '),:) == eucmatCopy(minQuantity(' num2str(bitString+1) '),:)'];
         end
        end
        
        removesting = 'toRemove = minQuantity (ceil(rand(1)*minSize))';
        eval([ 'if( ' evalString ');' removesting '; end ' ]);

        %x = 2;
        %y = 0 ;
        %evalstring = 'x == 2 && y == 0 ';
        %eval([ 'if (' evalstring '), y = 3 ; end' ])   
        %y
        
        % If the situation is all-twin, then we're done.
        if toRemove > 0
         break
        end
      end % if k>1
      
      % Otherwise, carry on to the next level.
      % Remove the current level from contention by setting related values to +infinity.
      index = find(eucmatCopy == minVal);
      eucmatCopy(index) = Inf;
      
      % We only need to consider the individuals that are tied. Ignore the others by
      % setting the entire row to +infinity.
      outOfContention = find(minInd ~= minVal);
      eucmatCopy(outOfContention,:) = Inf;
      
      % If we've run out of things to check, then stop.
      if isempty(find(eucmatCopy ~= Inf))
        k=inds;
      end  
      
    end
    
    % If we've gone through all possible levels of neighbourhood without
    % finding a discriminant, then choose randomly from whatever subset we've
    % managed to find.
    if k == inds
      % Choose one at random  ceil used to make value -> +infinite
      toRemove = minQuantity( ceil(rand(1)*minSize) );
      break;
    end
  end % for k=1:CurrentSize
  
  if outOfData == 0
    % Remove all information concerning the individual identified
    eucmat(toRemove,:) = [];
    eucmat(:, toRemove) = [];
    newArchive(toRemove,:) = [];
    if nargout > 1
      newIndex(toRemove) = [];
    end
    % Now there's one less individual to remove.
    currentSize = currentSize - 1;
  else
    % We're out of data, so we must just choose randomly from what's left.
    break;
  end
  
end% while currentSize > maxSize


% If the archive is too big still, remove the rest randomly.
[newArchiveSize, dump] = size(newArchive);
if newArchiveSize > maxSize
   if(outOfData == 0)
     fprintf('Error: having to perform random clustering when distance info remains.\n');
   end
   theseSurvive = randperm(newArchiveSize);
   theseSurvive = sort(theseSurvive(1:maxSize));
   newArchive = newArchive(theseSurvive,:);
   if nargout > 1
     newIndex = newIndex(theseSurvive);
   end
end
