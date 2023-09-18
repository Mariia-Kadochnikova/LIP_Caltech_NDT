function LIP_Caltech_NDT_generalization_analysis(binned_format_file_name)
% LIP_Caltech_NDT_generalization_analysis('C:\Projects\LIP_Caltech\NDT\filelist_290_tuned_units_95_runs_696_units_binned_data.mat');

%%   1.  Create strings listing where the toolbox and the tutoral data directories are and add the toolbox to Matlab's path

toolbox_dir = 'Y:\Sources\ndt.1.0.4';
%raster_file_directory_name = 'Zhang_Desimone_7objects_raster_data/';

addpath(toolbox_dir)
add_ndt_paths_and_init_rand_generator

run('LIP_Caltech_NDT_settings');
load(binned_format_file_name);


%%  3.  Create a classifier and a feature proprocessor object

the_classifier = max_correlation_coefficient_CL;
the_feature_preprocessors{1} = zscore_normalize_FP;  


%%  4. Let's first train the classifier to discriminate between objects at the upper location, and test the classifier with objects shown at the lower location


%%  4a.  create labels for which exact stimuli (ID plus position) belong in the training set, and which stimuli belong in the test set
%  id_string_names = {'instr', 'choice'}; 
%  
% for iID = 1:2   
%    the_training_label_names{iID} = {[id_string_names{iID} '_r']};
%    the_test_label_names{iID} = {[id_string_names{iID} '_l']};
% end

%     id_string_names_training = {'instr_r', 'instr_l'};
%     id_string_names_test = {'choice_r', 'choice_l'};
% for iID = 1:2 
%     the_training_label_names {iID} =  {[id_string_names_training{iID}]}; % id_string_names_training{iID};
%     the_test_label_names {iID} = {[id_string_names_test{iID}]};
% end


id_string_names = {'r', 'l'}; 
for iID = 1:2
    the_training_label_names{iID} = {['instr_' id_string_names{iID}]};
    the_test_label_names{iID} = {['choice_' id_string_names{iID}]};
end


%%  4b.  creata a generalization datasource that produces training data at the R location, and test data at the L location
num_cv_splits = 5; % 18, but at our number of data with this parameter more than 5 the code generates an error

specific_labels_names_to_use = 'combined_ID_position'; % use the combined ID and position labels

ds = generalization_DS(binned_format_file_name, specific_labels_names_to_use, num_cv_splits, the_training_label_names, the_test_label_names);
%ds.site_to_use = find_sites_with_k_label_repetitions(binned_labels.combined_ID_position, num_cv_splits, the_labels_to_use)

%%  4c. run a cross-validation decoding analysis that uses the generalization datasource we created to 
%         train a classifier with data from the upper location and test the classifier with data from the lower location


the_cross_validator = standard_resample_CV(ds, the_classifier, the_feature_preprocessors);
the_cross_validator.num_resample_runs = 10; %10

DECODING_RESULTS = the_cross_validator.run_cv_decoding;


% viewing the results suggests that they are above chance  (where chance is .1429)
DECODING_RESULTS.ZERO_ONE_LOSS_RESULTS.mean_decoding_results 





%%  5.  Training and Testing at all locations


mkdir C:\Projects\LIP_Caltech\Generalization_analysis\position_invariance_results;  % make a directory to save all the results
num_cv_splits = 5;
 
id_string_names = {'r', 'l'}; %{'instr', 'choice'};
pos_string_names_training = {'instr'};
pos_string_names_test = {'choice'};

 
for iTrainPosition = 1:2
    
   tic   % print how long it to run the results for training at one position (and testing at all three positions)
    
   for iTestPosition = 1:2
 
      % create the current labels that should be in the training and test sets 
      for iID = 1:2
            the_training_label_names{iID} = {[pos_string_names_training{iTrainPosition} '_' id_string_names{iID}]};
            the_test_label_names{iID} =  {[pos_string_names_test{iID} '_' pos_string_names{iTestPosition}]};
      end
 
      
      % create the generalization datasource for training and testing at the current locations
      ds = generalization_DS(binned_format_file_name, specific_labels_names_to_use, num_cv_splits, the_training_label_names, the_test_label_names);       
 
      % create the cross-validator
      the_cross_validator = standard_resample_CV(ds, the_classifier, the_feature_preprocessors);
      the_cross_validator.num_resample_runs = 10;
      
      the_cross_validator.display_progress.zero_one_loss = 0;     % let us supress all the output from the cross-validation procedure
      the_cross_validator.display_progress.resample_run_time = 0;
                 
      DECODING_RESULTS = the_cross_validator.run_cv_decoding;    % run the decoding analysis
 
      % save the results
      save_file_name = ['C:\Projects\LIP_Caltech\Generalization_analysis\position_invariance_results__train_pos' num2str(iTrainPosition) '_test_pos' num2str(iTestPosition)]; 
      save(save_file_name, 'DECODING_RESULTS')
 
   end
   
   toc
   
end






%% 6.  plot the results


position_names = {'instr', 'choice'};


for iTrainPosition = 1:2
    
    
    % load the results from each training and test location
    for iTestPosition = 1:2
        
        load(['C:\Projects\LIP_Caltech\Generalization_analysis\position_invariance_results__train_pos' num2str(iTrainPosition) '_test_pos' num2str(iTestPosition)]);
        all_results(iTrainPosition, iTestPosition) = DECODING_RESULTS.ZERO_ONE_LOSS_RESULTS.mean_decoding_results;
    %end
    
    figure (1)
    subplot(1, 2, iTrainPosition)
    result_names {iTestPosition} =  {['C:\Projects\LIP_Caltech\Generalization_analysis\position_invariance_results__train_pos' num2str(iTrainPosition) '_test_pos' num2str(iTestPosition)]};
    end
    
    plot_obj = plot_standard_results_object(result_names); % create the plot results object
    %plot_obj.significant_event_times = 0;                 % put a line at the time when the stimulus was shown
    plot_obj.plot_results;                                 % display the results
    

 
     
    
    % create a bar plot for each training lcoation
    figure (2)
    subplot(1, 2, iTrainPosition)
    bar(all_results(iTrainPosition, :) .* 100);
    
    title(['Train ' position_names{iTrainPosition}])
    
    ylabel('Classification Accuracy');
    set(gca, 'XTickLabel', position_names)
    xlabel('Test position')
    
    xLims = get(gca, 'XLim');
    line([xLims], [1/7 1/7] .* 100, 'color', [0 0 0]);    % put a line at the chance level of decoding    
    
end


set(gcf, 'position', [247   315   950   300])
