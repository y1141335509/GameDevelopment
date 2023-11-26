package com.enhighfood.game;

import static com.badlogic.gdx.graphics.g3d.particles.ParticleShader.Setters.screenWidth;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.InputMultiplexer;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.graphics.Pixmap;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.scenes.scene2d.Stage;
import com.badlogic.gdx.scenes.scene2d.ui.ProgressBar;
import com.badlogic.gdx.scenes.scene2d.ui.Skin;
import com.badlogic.gdx.utils.Array;
import com.badlogic.gdx.utils.TimeUtils;
import com.badlogic.gdx.utils.viewport.ScreenViewport;

public class GameScreen implements Screen {
    private MyGame game;
    public long startTime;
    private BitmapFont font;
    private SpriteBatch batch;
    private Array<FoodText> foodTexts;
    private float spawnTimer;
    private float spawnInterval = 1; // Adjust this to change how frequently food texts spawn
    private Stage stage;
    private ProgressBar progressBar;
    private ProgressBar.ProgressBarStyle progressBarStyle; // Add this line
    private Skin skin;


    public GameScreen(MyGame game) {
        this.game = game;
        this.font = new BitmapFont(); // Use a custom font if you have one
        this.batch = new SpriteBatch();
        this.foodTexts = new Array<>();
        this.spawnTimer = 0;
        // In your GameScreen class constructor
        Gdx.input.setInputProcessor(new MyInputProcessor(foodTexts, font));
        // Create and configure the skin and progress bar style
        createProgressBarStyle();

        // Create and configure the progress bar
        setupProgressBar();
    }

    private void createProgressBarStyle() {
        skin = new Skin();
        Pixmap pixmap = new Pixmap(100, 20, Pixmap.Format.RGBA8888);
        pixmap.setColor(Color.WHITE);
        pixmap.fill();
        skin.add("white", new Texture(pixmap));

        progressBarStyle = new ProgressBar.ProgressBarStyle(skin.newDrawable("white", Color.DARK_GRAY), skin.newDrawable("white", Color.GREEN));
        progressBarStyle.knobBefore = progressBarStyle.knob;

        pixmap.dispose();
    }

    private void setupProgressBar() {
        float min = 0;
        float max = 120; // Assuming your game is 120 seconds
        float step = 1;
        progressBar = new ProgressBar(min, max, step, false, progressBarStyle);
        progressBar.setValue(max); // Initialize with the maximum value
        progressBar.setBounds(10, Gdx.graphics.getHeight() - 30, Gdx.graphics.getWidth() - 20, 20); // Position and size


        stage = new Stage(new ScreenViewport());
        stage.addActor(progressBar);


        // If you have an existing input processor, you might need to combine it with the stage's input processor
        InputMultiplexer inputMultiplexer = new InputMultiplexer();
        inputMultiplexer.addProcessor(stage);
        // Add other input processors if necessary
        inputMultiplexer.addProcessor(new MyInputProcessor(foodTexts, font));
        Gdx.input.setInputProcessor(inputMultiplexer);
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

        // Update the progress bar value
        float timeElapsed = 120f;   // Calculate elapsed time since the game started
        progressBar.setValue(120f - timeElapsed); // Decrease the value to reflect remaining time
        // Update and draw the stage
        stage.act(Math.min(delta, 1 / 30f));
        stage.draw();


        ///////////// GAME LOGIC ENDS /////////////

        // Check for game end
        if (TimeUtils.timeSinceMillis(startTime) > 120000) {
            // Time's up, end the game
        }
    }

    private void spawnFoodText() {
        String foodName = "Hello"; // Implement this method to get random food names
        Vector2 position = new Vector2(MathUtils.random(0, Gdx.graphics.getWidth()) / 2f,
                MathUtils.random(0, Gdx.graphics.getHeight()));
        float size = MathUtils.random(5f, 10f); // Random size between 0.5 and 2.0 times the original size
        float speed = MathUtils.random(100, 200); // Random speed in units per second

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
        // ... dispose other resources ...

        if (stage != null) {
            stage.dispose();
        }
        if (skin != null) {
            skin.dispose();
        }
    }


    // Implement other necessary methods
}

