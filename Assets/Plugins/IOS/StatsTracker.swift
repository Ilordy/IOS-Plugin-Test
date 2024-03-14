import Foundation

@objc public class StatsTracker : NSObject {
    
    @objc public static let instance = StatsTracker()
    private var isTracking = false
    private var timer: Timer?
    private var cpuUsageSamples: [Float] = []
    private var ramUsageSamples: [Float] = []
    private var gpuUsageSamples: [Float] = []
    private var cpuAvg: Float = 0
    private var ramAvg: Float = 0
    

    @objc public func GetCpuAVG() -> Float{
        return cpuAvg
    }
    
    @objc public func GetRamAvg() -> Float {
        return ramAvg
    }
    
       // Start tracking CPU and RAM usage
     @objc public func startTracking() {
           isTracking = true
           cpuUsageSamples.removeAll()
           ramUsageSamples.removeAll()
           timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(sampleUsage), userInfo: nil, repeats: true)
       }

       // Stop tracking and return the average usage
      @objc public func stopTracking() -> () {
           isTracking = false
           timer?.invalidate()
           timer = nil
           cpuAvg = cpuUsageSamples.reduce(0, +) / Float(cpuUsageSamples.count)
           ramAvg = ramUsageSamples.reduce(0, +) / Float(ramUsageSamples.count)
       }

       @objc private func sampleUsage() {
           sampleCpuUsage()
           sampleRamUsage()
       }
    
    func getCpuUsage() -> Float {
        var totalUsage: Float = 0.0
        
        // Get the number of processors and the current processor tick information
        var processorInfo: processor_info_array_t?
        var processorMsgCount: mach_msg_type_number_t = 0
        var processorCount: natural_t = 0
        
        let result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &processorCount, &processorInfo, &processorMsgCount)
        
        if result == KERN_SUCCESS {
            var totalSystemTime: UInt32 = 0, totalUserTime: UInt32 = 0, totalIdleTime: UInt32 = 0
            
            for i in 0..<Int(processorCount) {
                let offset = Int(CPU_STATE_MAX * Int32(i))
                totalUserTime += UInt32(processorInfo![offset + Int(CPU_STATE_USER)])
                totalSystemTime += UInt32(processorInfo![offset + Int(CPU_STATE_SYSTEM)])
                totalIdleTime += UInt32(processorInfo![offset + Int(CPU_STATE_IDLE)])
            }
            
            totalUsage = Float(totalUserTime + totalSystemTime) / Float(totalUserTime + totalSystemTime + totalIdleTime)
            
            // Deallocate the processor info
            let deallocResult = vm_deallocate(mach_task_self_, vm_address_t(bitPattern: processorInfo), vm_size_t(processorMsgCount * UInt32(MemoryLayout<processor_info_t>.size)))
            if deallocResult != KERN_SUCCESS {
                print("Error deallocating processor info: \(deallocResult)")
            }
            
            return totalUsage * 100.0 // Convert to percentage
        } else {
            print("Failed to get CPU usage: \(result)")
            return -1 // Indicate failure
        }
    }
    
    
    func getRamUsage() -> Float {
        let processInfo = ProcessInfo.processInfo
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            task_info(mach_task_self_,
                      task_flavor_t(MACH_TASK_BASIC_INFO),
                      $0.withMemoryRebound(to: integer_t.self, capacity: 1) { zeroPtr in
                          UnsafeMutablePointer<Int32>(zeroPtr)
                      },
                      &count)
        }

        if kerr == KERN_SUCCESS {
            // taskInfo.resident_size is the amount of memory used by the app in bytes
            return Float(taskInfo.resident_size)
        } else {
            print("Error with task_info(): \(String(describing: strerror(kerr)))")
            return 0
        }
    }
    
       private func sampleCpuUsage() {
           let cpuUsage = getCpuUsage()
           cpuUsageSamples.append(cpuUsage)
       }

       private func sampleRamUsage() {
           let ramUsage = getRamUsage()
           ramUsageSamples.append(Float(ramUsage))
       }
    
}
