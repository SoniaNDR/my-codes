% Number of time steps (seconds in a day)
num_steps_per_day = 86400;



% Initialize variables
num_days = 30; % Assuming a 30-day month
E_threshold_max = 100;  % Example threshold values
E_threshold_min = 20;
E_outage = zeros(num_days, num_steps_per_day);
E_available = zeros(num_days, num_steps_per_day);

% Day and night definitions
day_start = 4 * 3600;  % 4 AM in seconds
day_end = 17 * 3600;   % 5 PM in seconds

% Generate random prediction data for each day
E_harvested_predicted = rand(num_days, num_steps_per_day);
E_consumed_day_predicted = rand(num_days, num_steps_per_day);
E_consumed_night_predicted = rand(num_days, num_steps_per_day);

% Simulation loop
for day = 1:num_days
    for t = 2:num_steps_per_day
        % Determine if it's daytime
        is_daytime = (t >= day_start && t <= day_end);

        % Daytime Operation
        if is_daytime
            % Predicted harvested and consumed energy for the current day
            E_harvested = E_harvested_predicted(day, t);
            E_consumed_day = E_consumed_day_predicted(day, t);
            
            % Calculate excess energy during the day
            E_excess_day = E_harvested - E_consumed_day;
            if E_excess_day < 0 && E_available(day, t-1) - E_threshold_max < E_consumed_day
                % Set outage indicator to 1
                E_outage(day, t) = 1;
            end
        end

        % Nighttime Operation
        if ~is_daytime
            % Predicted consumed energy for the current night
            E_consumed_night = E_consumed_night_predicted(day, t);
            
            if E_available(day, t-1) < E_consumed_night || E_available(day, t-1) < E_threshold_min
                % Set outage indicator to 1 during the night
                E_outage(day, t) = 1;
            end
        end
        
        % Update available energy for the next time step
        if t < num_steps_per_day
            E_available(day, t) = E_available(day, t-1) - E_consumed_night + E_harvested_predicted(day, t);
        end
    end
end

% Calculate outage percentage for each day
outage_percentage_per_day = sum(E_outage, 2) ./ num_steps_per_day * 100;

% Plotting
figure;
plot(1:num_days, outage_percentage_per_day, 'bo-', 'LineWidth', 2);
title('Outage Percentage for Each Day');
xlabel('Day of the Month');
ylabel('Outage Percentage (%)');
xlim([1 num_days]);
ylim([0 100]);
grid on;
