% Number of time steps (seconds in a day)
num_steps = 86400;

% Initialize variables

E_threshold_max = 100;  % Example threshold values
E_threshold_min = 20;
E_harvested = zeros(num_steps, 1);
E_consumed_day = zeros(num_steps, 1);
E_consumed_night = zeros(num_steps, 1);
E_available = zeros(num_steps, 1);
E_outage = zeros(num_steps, 1);

% Day and night definitions
day_start = 4 * 3600;  % 4 AM in seconds
day_end = 17 * 3600;   % 5 PM in seconds

% Simulation loop
for t = 2:num_steps
    % Determine if it's daytime
    is_daytime = (t >= day_start && t <= day_end);
    
    % Daytime Operation
    if is_daytime
        % Calculate excess energy during the day
        E_excess_day = E_harvested(t) - E_consumed_day(t);
        if E_excess_day >= 0
            % Store excess energy in the battery and cumulate during the day
            E_available(t) = E_available(t-1) + E_excess_day;
        else
            % Avoid negative excess energy
            E_excess_day = 0;
            if E_available(t-1) - E_threshold_max < E_consumed_day(t)
                % Set outage indicator to 1
                E_outage(t) = 1;
            end
        end
    end
    
    % Nighttime Operation
    if ~is_daytime
        if E_available(t-1) < E_consumed_night(t) || E_available(t-1) < E_threshold_min
            % Set outage indicator to 1 during the night
            E_outage(t) = 1;
        end
    end
end

% Plotting
figure;

% Subplot 1: Outage Status at Each Second
subplot(2, 1, 1);
stairs(E_outage);
title('Outage Status (0: No Outage, 1: Outage)');
xlabel('Time (seconds)');
ylabel('Outage Status');

% Subplot 2: Outage Percentage During the Day
subplot(2, 1, 2);
outage_percent = sum(E_outage) / num_steps * 100;
bar(1, outage_percent, 'r');
title('Outage Percentage During the Day');
xlabel('Day');
ylabel('Outage Percentage (%)');
ylim([0 100]);
