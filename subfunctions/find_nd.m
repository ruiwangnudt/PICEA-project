%FIND_ND	Find non-dominated points 
%
%	Syntax:
%		       ix = find_nd(ObjV);
%		[ix1,ix2] = find_nd(ObjV1,ObjV2);
%
%	In the first form, ix is a zero-one column vector indexing those
%	rows of ObjV which are relatively non-dominated, assuming a
%	minimization problem. ObjV(ix,:) contains only non-dominated rows.
%
%	In the second form, ix1 is a zero-one column vector indexing those
%	rows of ObjV1 which: 1) are relatively non-dominated and 2) are not
%	dominated by any row in ObjV2. ix2 is also a zero-one column vector,
%	indexing those rows of ObjV2 which are not dominated by any row in
%	ObjV1. ObjV2 must contain only relatively non-dominated rows for
%	the matrix [ObjV2(ix2,:) ; ObjV1(ix1,:)] to have the same property.
%
%	When duplicates are found, only one is kept.

% Author: Carlos Fonseca
% 	  Unversity of Sheffield
%	  10 March 1995
