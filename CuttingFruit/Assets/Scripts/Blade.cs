using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Blade : MonoBehaviour
{
    public GameObject bladeTrailPrefab;     // define the blade trail prefab
    public float minCuttingVelocity = .01f;        // min cutitng velocity

    private bool isCutting = false;
    Vector2 previousPosition;

    GameObject currentBladeTrail;

    Rigidbody2D rb;
    Camera cam;     // define the main camera
    CircleCollider2D circleCollider;

    void Start()
    {
        cam = Camera.main;                  // get the main camera
        rb = GetComponent<Rigidbody2D>();
        circleCollider = GetComponent<CircleCollider2D>();
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

    void UpdateCut()
    {
        Vector2 newPosition = cam.ScreenToWorldPoint(Input.mousePosition);      // the current mouse position.
        rb.position = newPosition;
        float velocity = (newPosition - previousPosition).magnitude * Time.deltaTime;

        if (velocity > minCuttingVelocity)
        {
            circleCollider.enabled = true;
        }
        else
        {
            circleCollider.enabled = false;
        }
        previousPosition = newPosition;
    }

    void StartCutting()
    {
        isCutting = true;
        currentBladeTrail = Instantiate(bladeTrailPrefab, transform);
        circleCollider.enabled = true;
    }

    void StopCutting()
    {
        isCutting = false;
        currentBladeTrail.transform.SetParent(null);    // 
        Destroy(currentBladeTrail, 2f);                  // destroy the trails after 2 seconds
        circleCollider.enabled = false;
    }

}
