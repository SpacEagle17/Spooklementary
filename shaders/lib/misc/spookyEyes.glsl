void doSpookyEyes(
    inout vec3 color,
    float fractLengthDist,
    vec3 worldGeoNormal,
    vec3 worldPos,
    vec3 blockUV,
    float skyLightCheck,
    int mat
) {
    if (fractLengthDist > 16 && mat % 2 == 0) {
        vec3 eyes1 = vec3(0.0);
        vec3 eyes2 = vec3(0.0);
        
        // Static hash for this block (doesn't change over time)
        vec3 blockPosStatic = floor(worldPos + atMidBlock / 64);
        
        float sideRandom = hash13(mod(blockPosStatic + frameTimeCounter * 0.000005, vec3(100)));
        vec3 blockUVEyes = blockUV;
        if (step(0.5, sideRandom) > 0.0) {
            blockUVEyes.x = 0.0;
        } else {
            blockUVEyes.z = 0.0;
        }
        float spookyEyesFrequency = EYE_FREQUENCY;
        float spookyEyesSpeed = EYE_SPEED;

        if (isTimeEventActive(1, 1.5, 2)) spookyEyesFrequency = 20.0; // make eyes appear everywhere

        // Horizontal eyes (25% chance) - kept the same
        if ((blockUVEyes.x > 0.15 && blockUVEyes.x < 0.43 || blockUVEyes.x < 0.85 && blockUVEyes.x > 0.57 || blockUVEyes.z > 0.15 && blockUVEyes.z < 0.43 || blockUVEyes.z < 0.85 && blockUVEyes.z > 0.57)
            && blockUVEyes.y > 0.44 && blockUVEyes.y < 0.56 && abs(clamp01(dot(normal, upVec))) < 0.99)
            eyes1 = vec3(1.0);
        
        // Vertical eyes (75% chance)
        if ((blockUVEyes.x > 0.65 && blockUVEyes.x < 0.8 || blockUVEyes.x < 0.35 && blockUVEyes.x > 0.2 || blockUVEyes.z > 0.65 && blockUVEyes.z < 0.8 || blockUVEyes.z < 0.35 && blockUVEyes.z > 0.2)
            && blockUVEyes.y > 0.35 && blockUVEyes.y < 0.65 && abs(clamp01(dot(normal, upVec))) < 0.99)
            eyes2 = vec3(1.0);

        // Use static hash to pick eye type (won't change during cycle)
        vec3 spookyEyes = mix(eyes1, eyes2, step(0.75, hash13(mod(blockPosStatic + vec3(123.45), vec3(100)))));

        // Probability of eyes appearing on a block
        spookyEyes *= vec3(step(1.0075 - spookyEyesFrequency * 0.0079, hash13(mod(blockPosStatic + frameTimeCounter * 0.0000005 * spookyEyesSpeed, vec3(100)))));
        
        // Static hash for eye color selection
        vec3 eyesColor = mix(vec3(1.0), vec3(1.7, 0.0, 0.0), vec3(step(1.0 - EYE_RED_PROBABILITY * mix(1.0, 2.0, getBloodMoon(sunVisibility)), hash13(mod(blockPosStatic + vec3(456.78), vec3(500))))));
        
        // Blink effect - each block has its own unique blink phase
        float blockBlinkOffset = hash13(mod(blockPosStatic + vec3(789.01), vec3(100))) * 1000.0; // Unique offset per block
        vec2 flickerEyeNoise = texture2DLod(noisetex, vec2(frameTimeCounter * 0.025 + blockBlinkOffset), 0.0).rb;
        float blinkThreshold = 0.15; // Lower threshold = eyes stay open more often
        float eyesOpen = step(blinkThreshold, max(flickerEyeNoise.r, flickerEyeNoise.g));
        
        color += spookyEyes * eyesOpen * 1.5 * skyLightCheck * clamp((1.0 - 1.15 * lmCoord.x) * 10.0, 0.0, 1.0) * eyesColor;
    }
}