function [r, p] = corr_tril(A, B, method)

% Correlates the lower triangles of any two matrices using the selected
% method. If no method is specified, Pearson correlation will be used.

sizeA = size(A);
sizeB = size(B);
if ~exist('method','var'),
    method = 'Pearson';
end

if sum(size(A) == size(B)) == 2,
    trilA = A(logical(tril(true(sizeA),-1)));
    trilB = B(logical(tril(true(sizeB),-1)));
    [r, p] = corr(trilA, trilB,'type',method,'rows','pairwise');
else
    disp('Matrices A and B must two dimensional` and same size');
    return
end
