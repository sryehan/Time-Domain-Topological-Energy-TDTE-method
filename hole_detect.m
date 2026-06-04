% FDTD Simulation of Wave Reaction at 16 Holes
% Parameters based on Dominguez et al. (2010)

%% 1. Parameters Setup
clear; close all; clc;

width = 90; dh = 0.2; 
depth = 25; 
nx = round(width/dh); ny = round(depth/dh);

c = 3.0; % mm/micro-sec (Speed of sound scaled)
dt = dh / (c * sqrt(2)) * 0.9; 

%% 2. Holes Data (16 points from Table 2)
x_coords = [10, 13, 16, 23, 28, 33, 38, 43, 48, 53, 58, 63, 68, 74, 79, 85];
y_depths = [15.0, 13.0, 10.5, 8.5, 6.5, 4.5, 6.5, 8.2, 10.5, 10.4, 10.5, 10.4, 10.4, 8.6, 6.5, 5.0];

% Convert to grid coordinates
hole_ix = round(x_coords/dh);
hole_iy = round(y_depths/dh);

% Create hole mask for visualization
hole_mask = zeros(nx, ny);
for h = 1:length(hole_ix)
    if hole_ix(h) > 0 && hole_ix(h) <= nx && hole_iy(h) > 0 && hole_iy(h) <= ny
        hole_mask(hole_ix(h), hole_iy(h)) = 1;
    end
end

% Create outline mask (white outlines around holes)
outline_mask = zeros(nx, ny);
for h = 1:length(hole_ix)
    ix = hole_ix(h);
    iy = hole_iy(h);
    
    if ix > 0 && ix <= nx && iy > 0 && iy <= ny
        % Create 3x3 white outline around each hole
        for dx = -1:1
            for dy = -1:1
                nx_idx = min(max(ix + dx, 1), nx);
                ny_idx = min(max(iy + dy, 1), ny);
                outline_mask(nx_idx, ny_idx) = 1;
            end
        end
    end
end

%% 3. Initialize Fields
p = zeros(nx, ny); p_prev = p; p_next = p;

% Source Array at the bottom
source_y = ny - 10;
source_x = round(10/dh):round(80/dh);

%% 4. Setup Video Recording
video_filename = 'wave_holes_simulation.mp4';
v = VideoWriter(video_filename, 'MPEG-4');
v.FrameRate = 30; % Frames per second
v.Quality = 95; % Quality (0-100)
open(v);

%% 5. Simulation Loop
freq = 1.0; % MHz
T = 400; 

% Create figure with adjusted size
figure('Color', 'w', 'Position', [100, 100, 900, 500]);

% Store hole outline positions for plotting
hole_positions_x = hole_ix * dh;
hole_positions_y = hole_iy * dh;

for tt = 1:T
    % FDTD Equation
    p_next(2:end-1, 2:end-1) = 2*p(2:end-1, 2:end-1) - p_prev(2:end-1, 2:end-1) + ...
        (c*dt/dh)^2 * (p(3:end, 2:end-1) + p(1:end-2, 2:end-1) + ...
        p(2:end-1, 3:end) + p(2:end-1, 1:end-2) - 4*p(2:end-1, 2:end-1));

    % Excitation Pulse
    pulse = sin(2*pi*freq * tt*dt) * exp(-((tt*dt - 1.5)/0.6)^2);
    p_next(source_x, source_y) = p_next(source_x, source_y) + pulse;

    % Reflection at 16 Holes (The "Reaction")
    for h = 1:length(hole_ix)
        ix = hole_ix(h);
        iy = hole_iy(h);
        if ix > 0 && ix <= nx && iy > 0 && iy <= ny
            p_next(ix, iy) = 0; % Hard boundary
        end
    end

    % Update buffers
    p_prev = p; p = p_next;
    
    % Visualization
    if mod(tt, 1) == 0
        % Create main pressure field plot
        imagesc((1:nx)*dh, (1:ny)*dh, p'); 
        colormap(jet(256)); 
        caxis([-0.2 0.2]); 
        hold on;
        
        % Plot white outlines around holes
        scatter(hole_positions_x, hole_positions_y, 60, 'w', ...
                'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 0.5);
        
        % Add smaller white centers for better visibility
        scatter(hole_positions_x, hole_positions_y, 40, 'w', ...
                'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 0.5);
        
        hold off;
        
        axis equal tight;
        title(['FDTD Wave Simulation | Time Step: ', num2str(tt), ...
               ' / ', num2str(T), ' | Frequency: ', num2str(freq), ' MHz'], ...
               'FontSize', 12, 'FontWeight', 'bold');
        xlabel('Width (mm)', 'FontSize', 11);
        ylabel('Depth (mm)', 'FontSize', 11);
        
        % Add colorbar
        cb = colorbar;
        ylabel(cb, 'Pressure Amplitude', 'FontSize', 10);
        
        set(gca, 'YDir', 'reverse', 'FontSize', 10);
        grid on;
        
        % Add annotation
        annotation('textbox', [0.02, 0.02, 0.3, 0.06], ...
                   'String', sprintf('16 Holes | Δt = %.3f μs | dh = %.2f mm', dt, dh), ...
                   'FitBoxToText', 'on', 'BackgroundColor', 'w', ...
                   'EdgeColor', 'k', 'FontSize', 9);
        
        drawnow;
        
        % Capture frame for video
        frame = getframe(gcf);
        writeVideo(v, frame);
    end
end

%% 6. Close Video File
close(v);
fprintf('Video saved as: %s\n', video_filename);

%% 7. Create a summary figure with hole locations
figure('Color', 'w', 'Position', [100, 100, 800, 400]);
subplot(1,2,1);
imagesc((1:nx)*dh, (1:ny)*dh, hole_mask');
colormap(gray);
title('Hole Locations', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Width (mm)');
ylabel('Depth (mm)');
set(gca, 'YDir', 'reverse');
hold on;
plot(x_coords, y_depths, 'ro', 'MarkerSize', 8, 'LineWidth', 1.5);
hold off;

subplot(1,2,2);
imagesc((1:nx)*dh, (1:ny)*dh, p');
colormap(jet);
caxis([-0.1 0.1]);
title('Final Pressure Field', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Width (mm)');
ylabel('Depth (mm)');
set(gca, 'YDir', 'reverse');
colorbar;

sgtitle('FDTD Simulation of Wave Reaction at 16 Holes', 'FontSize', 14, 'FontWeight', 'bold');

%% 8. Display simulation parameters
fprintf('\n=== Simulation Parameters ===\n');
fprintf('Grid size: %d x %d\n', nx, ny);
fprintf('Spatial step (dh): %.3f mm\n', dh);
fprintf('Time step (dt): %.6f μs\n', dt);
fprintf('Sound speed (c): %.1f mm/μs\n', c);
fprintf('Simulation time: %.2f μs\n', T*dt);
fprintf('Hole count: %d\n', length(x_coords));
fprintf('Video saved to: %s\n', video_filename);
