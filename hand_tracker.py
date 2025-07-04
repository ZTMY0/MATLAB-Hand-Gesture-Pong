import cv2
import mediapipe as mp
import socket

mp_hands = mp.solutions.hands.Hands(min_detection_confidence=0.7, min_tracking_confidence=0.5)
mp_draw = mp.solutions.drawing_utils
cap = cv2.VideoCapture(0)

UDP_IP = "127.0.0.1"
UDP_PORT = 5005
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

cv2.namedWindow("Hand Tracker", cv2.WINDOW_NORMAL)
cv2.resizeWindow("Hand Tracker", 480, 360)     
cv2.moveWindow("Hand Tracker", 800, 60)        

while True:
    success, frame = cap.read()
    if not success:
        break

    frame = cv2.flip(frame, 1)
    results = mp_hands.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))

    direction1 = "none"
    direction2 = "none"

    if results.multi_hand_landmarks:
        hands = results.multi_hand_landmarks[:2]
        for i, hand_landmarks in enumerate(hands):
            wrist = hand_landmarks.landmark[mp.solutions.hands.HandLandmark.WRIST]
            index_tip = hand_landmarks.landmark[mp.solutions.hands.HandLandmark.INDEX_FINGER_TIP]

            if index_tip.y < wrist.y:
                if i == 0: direction1 = "up"
                else: direction2 = "up"
            elif index_tip.y > wrist.y:
                if i == 0: direction1 = "down"
                else: direction2 = "down"

            mp_draw.draw_landmarks(frame, hand_landmarks, mp.solutions.hands.HAND_CONNECTIONS)

    message = f"{direction1},{direction2}".encode('utf-8') 
    sock.sendto(message, (UDP_IP, UDP_PORT))

    cv2.putText(frame, "Player 1: " + direction1, (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
    cv2.putText(frame, "Player 2: " + direction2, (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
    cv2.imshow("Hand Tracker", frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
