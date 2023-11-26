package com.enhighfood.game;

import com.badlogic.gdx.InputAdapter;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.utils.Array;

public class MyInputProcessor extends InputAdapter {
    private Array<FoodText> foodTexts;
    private BitmapFont font;

    public MyInputProcessor(Array<FoodText> foodTexts, BitmapFont font) {
        this.foodTexts = foodTexts;
        this.font = font;
    }


    @Override
    public boolean touchDown(int screenX, int screenY, int pointer, int button) {
        for (FoodText foodText : foodTexts) {
            if (foodText.intersects(screenX, screenY, font)) {
                foodText.startFading();
                return true; // Event was handled
            }
        }
        return false; // Event not handled, pass it to the next processor
    }
}

