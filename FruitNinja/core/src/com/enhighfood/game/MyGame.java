package com.enhighfood.game;


import com.badlogic.gdx.Game;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;

public class MyGame extends Game {
    SpriteBatch batch;
    BitmapFont font;

    @Override
    public void create() {
        font = new BitmapFont();
        batch = new SpriteBatch();
        this.setScreen(new GameScreen(this));
    }

    @Override
    public void render() {
        super.render(); // Important! This will render the active game screen.

    }

    @Override
    public void dispose() {
        batch.dispose();
    }
}


