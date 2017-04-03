function subject_level_accuracies = decode_rsa_leaveoneout(test_subjs_mat, decoding_method)

% DECODE_RSA_LEAVEONEOUT Perform n-fold cross-validation over a set of n
% similarity structures (e.g., one structure for each of n subjects.
%   ACC = PAIRWISE_RSA_LEAVEONEOUT( M ) returns the set of pairwise 
%   decoding accuracies in a vector for n structures.
%
%   M must be a 3-dimensional matrix containing an r-by-r similarity matrix
%   in the first two dimensions, stacked n-times in the third dimension for
%   n structures (e.g., n subjects). E.g., for 8 stimulus classes in 10
%   participants, size(M) would be [8, 8, 10].
%
%   DECODE_RSA_LEAVEONEOUT( M, method ) takes the string METHOD to
%   determine what type of decoding to attempt. Currently two options are
%   available:
%
%       empty-string / default is pairwise
%
%       'pairwise' Will run all pairwise comparisons of the rows in the
%       r-by-r similiarity structure (see PAIRWISE_RSA_TEST)
%
%       'permutation' Will compare all permutations of the rows and columns
%       in the r-by-r similarity structure (see PERMUTATION_RSA_TEST).
%       WARNING: Do not use permutation for matrix larger than 10x10.
%   
%   See also PAIRWISE_RSA_TEST, PERMUTATION_RSA_TEST.

%% Prep some basic values
number_of_subjects = size(test_subjs_mat,3);
list_of_subjs = 1:number_of_subjects;
subject_level_accuracies = nan(number_of_subjects,1);

if ~exist('decoding_method','var'),
    decoding_method = 'pairwise';
end


%% N-fold cross-validation 
% Loop through the n subjects, exclude one subject, and attempt to decode
% that subject based on the remaining group.

for this_sub = list_of_subjs,
    
    this_subj_structure = test_subjs_mat(:,:,this_sub);
    mean_group_structure = nanmean(test_subjs_mat(:,:,list_of_subjs(list_of_subjs~=this_sub)),3);
    
    switch decoding_method
        case 'pairwise'
            decoding_results = pairwise_rsa_test(this_subj_structure,mean_group_structure);
        case 'permutation'
            decoding_results = permutation_rsa_test(this_subj_structure,mean_group_structure);
    end
    
    subject_level_accuracies(this_sub) = mean(decoding_results);
    
end
