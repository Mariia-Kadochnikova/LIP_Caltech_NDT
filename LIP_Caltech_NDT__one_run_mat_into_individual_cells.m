function [binned_data, binned_labels, binned_site_info] = LIP_Caltech_NDT__one_run_mat_into_individual_cells(mat_filename)
% [binned_data, binned_labels, binned_site_info] = LIP_Caltech_NDT__one_run_mat_into_individual_cells('Y:\Projects\LIP_Caltech\Gutalin\20110126\GU_20110126_1-01.psth.mat');

% This code loads one psth.mat file and converts it to a cell array (where N is number of units), one cell per unit, according to NDT binned data format.

run('LIP_Caltech_NDT_settings');

if ~exist(OUTPUT_PATH,'dir')
    mkdir(OUTPUT_PATH);
end

load(mat_filename);
% load('Y:\Projects\LIP_Caltech\Gutalin\20110126\GU_20110126_1-01.psth.mat'); % once debug is complete, comment this line and enable the line above


% count number of units in this run
N_units =  numel(unitinfo);

if ~exist('PSTHinstr','var')
    PSTHinstr       = PSTH_mem_instr;
    PSTHchoice      = PSTH_mem_choice;
end


bins = PSTHinstr(1,1).bins;


% adjust timeline here if needed
% ...

% labels
labels = {'instr','instr','choice','choice'};
psitions = {'r','l','r','l'};
combined = {'instr_r','instr_l','choice_r','choice_l'};

for u = 1:N_units % for each unit

    % 4 conditions
    
    if size(PSTH_mem_instr,2) > 2 % 8 targets, sort to right: 2, 3, 4 and left: 6, 7, 8
        
        PSTHinstr_right = [PSTHinstr(u,2).histo_trial; PSTHinstr(u,3).histo_trial; PSTHinstr(u,4).histo_trial];
        PSTHinstr_left  = [PSTHinstr(u,6).histo_trial; PSTHinstr(u,7).histo_trial; PSTHinstr(u,8).histo_trial];
        PSTHchoice_right = [PSTHchoice(u,2).histo_trial; PSTHchoice(u,3).histo_trial; PSTHchoice(u,4).histo_trial];
        PSTHchoice_left  = [PSTHchoice(u,6).histo_trial; PSTHchoice(u,7).histo_trial; PSTHchoice(u,8).histo_trial];
        
        
    else % 2 targets
        
        PSTHinstr_right = PSTHinstr(u,1).histo_trial ; % instr right
        PSTHinstr_left = PSTHinstr(u,2).histo_trial ; % instr left
        PSTHchoice_right = PSTHchoice(u,1).histo_trial ; % choice right
        PSTHchoice_left = PSTHchoice(u,2).histo_trial ; % choice left
        
    end
    
    %create binned_data
    binned_data{u} = vertcat(PSTHinstr_right, PSTHinstr_left, PSTHchoice_right, PSTHchoice_left);
   
    binned_labels.stimulus_ID{u} = horzcat(repmat(labels(1),1, size(PSTHinstr_right,1)),...
                                           repmat(labels(2),1, size(PSTHinstr_left,1)),...
                                           repmat(labels(3),1, size(PSTHchoice_right,1)),...
                                           repmat(labels(4),1, size(PSTHchoice_left,1)));
    
    binned_labels.stimulus_position{u} = horzcat(repmat(psitions(1),1, size(PSTHinstr_right,1)),...
                                                 repmat(psitions(2),1, size(PSTHinstr_left,1)),...
                                                 repmat(psitions(3),1, size(PSTHchoice_right,1)),...
                                                 repmat(psitions(4),1, size(PSTHchoice_left,1)));
                                                
    binned_labels.combined_ID_position{u} = horzcat(repmat(combined(1),1, size(PSTHinstr_right,1)),...
                                                    repmat(combined(2),1, size(PSTHinstr_left,1)),...
                                                    repmat(combined(3),1, size(PSTHchoice_right,1)),...
                                                    repmat(combined(4),1, size(PSTHchoice_left,1)));
        

    %create binned_site_info
    binned_site_info.session_ID{u}          = unitinfo(u).session;
    binned_site_info.recording_channel{u}   = unitinfo(u).channame; 
    binned_site_info.unit{u}                = unitinfo(u).ucellname;
    binned_site_info.alignment_event_time(u) = 1800;
    
    
    
end 

binned_site_info.binning_parameters.raster_file_directory_name = OUTPUT_PATH;
binned_site_info.binning_parameters.bin_width = (bins(2) - bins(1))*1000; % in ms
binned_site_info.binning_parameters.sampling_interval =  (bins(2) - bins(1))*1000;
binned_site_info.binning_parameters.start_time = 0; % ms
binned_site_info.binning_parameters.end_time = 7000; % ms
binned_site_info.binning_parameters.the_bin_start_times = bins;
binned_site_info.binning_parameters.the_bin_widths = repmat((bins(2) - bins(1))*1000,size(bins));
binned_site_info.binning_parameters.alignment_event_time = 1800; % time of cue onset

