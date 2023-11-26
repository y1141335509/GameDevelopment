package com.enhighfood.game;

import com.badlogic.gdx.ApplicationAdapter;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.NinePatch;
import com.badlogic.gdx.graphics.g2d.Sprite;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.g2d.TextureAtlas;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.scenes.scene2d.Stage;
import com.badlogic.gdx.scenes.scene2d.ui.Skin;
import com.badlogic.gdx.scenes.scene2d.utils.Drawable;
import com.badlogic.gdx.scenes.scene2d.utils.TiledDrawable;
import com.badlogic.gdx.utils.ScreenUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Random;

public class MainGame extends ApplicationAdapter {
	ShapeRenderer shape;
	ArrayList<Ball> balls = new ArrayList<>();
	Random r = new Random();
	Stage stage;
	float nutrition = 0;
	private NutritionBar nutritionBar;


	@Override
	public void create() {
		stage = new Stage();
		Gdx.input.setInputProcessor(stage);

		// initialize the nutrition bar GUI
//		Skin skin = new Skin(Gdx.files.internal("uiskin.json"));
//		nutritionBar = new NutritionBar(skin);
//		nutritionBar.setPosition(10, Gdx.graphics.getHeight() - nutritionBar.getPrefHeight() - 10);
//		stage.addActor(nutritionBar);



		for (int i = 0; i < 10; i++) {
			String foodName = "hello";
			HashMap<String, Double> nutritionMap = new HashMap<>();
			nutritionMap.put("VA", 12d);
			nutritionMap.put("VB", 3d);
			nutritionMap.put("VC", 2d);
			nutritionMap.put("Water", 5d);
			nutritionMap.put("Toxic", -2d);


			FoodText foodText = new FoodText(foodName, nutritionMap);
			stage.addActor(foodText);
		}

	}

	@Override
	public void render() {
		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);
		stage.act(Gdx.graphics.getDeltaTime());
		stage.draw();
	}

	@Override
	public void dispose() {
		stage.dispose();
	}


}
