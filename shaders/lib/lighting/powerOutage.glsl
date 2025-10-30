void doPowerOutage(inout float emission, inout vec2 lmCoordM, vec3 worldPos, out float nearPlayerOutage, bool turnOffImmediately) {
    float shrinkCycle = 150.0;
    float shrinkVelocity = 8.0;
    float shrinkPause = 10.0;

    float totalCycleTime = shrinkCycle + shrinkPause * shrinkVelocity;
    float timeSinceActivation = 0.0;
    bool eventActive = isTimeEventActive(6, totalCycleTime / shrinkVelocity, 4, timeSinceActivation);
    nearPlayerOutage = 1.0;

    if (!eventActive) return;

    float t = mod(timeSinceActivation * shrinkVelocity, totalCycleTime);
    // t = mod(frameTimeCounter * shrinkVelocity, totalCycleTime); // for testing purposes
    
    int chunkSize = 16;
    vec2 d = abs(worldPos.xz - cameraPositionBestInt.xz);
    float exactDistance = max(d.x, d.y) / float(chunkSize);
    
    // Calculate edge position
    float playerThreshold = 1.6;
    float edgePosition = (shrinkCycle - t) / float(chunkSize);
    
    // Handle pause phase - everything dark
    if (t >= shrinkCycle) {
        emission = 0.0;
        lmCoordM.x = 0.0;
        nearPlayerOutage = 0.0;
        return;
    }

    // Immediate fade to darkness when requested
    if (turnOffImmediately) {
        float fadeStart = 0.5 * shrinkVelocity; // 0.5 second delay
        float fadeDuration = 4.0 * shrinkVelocity; // 4 second fade
        
        if (t >= fadeStart) {
            float fadeDarkness = smoothstep(fadeStart, fadeStart + fadeDuration, t);
            
            emission *= (1.0 - fadeDarkness);
            lmCoordM.x *= (1.0 - fadeDarkness);
            nearPlayerOutage *= (1.0 - fadeDarkness);
            
            if (fadeDarkness >= 1.0) {
                return;
            }
        }
    }
    
    // Generate position-based noise
    ivec3 chunkPos = ivec3(floor(worldPos / chunkSize));
    vec2 dirVecXZ = normalize(worldPos.xz - cameraPositionBestInt.xz);
    float angle = atan(dirVecXZ.y, dirVecXZ.x);
    
    // Combined noise pattern
    float noise1 = hash13(vec3(chunkPos)) * 0.2;
    float noise2 = sin(angle * 4.0 + frameTimeCounter * 0.05) * 0.1;
    float noise3 = sin(dirVecXZ.x * 2.0 + frameTimeCounter * 0.03) * 
                cos(dirVecXZ.y * 1.5 + frameTimeCounter * 0.02) * 0.15;
    float boundaryNoise = (noise1 + noise2 + noise3 + hash13(vec3(floor(worldPos * 0.03))) * 0.1) * 0.7;
    
    // Calculate distance with noise
    float noisyDistance = exactDistance - min(boundaryNoise, edgePosition * 0.4);
    
    // Transition zone parameters
    float borderWidth = mix(1.0, 0.4, t / shrinkCycle) + noise1 * 0.2;
    float transStart = max(0.0, edgePosition - borderWidth * 0.5);
    float transEnd = edgePosition + borderWidth * 0.5;
    
    // Generate flicker effect for shrinking wave
    float timeStep = floor(frameTimeCounter * 15.0);
    float randVal = hash11(timeStep);
    float flicker;
    if (randVal < 0.05) {
        flicker = 1.0;
    } else if (randVal < 0.25) {
        flicker = hash11(timeStep * 5.7) < 0.6 ? 1.0 : 0.0;
    } else if (randVal < 0.75) {
        float flickerSpeed = mix(10.0, 25.0, hash11(floor(timeStep * 0.2)));
        flicker = hash11(floor(frameTimeCounter * flickerSpeed)) < 0.7 ? 1.0 : 0.0;
    } else {
        flicker = hash11(timeStep * 0.5) < 0.3 ? 1.0 : 0.0;
    }
    
    // Calculate transition with flicker for shrinking wave
    float transition = smoothstep(transStart, transEnd, noisyDistance);
    float flickerZone = smoothstep(transStart, transEnd - borderWidth * 0.3, noisyDistance) * 
                    smoothstep(transEnd, transEnd - borderWidth * 0.3, noisyDistance);
    
    float shrinkingDarkness = transition * mix(1.0, flicker, flickerZone);
    
    // Near-player flicker (faster, turns off completely)
    bool shouldBeOff = hash11(floor(frameTimeCounter * 25.0)) < 0.5 || t > shrinkCycle * 0.86;
    float nearPlayerFlicker = shouldBeOff ? 1.0 : 0.0;
    
    float blendStart = playerThreshold + 0.07;
    float waveApproachBlend = smoothstep(blendStart, playerThreshold, edgePosition);
    
    // Also consider distance from player
    float distanceBlend = smoothstep(playerThreshold + 0.5, playerThreshold - 0.3, exactDistance);
    
    float finalBlend = waveApproachBlend * distanceBlend;
    float darkness = mix(shrinkingDarkness, nearPlayerFlicker, finalBlend);
    
    emission *= (1.0 - darkness);
    lmCoordM.x *= (1.0 - darkness);
    nearPlayerOutage *= (1.0 - darkness);
}