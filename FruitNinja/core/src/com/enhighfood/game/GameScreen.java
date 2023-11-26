package com.enhighfood.game;

import static com.badlogic.gdx.graphics.g3d.particles.ParticleShader.Setters.screenWidth;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.utils.Array;
import com.badlogic.gdx.utils.TimeUtils;

public class GameScreen implements Screen {
    private MyGame game;
    public long startTime;
    private BitmapFont font;
    private SpriteBatch batch;
    private Array<FoodText> foodTexts;
    private float spawnTimer;
    private float spawnInterval = 1; // Adjust this to change how frequently food texts spawn

    public GameScreen(MyGame game) {
        this.game = game;
        this.font = new BitmapFont(); // Use a custom font if you have one
        this.batch = new SpriteBatch();
        this.foodTexts = new Array<>();
        this.spawnTimer = 0;
        // In your GameScreen class constructor
        Gdx.input.setInputProcessor(new MyInputProcessor(foodTexts, font));

    }

    @Override
    public void show() {

    }

    @Override
    public void render(float delta) {
        // Clear the screen
        Gdx.gl.glClearColor(0, 1, 1, 1);
        Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);

        ///////////// GAME LOGIC ENDS /////////////
        // Update spawn timer and spawn food texts
        spawnTimer += delta;
        if (spawnTimer >= spawnInterval) {
            spawnFoodText();
            spawnTimer = 0;
        }
        // Update each food text
        for (FoodText foodText : foodTexts) {
            foodText.update(Gdx.graphics.getDeltaTime());
        }


        game.batch.begin();
        // Render each food text
        for (FoodText foodText : foodTexts) {
            foodText.render(font, game.batch);
        }
        game.batch.end();


        ///////////// GAME LOGIC ENDS /////////////

        // Check for game end
        if (TimeUtils.timeSinceMillis(startTime) > 120000) {
            // Time's up, end the game
        }
    }

    private void spawnFoodText() {
        String foodName = "Hello"; // Implement this method to get random food names
        Vector2 position = new Vector2(MathUtils.random(0, Gdx.graphics.getWidth()), MathUtils.random(0, Gdx.graphics.getHeight()));
        float size = MathUtils.random(0.5f, 2.0f); // Random size between 0.5 and 2.0 times the original size
        float speed = MathUtils.random(50, 200); // Random speed in units per second

        FoodText foodText = new FoodText(foodName, position, size, speed);
        foodTexts.add(foodText); // Add foodText to the array
    }



    @Override
    public void resize(int width, int height) {

    }

    @Override
    public void pause() {

    }

    @Override
    public void resume() {

    }

    @Override
    public void hide() {

    }

    @Override
    public void dispose() {

    }

    // Implement other necessary methods
}

