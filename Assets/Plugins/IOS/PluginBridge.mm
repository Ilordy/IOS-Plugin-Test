#import <Foundation/Foundation.h>
#include "UnityFramework/UnityFramework-Swift.h"

extern "C" {
float GetCPUUsage(){
        float result = [[StatsTracker instance] GetCpuAVG];
        return result;
    }
float GetRamUsage() {
        float result = [[StatsTracker instance] GetRamAvg];
        return result;
    }

void StartTracker(){
    [[StatsTracker instance] startTracking];
}

void StopTracker(){
    [[StatsTracker instance] stopTracking];
}
}
