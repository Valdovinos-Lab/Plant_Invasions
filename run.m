%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main function for performing a series of simulations of plant invasions.
%   -simulations are performed only using death case 3 and invader types
%   3, 4, and 8 because these were the only groups for which species 
%   invasions were successful and therefore saves computation time
%   -simulations are also only performed using attachment algorithm 1
%   (random) because results are qualtiatively similar for each algorithm
%   -simulations are performed over the range of user specified networks 
%   ranging from 1-1200
%
% Author:
%   Sabine Dritz: sjdritz@ucdavis.edu
%
% Date:
%   4/16/2022
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Run a suite of simulations
function [] = run(networks)

    % if no networks were specified, use all of them
    if nargin < 1
        networks = 1:1:1200;
    end

    % network range 
    for network_index = 1:length(networks)
        network = networks(network_index);
        
        % run for mortality situation 3 defined below:
        % 1) animals high mortality
        % 2) plants high mortality
        % 3) animals and plants low mortality
        % 4) animals and plants high mortality
        for death_case = 3
            
            % run for attachment algorithm 1 defined below:
            % 1) links randomly
            % 2) links to specialists
            % 3) links to generalists
            for link_case = 1
                
                % runs for invader types 3, 4, and 8 defined below:
                % 1) specialists
                % 2) high pollen producing specialists
                % 3) high reward producing specialists
                % 4) high pollen and reward producing specialists
                % 5) generalists
                % 6) high pollen producing generalists
                % 7) high reward producing generalists
                % 8) high pollen and reward producing generalists
                inv_types = [3, 4, 8];
                for inv_index = 1:3
                    inv_type = inv_types(inv_index);
                    
                    % Run simulation 
                    file_name = [network, death_case, link_case, inv_type];
                    [Alpha, P, A] = run_inv_PC(file_name);
    
                    % Write data to a csv file
                    plant_data = [full(P{1}), full(P{2})];
                    animal_data = [full(A{1}), full(A{2})];
                    alpha_data = [full(Alpha{1}), full(Alpha{2})];                
                    writematrix(plant_data, sprintf('data/P_n%04d_m%d_l%d_i%d.csv', file_name));
                    writematrix(animal_data, sprintf('data/A_n%04d_m%d_l%d_i%d.csv', file_name));
                    writematrix(alpha_data, sprintf('data/Alpha_n%04d_m%d_l%d_i%d.csv', file_name));
                end
            end
        end
    end
end               
