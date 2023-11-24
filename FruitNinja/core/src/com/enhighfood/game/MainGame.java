package com.enhighfood.game;

import com.badlogic.gdx.ApplicationAdapter;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.utils.ScreenUtils;

import java.util.ArrayList;
import java.util.Random;

public class MainGame extends ApplicationAdapter {
	ShapeRenderer shape;
	ArrayList<Ball> balls = new ArrayList<>();
	Random r = new Random();

	@Override
	public void create() {

		// defined a "shape" upon game starts
		shape = new ShapeRenderer();
//		ball = new Ball(150, 200, 70, 12, 5);		// initialize a ball

		for (int i = 0; i < 10; i++) {
			balls.add(new Ball(r.nextInt(Gdx.graphics.getWidth()),
					r.nextInt(Gdx.graphics.getHeight()),
					r.nextInt(100), r.nextInt(15), r.nextInt(15)));
		}


	}

	@Override
	public void render() {
		// Every frame, the UI gets rendered. At the start of each frame, make sure the UI is black
		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);

		for (Ball ball : balls) {
			ball.update();
			shape.begin(ShapeRenderer.ShapeType.Filled);
			ball.draw(shape);
			shape.end();
		}


		/**
		 * // initialize the "shape" as filled
		 * 		shape.begin(ShapeRenderer.ShapeType.Filled);
		 *
		 * 		// set the position and size of the "shape"
		 * 		shape.circle(x, y, 50);
		 *
		 * 		// end initialize the "shape"
		 * 		shape.end();
		 *
		 * 		x += xSpeed;		// move the circle toward right by xSpeed pixel
		 * 		if (x > Gdx.graphics.getWidth()) {		// if the circle hit UI boundary
		 * 			xSpeed = -5;
		 *                }
		 * 		if (x < 0) {
		 * 			xSpeed = 5;
		 *        }
		 */
	}


}
