""" import cv2 as cv
import numpy as np

video = cv.VideoCapture(0)
prevCircle = None
dist = lambda x1, y1, x2, y2: (x1-x2)**2 + (y1-y2)**2

while True:
    ret, frame = video.read()
    if not ret:
        print("No se puede abrir la camara")
        break
    
    graFrame = cv.cvtColor(frame, cv.COLOR_BGR2GRAY)
    blurFrame = cv.GaussianBlur(graFrame, (17,17), 0)
    
    circles = cv.HoughCircles(blurFrame, cv.HOUGH_GRADIENT, 1.0, 20, param1=50, param2=30, minRadius=0, maxRadius=0)
    
    if circles is not None:
        circles = np.uint16(np.around(circles))
        chosen = None
        for i in circles[0,:]:
            if chosen is None:
                chosen = i
            if prevCircle is not None:
                if dist(chosen[0], chosen[1], prevCircle[0], prevCircle[1]) < dist(i[0], i[1], prevCircle[0], prevCircle[1]):
                    chosen = i
        cv.circle(frame, (chosen[0], chosen[1]), 1, (0,100,100), 3)
        cv.circle(frame, (chosen[0], chosen[1]), chosen[2], (255,0,255), 3)
        prevCircle = chosen
        
    cv.imshow("Circles", frame)
    
    
    if cv.waitKey(1) & 0xFF == ord('q'):
        break
    
video.release()
cv.destroyAllWindows() """

import cv2 as cv
import numpy as np

video = cv.VideoCapture(6)
prevPositionYellow = None
prevPositionRed = None
dist = lambda x1, y1, x2, y2: (x1 - x2) ** 2 + (y1 - y2) ** 2

while True:
    ret, frame = video.read()
    if not ret:
        print("No se puede abrir la cámara")
        break

    hsvFrame = cv.cvtColor(frame, cv.COLOR_BGR2HSV)

    # Definir los rangos de color para el amarillo y el rojo en el espacio HSV
    lower_yellow = np.array([20, 100, 100])
    upper_yellow = np.array([40, 255, 255])
    lower_red1 = np.array([0, 100, 100])
    upper_red1 = np.array([10, 255, 255])
    lower_red2 = np.array([170, 100, 100])
    upper_red2 = np.array([180, 255, 255])

    # Aplicar una máscara para detectar el color amarillo
    yellow_mask = cv.inRange(hsvFrame, lower_yellow, upper_yellow)

    # Aplicar una máscara para detectar el color rojo
    red_mask1 = cv.inRange(hsvFrame, lower_red1, upper_red1)
    red_mask2 = cv.inRange(hsvFrame, lower_red2, upper_red2)
    red_mask = cv.bitwise_or(red_mask1, red_mask2)

    # Aplicar un desenfoque a las máscaras para suavizar los contornos
    yellow_blur = cv.GaussianBlur(yellow_mask, (17, 17), 0)
    red_blur = cv.GaussianBlur(red_mask, (17, 17), 0)

    # Detectar los contornos de la pelota amarilla
    yellow_contours, _ = cv.findContours(yellow_blur, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE)

    # Encontrar el contorno con el área máxima para la pelota amarilla
    max_area_yellow = 0
    max_contour_yellow = None
    for contour in yellow_contours:
        area = cv.contourArea(contour)
        if area > max_area_yellow:
            max_area_yellow = area
            max_contour_yellow = contour

    if max_contour_yellow is not None:
        # Calcular el centro y el radio del contorno máximo para la pelota amarilla
        ((x_yellow, y_yellow), radius_yellow) = cv.minEnclosingCircle(max_contour_yellow)
        center_yellow = (int(x_yellow), int(y_yellow))

        # Convertir posición de píxeles a valores de coordenadas x e y para la pelota amarilla
        height, width, _ = frame.shape
        x_normalized_yellow = (x_yellow / width) * 2 - 1  # Normalizar a rango [-1, 1]
        y_normalized_yellow = (y_yellow / height) * 2 - 1  # Normalizar a rango [-1, 1]

        # Ajustar límites de x e y para la pelota amarilla
        x_adjusted_yellow = x_normalized_yellow * 1.0  # Ajustar límites a [-1.2, 0.8]
        y_adjusted_yellow = -y_normalized_yellow * 1.0  # Ajustar límites a [-1.1, 0.9] e invertir el valor

        # Dibujar el círculo y mostrarlo en el marco para la pelota amarilla
        cv.circle(frame, center_yellow, 1, (0, 100, 100), 3)
        cv.circle(frame, center_yellow, int(radius_yellow), (255, 0, 255), 3)

        # Dibujar el texto con los valores de x_adjusted e y_adjusted para la pelota amarilla
        text_yellow = f'Yellow - x: {x_adjusted_yellow:.2f}, y: {y_adjusted_yellow:.2f}'
        cv.putText(frame, text_yellow, (10, 30), cv.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)

        prevPositionYellow = (x_adjusted_yellow, y_adjusted_yellow)

    # Detectar los contornos de la pelota roja
    red_contours, _ = cv.findContours(red_blur, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE)

    # Encontrar el contorno con el área máxima para la pelota roja
    max_area_red = 0
    max_contour_red = None
    for contour in red_contours:
        area = cv.contourArea(contour)
        if area > max_area_red:
            max_area_red = area
            max_contour_red = contour

    if max_contour_red is not None:
        # Calcular el centro y el radio del contorno máximo para la pelota roja
        ((x_red, y_red), radius_red) = cv.minEnclosingCircle(max_contour_red)
        center_red = (int(x_red), int(y_red))

        # Convertir posición de píxeles a valores de coordenadas x e y para la pelota roja
        height, width, _ = frame.shape
        x_normalized_red = (x_red / width) * 2 - 1  # Normalizar a rango [-1, 1]
        y_normalized_red = (y_red / height) * 2 - 1  # Normalizar a rango [-1, 1]

        # Ajustar límites de x e y para la pelota roja
        x_adjusted_red = x_normalized_red * 1.0  # Ajustar límites a [-1.2, 0.8]
        y_adjusted_red = -y_normalized_red * 1.0  # Ajustar límites a [-1.1, 0.9] e invertir el valor

        # Dibujar el círculo y mostrarlo en el marco para la pelota roja
        cv.circle(frame, center_red, 1, (0, 0, 255), 3)
        cv.circle(frame, center_red, int(radius_red), (0, 0, 255), 3)

        # Dibujar el texto con los valores de x_adjusted e y_adjusted para la pelota roja
        text_red = f'Red - x: {x_adjusted_red:.2f}, y: {y_adjusted_red:.2f}'
        cv.putText(frame, text_red, (10, 60), cv.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)

        prevPositionRed = (x_adjusted_red, y_adjusted_red)

    cv.imshow("Balls", frame)

    if cv.waitKey(1) & 0xFF == ord('q'):
        break

video.release()
cv.destroyAllWindows()



