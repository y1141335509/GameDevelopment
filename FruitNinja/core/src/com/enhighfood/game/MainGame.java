package com.enhighfood.game;

import com.badlogic.gdx.ApplicationAdapter;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.utils.ScreenUtils;

public class MainGame extends ApplicationAdapter {
	SpriteBatch batch;
	Texture img;

	private GameScreen gameScreen;


	@Override
	public void create () {
		gameScreen = new GameScreen();
		gameScreen.show();
	}

	@Override
	public void render () {
		gameScreen.render(Gdx.graphics.getDeltaTime());
	}
	
	@Override
	public void dispose () {
		gameScreen.dispose();
	}
}
