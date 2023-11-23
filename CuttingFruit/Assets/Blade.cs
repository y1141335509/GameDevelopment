using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Blade : MonoBehaviour
{
    private bool isCutting = false;

    Rigidbody2D rb;
    Camera cam;     // define the main camera

    void Start()
    {
        cam = Camera.main;                  // get the main camera
        rb = GetComponent<Rigidbody2D>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            StartCutting();
        }
        else if (Input.GetMouseButtonUp(0))
        {
            StopCutting();
        }

        if (isCutting)
        {
            UpdateCut();
        }
    }

    void StartCutting()
    {
        isCutting = true;
    }

    void StopCutting()
    {
        isCutting = false;
    }

    void UpdateCut()
    {
        rb.position = cam.ScreenToWorldPoint(Input.mousePosition);      // the current mouse position.
    }
}
