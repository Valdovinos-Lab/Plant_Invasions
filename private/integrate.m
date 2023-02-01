function [final_parameters, generate_figs] = integrate(file_name, initial_state, tspan, generate_figs)

    global J_pattern simulation extinct_level_p network_metadata 

    % determine dimensions of dataset
    [row, col] = size(network_metadata.data);

    % integrate the dynamic model
    options = odeset('JPattern', J_pattern, 'NonNegative', 1:(2 * row) + col);
    [time, parameters] = ode15s(@apply_equations, tspan, initial_state, options);
    
    % access final row of parameter values
    final_parameters = parameters(end,:)';
    
    % plot time series follow invasion once at the first time a successful invasion occures
     [plants, nectar, animals, alphas] = expand_full(parameters);
     if (generate_figs == 0)
         if (simulation == 2) 
             if (plants(end, 1) > extinct_level_p)
                 plot_timeseries(file_name, time, plants, nectar, animals, alphas, row, col);
                 generate_figs = 1;
             end
         end
     end
end

