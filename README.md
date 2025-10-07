# Hand-Controlled Pong Game

A classic Pong game with a twist - control the paddles using hand gestures! This project combines MATLAB for the game engine with Python for hand tracking using MediaPipe.

## Overview

This implementation features:
- **Gesture-based controls** using MediaPipe hand tracking
- **Custom visual assets** with Undertale-themed graphics
- **Real-time UDP communication** between Python and MATLAB
- **Audio feedback** with sound effects and background music
- **Two-player support** with independent hand tracking

## Requirements

### Software Dependencies

#### MATLAB
- MATLAB R2019b or later
- Image Processing Toolbox
- Instrument Control Toolbox (for UDP communication)

#### Python
- Python 3.7 or later
- Required packages:
```bash
pip install opencv-python mediapipe
```

### Hardware
- Webcam for hand tracking
- Sufficient lighting for accurate hand detection

## Required Assets

Place the following files in your asset directory (`C:\Users\hp\.vscode\dist\assets\` or modify the path in the code):

- `hitsound.wav` - Sound effect for paddle/wall collisions
- `point.wav` - Sound effect for scoring
- `music.mp3` - Background music
- `custom_ball.png` - Ball sprite image
- `sans_paddle.png` - Paddle sprite image
- `undertale.png` - Background image

## Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/hand-controlled-pong.git
cd hand-controlled-pong
```

2. **Install Python dependencies**
```bash
pip install opencv-python mediapipe
```

3. **Set up assets**
   - Create your asset directory or use the default path
   - Add all required audio and image files
   - Update the `asset_path` variable in `matlab_pong.m` if needed

4. **Configure UDP**
   - Ensure both scripts use the same IP (`127.0.0.1`) and port (`5005`)
   - Check firewall settings if connection issues occur

## How to Play

### Starting the Game

1. **Launch the hand tracking script first:**
```bash
python hand_tracker.py
```
   - Allow camera access when prompted
   - Position yourself so both hands are visible

2. **Start the MATLAB game:**
```matlab
matlab_pong()
```

### Controls

- **Point your index finger UP** to move paddle up
- **Point your index finger DOWN** to move paddle down
- **First hand detected** controls Player 1 (left paddle)
- **Second hand detected** controls Player 2 (right paddle)
- **Press ESC** to quit the game
- **Press Q** in the hand tracker window to close tracking

### Gameplay

- Score points by getting the ball past your opponent's paddle
- The ball bounces off the top and bottom walls
- Paddle collisions change the ball's direction
- First to reach the target score wins!

## Configuration

### MATLAB Settings (`matlab_pong.m`)

```matlab
cfg.paddle_width = 3;      % Paddle width
cfg.paddle_height = 12;    % Paddle height
cfg.paddle_speed = 2;      % Movement speed
cfg.ball_radius = 3;       % Ball size
cfg.ball_speed = [1.0 0.8]; % Initial ball velocity [x, y]
cfg.field = [0 100 0 60];  % Playing field dimensions
```

### Python Settings (`hand_tracker.py`)

```python
min_detection_confidence=0.7  # Hand detection threshold
min_tracking_confidence=0.5   # Hand tracking threshold
cv2.resizeWindow("Hand Tracker", 480, 360)  # Window size
```

## Troubleshooting

### Common Issues

**Camera not opening:**
- Check if another application is using the camera
- Try changing `cv2.VideoCapture(0)` to `cv2.VideoCapture(1)` or higher

**UDP connection failed:**
- Ensure both scripts are using the same port (5005)
- Check firewall settings
- Verify both scripts are running on the same machine

**Hand detection not working:**
- Improve lighting conditions
- Ensure hands are clearly visible and not overlapping
- Adjust detection confidence thresholds

**Audio not playing:**
- Verify audio files exist in the asset path
- Check MATLAB audio device settings
- Ensure file formats are supported

**Images not displaying:**
- Verify image files exist and paths are correct
- Check image file formats (PNG recommended)
- Ensure Image Processing Toolbox is installed

## Project Structure

```
hand-controlled-pong/
│
├── matlab_pong.m           # Main MATLAB game engine
├── hand_tracker.py         # Python hand tracking script
├── README.md               # This file
│
└── assets/                 # Game assets
    ├── hitsound.wav
    ├── point.wav
    ├── music.mp3
    ├── custom_ball.png
    ├── sans_paddle.png
    └── undertale.png
```

## How It Works

### Communication Flow

1. **Python script** captures webcam feed and processes hand gestures
2. Hand positions are converted to directional commands ("up", "down", "none")
3. Commands are sent via **UDP** to MATLAB
4. **MATLAB receives** commands and updates paddle positions
5. Game logic processes collisions, scoring, and rendering
6. Audio feedback enhances gameplay experience

### Hand Detection Logic

- Uses MediaPipe's hand landmark detection
- Compares wrist and index finger tip positions
- Index finger above wrist = "up" command
- Index finger below wrist = "down" command
- Supports up to 2 hands simultaneously

## Contributing

Contributions are welcome! Feel free to:
- Add new features
- Improve hand gesture recognition
- Create new themes and assets
- Optimize performance
- Fix bugs

## License

This project is open source and available under the MIT License.

## Acknowledgments

- MediaPipe for hand tracking technology
- Undertale for visual inspiration
- Classic Pong for timeless gameplay

## Contact

For questions or suggestions, please open an issue on GitHub.

---
