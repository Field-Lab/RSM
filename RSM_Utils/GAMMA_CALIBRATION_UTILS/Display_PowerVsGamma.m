function[ ] = Display_PowerVsGamma( red_S, green_S, blue_S, gray_S, Model, N_bits )


% Make models
finegrain_gunvals = linspace(0, 1, 2^N_bits); 

[fit_radpow_red] = Model( [red_S.slope, red_S.intercept], finegrain_gunvals, N_bits);
[fit_radpow_green] = Model( [green_S.slope, green_S.intercept], finegrain_gunvals, N_bits);
[fit_radpow_blue] = Model( [blue_S.slope, blue_S.intercept], finegrain_gunvals, N_bits);
[fit_radpow_gray] = Model( [gray_S.slope, gray_S.intercept], finegrain_gunvals, N_bits);

fit_gunsum = fit_radpow_red + fit_radpow_green + fit_radpow_blue;

max_val = max([max(fit_radpow_red), max(fit_radpow_green), max(fit_radpow_blue)]);


% Plot each gun with its associated best fit line
figure

plot(red_S.gun_vals, red_S.avgraw_radpow_data, 'r.');
hold
plot(finegrain_gunvals, fit_radpow_red, 'r--');

plot(green_S.gun_vals, green_S.avgraw_radpow_data, 'g.');
plot(finegrain_gunvals, fit_radpow_green, 'g--');

plot(blue_S.gun_vals, blue_S.avgraw_radpow_data, 'b.');
plot(finegrain_gunvals, fit_radpow_blue, 'b--');
hold

title('Color Linearity Test: Data-> points, Fit-> dashed-lines');
xlabel('Gun Values');
ylabel('Radiant Power');
axis([-0.05, 1.05, 0, 1.05*max_val]);

% Plot grayscale data and predicted grayscale data


figure

plot(gray_S.gun_vals, gray_S.avgraw_radpow_data, 'k.');
hold
plot(finegrain_gunvals, fit_gunsum, 'k--');
hold

title('Grayscale Linearity Test: Data-> points, Sum of color-data fits-> dashed-lines');
xlabel('Gun Values');
ylabel('Radiant Power');
axis([-0.05, 1.05, 0, 1.05*max(fit_gunsum)]);