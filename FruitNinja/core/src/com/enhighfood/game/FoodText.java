package com.enhighfood.game;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.GlyphLayout;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.math.Vector2;

public class FoodText {
    String name;
    Vector2 position;
    float size;
    float speed;
    private float alpha = 1.0f; // Opacity of the text
    private boolean fading = false;
    private float fadeDuration = 0.2f; // Duration for fade-out
    private float fadeTimer = 0;
    private GlyphLayout layout; // Used to calculate text dimensions
    private boolean shouldBeRemoved = false;


    public FoodText(String name, Vector2 position, float size, float speed) {
        this.name = name;
        this.position = position;
        this.size = size;
        this.speed = speed;
        layout = new GlyphLayout(); // Make sure this line is present
    }

    // Update position based on speed
    public void update(float deltaTime) {
        position.x += speed * deltaTime;
        // Add any other movement logic here
        if (fading) {
            fadeTimer += deltaTime;
            alpha = Math.max(0, 1 - fadeTimer / fadeDuration);

            if (alpha == 0) {
                shouldBeRemoved = true;
            }
        }
    }

    public boolean shouldBeRemoved() {
        return shouldBeRemoved;
    }

    // Render the text
    public void render(BitmapFont font, SpriteBatch batch) {
        font.setColor(1, 1, 1, alpha); // Correctly applying alpha
        font.getData().setScale(size);
        font.draw(batch, name, position.x, position.y);
        font.setColor(1, 1, 1, 1);  // reset the font color to fully opacity
    }


    // method to start fading
    public void startFading() {
        fading = true;
        fadeTimer = 0;      // reset the fade timer
    }

    // method to check if a point intersects with the food text
    public boolean intersects(float x, float y, BitmapFont font) {
        y = Gdx.graphics.getHeight() - y;
        font.getData().setScale(size);
        layout.setText(font, name);

        float textWidth = layout.width;
        float textHeight = layout.height;

        System.out.println("Tap: (" + x + ", " + y + ")");
        System.out.println("Text bounds: (" + position.x + ", " + position.y + ", " + textWidth + ", " + textHeight + ")");

        return x >= position.x && x <= position.x + textWidth &&
                y >= position.y - textHeight && y <= position.y;
    }

}

