using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Runtime.InteropServices;
using UnityEngine.UI;

public class StatsShowCaseUI : MonoBehaviour
{
    [SerializeField] private Text resultText;
    [SerializeField] private Button startBtn, stopBtn;

    [DllImport("__Internal")]
    private static extern float GetCPUUsage();


    [DllImport("__Internal")]
    private static extern float GetRamUsage();


    [DllImport("__Internal")]
    private static extern void StartTracker();


    [DllImport("__Internal")]
    private static extern void StopTracker();

    void Start()
    {
        startBtn.onClick.AddListener(TrackerStart);
        stopBtn.onClick.AddListener(TrackerStop);
        
    }

     void TrackerStart()
    {
        StartTracker();
        resultText.text = "Tracking...";
    }

     void TrackerStop()
    {
        StopTracker();
        resultText.text = $"Results: CPU: {GetCPUUsage().ToString()}, Ram: {GetRamUsage().ToString()}";
    }

}
