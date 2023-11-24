package com.enhighfood.game;

import com.badlogic.gdx.ApplicationAdapter;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.utils.ScreenUtils;

public class MainGame extends ApplicationAdapter {
	ShapeRenderer shape;
	int x = 50, y = 50;

	@Override
	public void create() {

		// defined a "shape" upon game starts
		shape = new ShapeRenderer();

	}

	@Override
	public void render() {
		// Every frame, the UI gets rendered. At the start of each frame, make sure the UI is black
		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);

		x += 5;

		// initialize the "shape" as filled
		shape.begin(ShapeRenderer.ShapeType.Filled);

		// set the position and size of the "shape"
		shape.circle(x, y, 50);

		// end initialize the "shape"
		shape.end();

	}


}
