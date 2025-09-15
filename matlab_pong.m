function matlab_pong()
    %== Config ==%
    cfg.paddle_width = 3;
    cfg.paddle_height = 12;
    cfg.paddle_speed = 2;
    cfg.ball_radius = 3;
    cfg.fig_pos = [10, 40, 680, 500];
    cfg.field = [0 100 0 60];
    cfg.ball_speed = [1.0 0.8];

    asset_path = 'C:\Users\hp\.vscode\dist\assets\';

    [hit_sound, fs_hit] = audioread(fullfile(asset_path, 'hitsound.wav'));
    [point_sound, fs_point] = audioread(fullfile(asset_path, 'point.wav'));

    [bgm, fs_bgm] = audioread(fullfile(asset_path, 'music.mp3'));
    player_bgm = audioplayer(bgm, fs_bgm);
    play(player_bgm);

    u = udp('127.0.0.1', 'LocalPort', 5005); fopen(u);

    %== Game Window ==%
    fig = figure('Name', 'Pong Game', 'NumberTitle', 'off', ...
        'MenuBar', 'none', 'Color', 'k', 'KeyPressFcn', @closeGame, ...
        'Position', cfg.fig_pos);
    axis(cfg.field); axis manual;
    set(gca, 'Color', 'k', 'XColor', 'none', 'YColor', 'none'); hold on;

    %== Img assets ==%
    ball_img = imread(fullfile(asset_path, 'custom_ball.png'));
    paddle_img = imread(fullfile(asset_path, 'sans_paddle.png'));
    bg_img = imread(fullfile(asset_path, 'undertale.png'));

    
    h_bg = image('XData', [cfg.field(1) cfg.field(2)], 'YData', [cfg.field(3) cfg.field(4)], 'CData', bg_img);
    uistack(h_bg, 'bottom');

    %== Initial State ==%
    state.paddle1 = [5, 20];
    state.paddle2 = [95, 20];
    state.ball = [50, 30];
    state.ball_speed = cfg.ball_speed;
    state.score = [0, 0];

    %=== Draw paddles and ball using images ===%
    handles.p1 = imshow(paddle_img, 'XData', [state.paddle1(1), state.paddle1(1)+cfg.paddle_width], ...
                                 'YData', [state.paddle1(2), state.paddle1(2)+cfg.paddle_height]);
    handles.p2 = imshow(paddle_img, 'XData', [state.paddle2(1), state.paddle2(1)+cfg.paddle_width], ...
                                 'YData', [state.paddle2(2), state.paddle2(2)+cfg.paddle_height]);
    handles.ball = imshow(ball_img, 'XData', [state.ball(1)-cfg.ball_radius, state.ball(1)+cfg.ball_radius], ...
                                 'YData', [state.ball(2)-cfg.ball_radius, state.ball(2)+cfg.ball_radius]);

    handles.score1 = text(25, 57, 'Player 1: 0', 'Color', 'w', 'FontSize', 14);
    handles.score2 = text(55, 57, 'Player 2: 0', 'Color', 'w', 'FontSize', 14);
    handles.info = text(25, 2, 'Press ESC to Quit', 'Color', 'w', 'FontSize', 10);

    %== Start Timer ==%
    game_timer = timer('ExecutionMode', 'fixedRate', 'Period', 0.013, ...
        'TimerFcn', @(~,~) updateGame());
    start(game_timer);

    %== Main Game Function ==%
    function updateGame()
        if ~isvalid(fig)
            stop(game_timer);
            delete(game_timer);
            fclose(u);
            stop(player_bgm);
            delete(player_bgm);
            return;
        end

        [dir1, dir2] = readUDP(u);

        state.paddle1(2) = movePaddle(state.paddle1(2), dir1, cfg);
        state.paddle2(2) = movePaddle(state.paddle2(2), dir2, cfg);

        % Update paddle positions
        set(handles.p1, 'XData', [state.paddle1(1), state.paddle1(1)+cfg.paddle_width], ...
                        'YData', [state.paddle1(2), state.paddle1(2)+cfg.paddle_height]);
        set(handles.p2, 'XData', [state.paddle2(1), state.paddle2(1)+cfg.paddle_width], ...
                        'YData', [state.paddle2(2), state.paddle2(2)+cfg.paddle_height]);

        % Move ball
        state.ball = state.ball + state.ball_speed;

        % Bounce off top/bottom
        if state.ball(2)-cfg.ball_radius <= cfg.field(3) || state.ball(2)+cfg.ball_radius >= cfg.field(4)
            state.ball_speed(2) = -state.ball_speed(2);
            sound(hit_sound, fs_hit);
        end

        % Paddle collisions
        if checkPaddleHit(state.ball, state.paddle1, cfg, 'left')
            state.ball_speed(1) = abs(state.ball_speed(1));
            state.ball(1) = state.paddle1(1) + cfg.paddle_width + cfg.ball_radius;
            sound(hit_sound, fs_hit);
        elseif checkPaddleHit(state.ball, state.paddle2, cfg, 'right')
            state.ball_speed(1) = -abs(state.ball_speed(1));
            state.ball(1) = state.paddle2(1) - cfg.ball_radius;
            sound(hit_sound, fs_hit);
        end

        % Point scoring
        if state.ball(1) + cfg.ball_radius >= cfg.field(2)
            state.score(1) = state.score(1) + 1;
            sound(point_sound, fs_point);
            resetBall();
        elseif state.ball(1) - cfg.ball_radius <= cfg.field(1)
            state.score(2) = state.score(2) + 1;
            sound(point_sound, fs_point);
            resetBall();
        end

        % Update ball position graphics
        set(handles.ball, 'XData', [state.ball(1)-cfg.ball_radius, state.ball(1)+cfg.ball_radius], ...
                         'YData', [state.ball(2)-cfg.ball_radius, state.ball(2)+cfg.ball_radius]);

        % Update score texts
        set(handles.score1, 'String', ['Player 1: ' num2str(state.score(1))]);
        set(handles.score2, 'String', ['Player 2: ' num2str(state.score(2))]);

        drawnow limitrate;
    end

    %=== Paddle Movement Logic ===%
    function y = movePaddle(y, dir, cfg)
        if strcmp(dir, 'up'), y = y - cfg.paddle_speed; end
        if strcmp(dir, 'down'), y = y + cfg.paddle_speed; end
        y = max(0, min(cfg.field(4) - cfg.paddle_height, y));
    end

    %=== Input UDP ===%
    function [dir1, dir2] = readUDP(u)
        if u.BytesAvailable > 0
            data = fscanf(u, '%s');
            dirs = strsplit(data, ',');
            dir1 = dirs{1};
            dir2 = dirs{2};
        else
            dir1 = 'none';
            dir2 = 'none';
        end
    end

    %=== Collision Detection ===%
    function hit = checkPaddleHit(ball, paddle, cfg, side)
        if strcmp(side, 'left')
            hit = ball(1) - cfg.ball_radius <= paddle(1) + cfg.paddle_width && ...
                  ball(2) >= paddle(2) && ball(2) <= paddle(2) + cfg.paddle_height;
        else
            hit = ball(1) + cfg.ball_radius >= paddle(1) && ...
                  ball(2) >= paddle(2) && ball(2) <= paddle(2) + cfg.paddle_height;
        end
    end

    %=== Ball Reset ===%
    function resetBall()
        state.ball = [50, 30];
        state.ball_speed = [sign(randn)*1.0, sign(randn)*0.8];
        pause(0.5);
    end

    %=== Close Game on ESC ===%
    function closeGame(~, event)
        if strcmp(event.Key, 'escape')
            close(fig);
        end
    end
end
