// /hiyori_free_t08.model3.json


import React, { useEffect, useRef } from 'react';
import * as PIXI from 'pixi.js';
import { Live2DModel } from 'pixi-live2d-display';

function Live2DComponent({ modelPath }) {
  const canvasRef = useRef(null);

  useEffect(() => {
    if (!canvasRef.current) return;

    // Expose PIXI to window for Live2D models
    window.PIXI = PIXI;

    // Initialize PIXI Application
    const app = new PIXI.Application({
      view: document.getElementById('canvas'),
    });

    // Load and add Live2D model
    let model;
    Live2DModel.from(modelPath).then(loadedModel => {
      model = loadedModel;
      app.stage.addChild(model);

      // Set transforms
      model.x = 100;
      model.y = 100;
      model.rotation = Math.PI;
      model.skew.x = Math.PI;
      model.scale.set(2, 2);
      model.anchor.set(0.5, 0.5);

      // Handle interaction
      model.on('hit', (hitAreas) => {
        if (hitAreas.includes('body')) {
          model.motion('tap_body');
        }
      });
    });

    // Cleanup
    return () => {
      if (model) {
        app.stage.removeChild(model);
        model.destroy();
      }
      app.destroy(true, { children: true, texture: true, baseTexture: true });
    };
  }, [modelPath]);

  return <canvas ref={canvasRef} />;
}

export default Live2DComponent;










