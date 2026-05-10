import Foundation
import CoreFoundation
import Metal

let n = CommandLine.arguments.dropFirst().first.flatMap(Int.init) ?? (1 << 24)
let bytes = n * MemoryLayout<Float>.stride

guard let device = MTLCreateSystemDefaultDevice(),
      let queue = device.makeCommandQueue() else {
    fatalError("Metal device not available")
}

let source = """
#include <metal_stdlib>
using namespace metal;

kernel void saxpy(device const float *x [[buffer(0)]],
                  device float *y [[buffer(1)]],
                  constant float &a [[buffer(2)]],
                  constant uint &n [[buffer(3)]],
                  uint i [[thread_position_in_grid]]) {
    if (i < n) {
        y[i] = a * x[i] + y[i];
    }
}
"""

let library: MTLLibrary
do {
    library = try device.makeLibrary(source: source, options: nil)
} catch {
    fatalError("Could not compile Metal kernel: \(error)")
}
guard let function = library.makeFunction(name: "saxpy") else {
    fatalError("Missing saxpy kernel")
}
let pipeline: MTLComputePipelineState
do {
    pipeline = try device.makeComputePipelineState(function: function)
} catch {
    fatalError("Could not create Metal pipeline: \(error)")
}

var xHost = [Float](repeating: 1.0, count: n)
var yHost = [Float](repeating: 2.0, count: n)

let xBuffer = xHost.withUnsafeBytes {
    device.makeBuffer(bytes: $0.baseAddress!, length: bytes, options: .storageModeShared)
}
let yBuffer = yHost.withUnsafeBytes {
    device.makeBuffer(bytes: $0.baseAddress!, length: bytes, options: .storageModeShared)
}

guard let xBuffer, let yBuffer else {
    fatalError("Could not allocate Metal buffers")
}

var a: Float = 3.0
var count = UInt32(n)

guard let commandBuffer = queue.makeCommandBuffer(),
      let encoder = commandBuffer.makeComputeCommandEncoder() else {
    fatalError("Could not create Metal command buffer")
}

encoder.setComputePipelineState(pipeline)
encoder.setBuffer(xBuffer, offset: 0, index: 0)
encoder.setBuffer(yBuffer, offset: 0, index: 1)
encoder.setBytes(&a, length: MemoryLayout<Float>.stride, index: 2)
encoder.setBytes(&count, length: MemoryLayout<UInt32>.stride, index: 3)

let threadsPerGroup = min(256, pipeline.maxTotalThreadsPerThreadgroup)
encoder.dispatchThreads(
    MTLSize(width: n, height: 1, depth: 1),
    threadsPerThreadgroup: MTLSize(width: threadsPerGroup, height: 1, depth: 1)
)
encoder.endEncoding()

let start = CFAbsoluteTimeGetCurrent()
commandBuffer.commit()
commandBuffer.waitUntilCompleted()
let elapsed = CFAbsoluteTimeGetCurrent() - start

if let error = commandBuffer.error {
    fatalError("Metal command failed: \(error)")
}

let result = yBuffer.contents().bindMemory(to: Float.self, capacity: n)
var maxError: Float = 0.0
for i in 0..<n {
    maxError = max(maxError, abs(result[i] - 5.0))
}

let gbps = Double(3 * bytes) / elapsed / 1e9
print(String(format: "N=%d, time=%.3f ms, %.1f GB/s", n, elapsed * 1e3, gbps))
print("max error = \(maxError)")
