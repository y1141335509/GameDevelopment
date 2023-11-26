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

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;

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
    private String[] foodNames = {"Banana", "Apple", "Cilantro", "Bok Choy"};


    public GameScreen(MyGame game) {
        this.game = game;
        this.font = new BitmapFont(); // Use a custom font if you have one
        this.batch = new SpriteBatch();
        this.foodTexts = new Array<>();
        this.spawnTimer = 0;
        this.startTime = System.currentTimeMillis();
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

        progressBarStyle = new ProgressBar.ProgressBarStyle(
                skin.newDrawable("white", Color.BLACK),
                skin.newDrawable("white", Color.GREEN)
        );
        progressBarStyle.knobBefore = progressBarStyle.knob;

        pixmap.dispose();
    }

    private void setupProgressBar() {
        float min = 0;
        float max = 120; // Assuming your game is 120 seconds
        float step = 1;
        progressBar = new ProgressBar(min, max, step, false, progressBarStyle);
        progressBar.setValue(max); // Initialize with the maximum value
        progressBar.setBounds(10, Gdx.graphics.getHeight() - 30,
                Gdx.graphics.getWidth() - 20, 20); // Position and size


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

        /// Update the progress bar
        long currentTime = System.currentTimeMillis();
        float elapsedTimeInSeconds = (currentTime - this.startTime) / 1000f;
        progressBar.setValue(Math.max(0, 120 - elapsedTimeInSeconds)); // Decrease the progress bar value


        stage.act(Math.min(delta, 1 / 30f));
        stage.draw();

        // Check for game end
        if (elapsedTimeInSeconds >= 120) {
            // Time's up, end the game
            Gdx.app.exit();
        }

        ///////////// GAME LOGIC ENDS /////////////

        // Check for game end
        if (TimeUtils.timeSinceMillis(startTime) > 120000) {
            // Time's up, end the game
            Gdx.app.exit(); // quit the current game
        }

    }

    private void spawnFoodText() {
        List<String> foodNameArray = new ArrayList<>(Arrays.asList(this.foodNames));
        int randInx = new Random().nextInt(foodNameArray.size());
        String foodName = foodNameArray.get(randInx);


        // set the area where the food texts are generated
        Vector2 position = new Vector2(MathUtils.random(50, Gdx.graphics.getWidth()) / 2f - 50,
                MathUtils.random(50, Gdx.graphics.getHeight() - 50));
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

