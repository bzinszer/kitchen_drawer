%% Quick'n'dirty script for generating statistical learning sequences
% Right now, it takes words as n-grams (sets of co-occurring units of fixed
% length, like 3-gram ABC or 4-gram ABCD). 

% Follows rules of Arcuili & Simpson (2011, 2012) for:
% - Repeated character trials
% - Not repeating the same word twice in a row
% - Not repeating the same sequence of two words twice, e.g.:
%   ABC DEF ABC DEF

% Search is a bit brute-forcy in that it randomly moves violations
% somewhere else in the list and re-evaluates to see whether the list meets
% all requirements after the changes. If the maximum number of iterations 
% is exceeded, then the list is abandoned and a new random shuffle is
% attempted instead.

word_strings = {'ABC';'DEF';'GHI';'JKL'}; % Inventory of the words
nreps_word_strings_norm = 18; % Number of times each word should appear in the stream

% Number of times each word should appear as a character-repeat catch. This
% value must be evenly divisible by the length of the word.
nreps_word_strings_rept = 6;  

number_unique_lists = 4; % How many unique streams to generate
max_iter = 10; % How many iterations of the search procedure to attempt before re-shuffling instead

%% Begin

% Initialize an empty cell array that will contain all the words and
% mutated (repetition-trial) words
inventory = cell(size(word_strings,1)*nreps_word_strings_norm + size(word_strings,1)*nreps_word_strings_rept,1);

for i = 1:size(word_strings,1)
    
    % Create the normal (non-mutated, non-repetition) words
    norms = repmat(word_strings(i),nreps_word_strings_norm,1);
    
    % Initalize the empty cell array for the mutated (repetition) words
    mutants = cell(nreps_word_strings_rept,1);
    
    % For each of the characters in a word string, repeat it once to create
    % a mutant. Create as many of these mutants as there are total
    % repetition strings per word / number of characters that have to get
    % this repetition treatment.
    % Ex: 6 reps / 3 letter word = 2 reps per letter
    for j = 1:length(word_strings{i})
        
        % The mutation starts off as a normal string
        mutation = word_strings{i};
        % Pick the character for mutation, and just duplicate it by bumping
        % the rest of the string (including mutant character) back by one.
        mutation(j+1:end+1) = mutation(j:end);
        
        % Repeat the mutation the correct number of times to evenly
        % distribute across the characters of the string
        mutation = repmat({mutation},nreps_word_strings_rept/length(word_strings{i}),1);
        
        % Fill in to the mutants array
        first_empty = find(cellfun(@isempty,mutants),1);
        last_empty = first_empty-1+length(mutation);
        mutants(first_empty:last_empty) = mutation;
    end
    
    % Merge the normal and mutants arrays
    new_entry = [norms;mutants];
    
    % Fill them into the full inventory array
    first_empty = find(cellfun(@isempty,inventory),1);
    last_empty = first_empty-1+length(new_entry);
    inventory(first_empty:last_empty) = new_entry;
    
end

shuffled_lists = cell(length(inventory),number_unique_lists);
for listnum = 1:number_unique_lists
    shuffled_lists(:,listnum) = shuffle_array(inventory,max_iter);
end

function shuffled = shuffle_array(inventory,max_iter)
% Start out by shuffling the inventory. This shuffle likely won't satisfy
% all the requirements, but it's nice to start with some pseudorandomness
shuffled = inventory(randperm(length(inventory)));

items = cellfun(@unique,shuffled,'UniformOutput',false);
reps = sum(strcmp(items(2:end),items(1:end-1)));
pairs = [items(1:2:end),items(2:2:end)];
sets = sum(strcmp(pairs(2:end,1),pairs(1:end-1,1)) & strcmp(pairs(2:end,2),pairs(1:end-1,2)) );
iter = 0;

while reps || sets
    iter = iter+1;
    fprintf('Iteration %g: %g reps & %g sets found.\n',iter,reps,sets);
    
    % Requirement 0: Don't start on a mutated word
    if length(shuffled{1}) > length(unique(shuffled{1}))
        shuffled(end+1) = shuffled(1);
        shuffled(1) = [];
        fprintf('\tSwapped entry %g to the end\n',1);
    end
    
    for k = 2:length(shuffled)
        
        % Requirement 1: A word cannot repeat
        while strcmp(unique(shuffled{k}),unique(shuffled{k-1}))
            % Move the violating word to a random position
            randpos = randsample(length(shuffled),1);
            shuffled(randpos+1:end+1) = shuffled(randpos:end);
            if k>=randpos
                shuffled(randpos) = shuffled(k+1);
                shuffled(k+1) = [];
            else
                shuffled(randpos) = shuffled(k);
                shuffled(k) = [];
            end
            fprintf('\tSwapped entry %g to position %g\n',k,randpos);
            
        end
        
        % Requirement 2: A pair of words cannot follow each other twice, ABAB
        if k>=4
            while strcmp(unique(shuffled{k}),unique(shuffled{k-2})) && strcmp(unique(shuffled{k-1}),unique(shuffled{k-3}))
                if k<length(shuffled)-2
                    shuffled(end+1:end+2) = shuffled(k-1:k);
                    shuffled(k-1:k) = [];
                    fprintf('\tSwapped pair %g to the end\n',k);
                else
                    shuffled(end+1) = shuffled(k-1);
                    shuffled(k-1) = [];
                    fprintf('\tSwapped pair %g with each other\n',k);
                end
            end
        end
    end
    items = cellfun(@unique,shuffled,'UniformOutput',false);
    reps = sum(strcmp(items(2:end),items(1:end-1)));
    pairs = [items(1:2:end),items(2:2:end)];
    sets = sum(strcmp(pairs(2:end,1),pairs(1:end-1,1)) & strcmp(pairs(2:end,2),pairs(1:end-1,2)) );
    fprintf('Iteration %g: %g reps & %g sets remaining.\n',iter,reps,sets);
    
    if iter>=max_iter && (reps || sets)
        iter = 0;
        fprintf('This one sucks. Starting over.\n');
        shuffled = shuffle_array(shuffled);
        items = cellfun(@unique,shuffled,'UniformOutput',false);
        reps = sum(strcmp(items(2:end),items(1:end-1)));
        pairs = [items(1:2:end),items(2:2:end)];
        sets = sum(strcmp(pairs(2:end,1),pairs(1:end-1,1)) & strcmp(pairs(2:end,2),pairs(1:end-1,2)) );
    end
    
end
end


