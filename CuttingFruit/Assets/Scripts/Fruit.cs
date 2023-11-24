using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Fruit : MonoBehaviour
{
    public GameObject fruitSlicedPrefab;
    Rigidbody2D rb;
    public float startForce = 15f;

    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        rb.AddForce(transform.up * startForce, ForceMode2D.Impulse);
    }

    void OnTriggerEnter2D(Collider2D col)
    {
        /*
        @Param: col -> the blade -> is the current position of mouse
        */
        Debug.Log("ENTERED TRIGGER FUNCITON HERE");
        if (col.gameObject.CompareTag("Blade"))
        {

            Vector3 direction = (col.transform.position - transform.position).normalized;

            Quaternion rotation = Quaternion.LookRotation(direction);

            Debug.Log("WE HIT A WATERMELON");
            Instantiate(fruitSlicedPrefab, transform.position, rotation);
            Destroy(gameObject);
        }
    }
}
