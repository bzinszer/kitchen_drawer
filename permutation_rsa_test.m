function [accuracies, solutions] = permutation_rsa_test(test_matrix, training_matrix)
% PERMUTATION_RSA_TEST Compares all permutations of an r-by-r similarity
% structure (matrix) to another structure to find the permutation that most
% closely correlates. Do not use for matrices larger than 10-by-10 because
% the number of permutations grows factorially.
%
%   ACC = PERMUTATION_RSA_TEST( M1, M2 ) returns the accuracy (proportion
%   of correctly-matched rows) from the permutation of the test matrix M1 
%   with the highest correlation to the training matrix M2.
%
%   M1 and M2 must be square, symmetric, and the same size, but they may be
%   populated with any distance values (Pearson R, Fisher R-to-Z, euclidean
%   distance, etc).
%
%   M1 may contain a third dimension to allow testing of multiple
%   structures (e.g., multiple subjects) against the training matrix M2.
%   Results for each structure (along M1's first dimension) will be
%   returned as rows.
%
%   To view the permutation of the test matrix M1 that best correlated with
%   the training matrix M2, add BESTP to the output.
%   [ ACC, BESTP ] = PAIRWISE_RSA_TEST( M1, M2 )

%% Sanity Check
if numel(test_matrix(:,:,1))>100 || numel(training_matrix)>100
    disp('Input matrices are too large. Matrices larger than 10-by-10 will overload memory or take too long to process.');
    return
end

num_subjs = size(test_matrix,3);
test_subjs = 1:num_subjs;
num_classes = size(test_matrix,1);

group_nsim_vect = training_matrix(logical(tril(training_matrix+1,-1)));
 
all_perms = perms(1:num_classes);
best_perms_by_subj = nan(num_subjs,num_classes);
best_corrs_by_subj = nan(num_subjs,1);
subjwise_list_corrs = nan(size(all_perms,1),num_subjs);
subjwise_list_acc = nan(size(all_perms,1),num_subjs);
 
key = 1:num_classes;
 
for subj = 1:num_subjs,
          
    for perm_id = 1:size(all_perms,1),
         
        perm = all_perms(perm_id,:);
        this_permed_nsim = test_matrix(perm,perm,subj);
        this_permed_nsim = this_permed_nsim(logical(tril(this_permed_nsim+1,-1)));
        corr_this_perm = corr(this_permed_nsim,group_nsim_vect);
        subjwise_list_corrs(perm_id,subj) = corr_this_perm;
        subjwise_list_acc(perm_id,subj) = sum(perm==key)/num_classes;
         
    end
     
    best_corrs_by_subj(subj) = max(subjwise_list_corrs(:,subj));
    best_perms_by_subj(subj,:) = all_perms(subjwise_list_corrs(:,subj)==best_corrs_by_subj(subj),:);
     
end
 
accuracies = sum(best_perms_by_subj == repmat(key,num_subjs,1),2)/num_classes;
solutions = best_perms_by_subj;
 