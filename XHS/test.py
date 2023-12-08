

import pygame, random

# Initialize Pygame
pygame.init()

# Load the image and get its size
bg = pygame.image.load('./test1.png')
SIZE = bg.get_size()


# Set the screen width and height to the image size
screen = pygame.display.set_mode(SIZE)
pygame.display.set_caption("Snowing in the Forbidden City")

# Resize the image to fit the screen size (if necessary)
bg = pygame.transform.scale(bg, SIZE)

# Snowflake list
snow_list = []

# Initialize snowflakes: [x position, y position, x axis speed, y axis speed]
for i in range(200):
    x = random.randrange(0, SIZE[0])
    y = random.randrange(0, SIZE[1])
    sx = random.randint(-1, 1)
    sy = random.randint(1, 3)  # Slower snowflakes for a gentle snowfall
    snow_list.append([x, y, sx, sy])

# Create a clock object to control the frame rate
clock = pygame.time.Clock()

# Main game loop
done = False
while not done:
    # Event loop to check for quit events
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            done = True

    # Use the background image
    screen.blit(bg, (0, 0))

    # Loop through the snowflakes
    for i in range(len(snow_list)):
        # Draw the snowflake: color, position, size
        pygame.draw.circle(screen, (255, 255, 255), snow_list[i][:2], 2.5)

        # Move the snowflake position (takes effect next loop)
        snow_list[i][0] += snow_list[i][2]
        snow_list[i][1] += snow_list[i][3]

        # If snowflake falls off the screen, reset its position
        if snow_list[i][1] > SIZE[1]:
            snow_list[i][1] = random.randrange(-50, -10)
            snow_list[i][0] = random.randrange(0, SIZE[0])

    # Refresh the screen
    pygame.display.flip()
    clock.tick(20)

# Exit Pygame
pygame.quit()




















print('hello')

