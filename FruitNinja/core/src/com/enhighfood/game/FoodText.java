package com.enhighfood.game;


import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.g2d.Batch;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.GlyphLayout;
import com.badlogic.gdx.scenes.scene2d.Actor;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.actions.Actions;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

public class FoodText extends Actor {
    private String foodName;
    private HashMap<String, Double> nutritionValues;
    private BitmapFont font;
    private GlyphLayout layout;
    private Vector2 velocity;
    private Random r = new Random();
    public NutritionBar nutritionBar;


    public FoodText(String foodName, final HashMap<String, Double> nutritionValues) {
        this.foodName = foodName;
        this.nutritionValues = nutritionValues;
        this.font = new BitmapFont(); // Customize your font
        this.layout = new GlyphLayout(font, foodName);

        // Set the size and position of the actor
        setSize(layout.width, layout.height);
        setPosition(r.nextInt(Gdx.graphics.getWidth() - (int) getWidth()),
                r.nextInt(Gdx.graphics.getHeight() - (int) getHeight()));

        // Random velocity for movement
        float angle = r.nextFloat() * 360;
        float speed = r.nextFloat() * 100; // Adjust the speed as needed
        velocity = new Vector2(speed, 0).setAngleDeg(angle);

        addListener(new ClickListener() {
            @Override
            public void clicked(InputEvent event, float x, float y) {
                addAction(Actions.fadeOut(1f)); // 1 second fade out
                for (Map.Entry<String, Double> entry : nutritionValues.entrySet()) {
                    nutritionBar.updateNutrition(entry.getKey(), entry.getValue());
                }
            }
        });

    }

    @Override
    public void act(float delta) {
        super.act(delta);
        moveBy(velocity.x * delta, velocity.y * delta);
    }

    @Override
    public void draw(Batch batch, float parentAlpha) {
        font.setColor(getColor()); // This allows the fade out effect
        font.draw(batch, layout, getX(), getY());
    }
}
