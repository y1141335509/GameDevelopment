package com.enhighfood.game;


import com.badlogic.gdx.scenes.scene2d.ui.ProgressBar;
import com.badlogic.gdx.scenes.scene2d.ui.Skin;
import com.badlogic.gdx.scenes.scene2d.ui.Table;

import java.util.HashMap;

public class NutritionBar extends Table {
    private HashMap<String, ProgressBar> bars;

    public NutritionBar(Skin skin) {
        bars = new HashMap<>();
        String[] nutrients = {"VA", "VB", "VC", "Water", "Toxic"};

        for (String nutrient : nutrients) {
            ProgressBar bar = new ProgressBar(0, 100, 1, false, skin); // Adjust range and step size
            bars.put(nutrient, bar);
            add(bar).pad(10); // Add the bar to the table
            row(); // New row for each bar
        }
    }

    public void updateNutrition(String nutrient, double amount) {
        if (bars.containsKey(nutrient)) {
            ProgressBar bar = bars.get(nutrient);
            bar.setValue((float) (bar.getValue() + amount));
        }
    }
}



