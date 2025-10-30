#if CLOUD_QUALITY == 1 || !defined DEFERRED1
    const float cloudStretchRaw = 11.0;
#elif CLOUD_QUALITY == 2
    const float cloudStretchRaw = 16.0;
#elif CLOUD_QUALITY == 3
    const float cloudStretchRaw = 18.0;
#endif
#if CLOUD_UNBOUND_SIZE_MULT <= 100
    const float cloudStretch = cloudStretchRaw * 2;
#else
    const float cloudStretch = cloudStretchRaw / float(CLOUD_UNBOUND_SIZE_MULT_M);
#endif

const float cloudTallness = cloudStretch * 2.0;
const float cloudNarrowness = 0.00012;

float GetCloudNoise(vec3 tracePos, int cloudAltitude, float lTracePosXZ, float cloudPlayerPosY) {
    vec3 tracePosM = tracePos.xyz * cloudNarrowness;
    float wind = 0.0006;
    float noise = 0.0;
    float currentPersist = 1.0;
    float total = 0.0;

    #if CLOUD_SPEED_MULT == 100
        #define CLOUD_SPEED_MULT_M CLOUD_SPEED_MULT * 0.01
        wind *= syncedTime;
    #else
        #define CLOUD_SPEED_MULT_M CLOUD_SPEED_MULT * 0.01
        wind *= frameTimeCounter * CLOUD_SPEED_MULT_M;
    #endif
    #if CLOUD_UNBOUND_SIZE_MULT != 100
        tracePosM *= CLOUD_UNBOUND_SIZE_MULT_M;
        wind *= CLOUD_UNBOUND_SIZE_MULT_M;
    #endif

    #if CLOUD_QUALITY == 1
        int sampleCount = 2;
        float persistance = 0.6;
        float noiseMult = 0.95;
        tracePosM *= 0.5; wind *= 0.5;
    #elif CLOUD_QUALITY == 2 || !defined DEFERRED1
        int sampleCount = 4;
        float persistance = 0.5;
        float noiseMult = 1.07;
    #elif CLOUD_QUALITY == 3
        int sampleCount = 4;
        float persistance = 0.5;
        float noiseMult = 1.0;
    #endif

    #ifndef DEFERRED1
        noiseMult *= 1.2;
    #endif

    for (int i = 0; i < sampleCount; i++) {
        #if CLOUD_QUALITY >= 2
            noise += Noise3D(tracePosM + vec3(wind, 0.0, 0.0)) * currentPersist;
        #else
            noise += texture2DLod(noisetex, tracePosM.xz + vec2(wind, 0.0), 0.0).b * currentPersist;
        #endif
        total += currentPersist;

        tracePosM *= 3.0;
        wind *= 0.5;
        currentPersist *= persistance;
    }
    noise = pow2(noise / total);

    #define CLOUD_BASE_ADD 0.8
    //#define CLOUD_FAR_ADD -0.005
    #define CLOUD_ABOVE_ADD 0.1

    noiseMult *= CLOUD_BASE_ADD
                //+ CLOUD_FAR_ADD * sqrt(lTracePosXZ + 10.0) // more/less clouds far away
                + CLOUD_ABOVE_ADD * clamp01(-cloudPlayerPosY / cloudTallness) // more clouds when camera is above them
                + CLOUD_UNBOUND_RAIN_ADD * rainFactor; // more clouds during rain
    noise *= noiseMult * CLOUD_UNBOUND_AMOUNT;

    float threshold = clamp(abs(cloudAltitude - tracePos.y) / cloudStretch, 0.001, 0.999);
    threshold = pow2(pow2(pow2(threshold)));
    return noise - (threshold * 0.2 + 0.25);
}

vec4 GetVolumetricClouds(int cloudAltitude, float distanceThreshold, inout float cloudLinearDepth, float skyFade, float skyMult0, vec3 cameraPos, vec3 nPlayerPos, float lViewPosM, float VdotS, float VdotU, float dither) {
    vec4 volumetricClouds = vec4(0.0);

    float higherPlaneAltitude = cloudAltitude + cloudStretch;
    float lowerPlaneAltitude  = cloudAltitude - cloudStretch;

    float lowerPlaneDistance  = (lowerPlaneAltitude - cameraPos.y) / nPlayerPos.y;
    float higherPlaneDistance = (higherPlaneAltitude - cameraPos.y) / nPlayerPos.y;
    float minPlaneDistance = min(lowerPlaneDistance, higherPlaneDistance);
          minPlaneDistance = max(minPlaneDistance, 0.0);
    float maxPlaneDistance = max(lowerPlaneDistance, higherPlaneDistance);
    if (maxPlaneDistance < 0.0) return vec4(0.0);
    float planeDistanceDif = maxPlaneDistance - minPlaneDistance;

    #ifndef DEFERRED1
        float stepMult = 32.0;
    #elif CLOUD_QUALITY == 1
        float stepMult = 16.0;
    #elif CLOUD_QUALITY == 2
        float stepMult = 24.0;
    #elif CLOUD_QUALITY == 3
        float stepMult = 16.0;
    #endif

    #if CLOUD_UNBOUND_SIZE_MULT > 100
        stepMult = stepMult / sqrt(float(CLOUD_UNBOUND_SIZE_MULT_M));
    #endif

    int sampleCount = int(planeDistanceDif / stepMult + dither + 1);
    vec3 traceAdd = nPlayerPos * stepMult;
    vec3 tracePos = cameraPos + minPlaneDistance * nPlayerPos;
    tracePos += traceAdd * dither;
    tracePos.y -= traceAdd.y;

    float firstHitPos = 0.0;
    float VdotSM1 = max0(sunVisibility > 0.5 ? VdotS : - VdotS);
    float VdotSM1M = VdotSM1 * invRainFactor;
    float VdotSM2 = pow2(VdotSM1) * abs(sunVisibility - 0.5) * 2.0;
    float VdotSM3 = VdotSM2 * (2.5 + rainFactor) + 1.5 * rainFactor;

    #ifdef FIX_AMD_REFLECTION_CRASH
        sampleCount = min(sampleCount, 30); //BFARC
    #endif

    for (int i = 0; i < sampleCount; i++) {
        tracePos += traceAdd;

        if (abs(tracePos.y - cloudAltitude) > cloudStretch) break;

        vec3 cloudPlayerPos = tracePos - cameraPos;
        float lTracePos = length(cloudPlayerPos);
        float lTracePosXZ = length(cloudPlayerPos.xz);
        float cloudMult = 1.0;
        if (lTracePosXZ > distanceThreshold) break;
        if (lTracePos > lViewPosM) {
            if (skyFade < 0.7) continue;
            else cloudMult = skyMult0;
        }

        float cloudNoise = GetCloudNoise(tracePos, cloudAltitude, lTracePosXZ, cloudPlayerPos.y);

        if (cloudNoise > 0.00001) {
            #if defined CLOUD_CLOSED_AREA_CHECK && SHADOW_QUALITY > -1
                float shadowLength = shadowDistance * 0.9166667; //consistent08JJ622
                if (shadowLength < lTracePos)
                if (GetShadowOnCloud(tracePos, cameraPos, cloudAltitude, lowerPlaneAltitude, higherPlaneAltitude)) {
                    if (eyeBrightness.y != 240) continue;
                }
            #endif

            if (firstHitPos < 1.0) {
                firstHitPos = lTracePos;
                #if CLOUD_QUALITY == 1 && defined DEFERRED1
                    tracePos.y += 4.0 * (texture2DLod(noisetex, tracePos.xz * 0.001, 0.0).r - 0.5);
                #endif
            }

            float opacityFactor = min1(cloudNoise * 8.0);

            float cloudShading = 1.0 - (higherPlaneAltitude - tracePos.y) / cloudTallness;
            cloudShading *= 1.0 + 0.2 * VdotSM3 * (1.0 - opacityFactor);

            vec3 worldLightVec = mat3(gbufferModelViewInverse) * sunVec;
            float cloudLightRadius = 375.0;

            float aboveFade = clamp01(1.0 - (cameraPos.y - cloudAltitude) / (cloudTallness * 3.0));
            float radiusFactor = mix(cloudLightRadius * 8.0, cloudLightRadius, aboveFade);
            float moonVisibility = abs(1.0 - moonPhase / 4.0);
            float sunMult = mix(moonVisibility, 0.85, sunVisibility);

            float sunPlaneIntersect = (cloudAltitude - cameraPos.y) / worldLightVec.y;
            vec2 posVector = cameraPos.xz + worldLightVec.xz * sunPlaneIntersect - tracePos.xz;
            float falloff = exp((1.0 - max0(1.0 - length(posVector) / radiusFactor)) * -6.0) * aboveFade * sunMult;

            vec3 bloodMoonCloudColor = vec3(1.0);
            #if BLOOD_MOON > 0
                auroraSpookyMix = getBloodMoon(sunVisibility);
                bloodMoonCloudColor = mix(bloodMoonCloudColor, vec3(0.3412, 0.0118, 0.0118), auroraSpookyMix);
            #endif
            float moonShadingFactor = clamp01(falloff * mix(1.0, 2.0, aboveFade) * mix(1.0, (lTracePos - minPlaneDistance) / (maxPlaneDistance - minPlaneDistance), 0.75));
            cloudLightColor += bloodMoonCloudColor * moonShadingFactor * 0.6;
            cloudShading += moonShadingFactor * 0.3;

            vec3 colorSample = cloudAmbientColor * (0.4 + 0.6 * cloudShading) + cloudLightColor * cloudShading;
            //vec3 colorSample = 2.5 * cloudLightColor * pow2(cloudShading); // <-- Used this to take the Unbound logo

            vec3 lightningPos = getLightningPos(tracePos - cameraPos, lightningBoltPosition.xyz, false);
            vec2 lightningAdd = lightningFlashEffect(lightningPos, vec3(1.0), 550.0, 0.0, 0) * isLightningActive() * 10.0;
            colorSample += lightningAdd.y;

            vec3 cloudSkyColor = GetSky(VdotU, VdotS, dither, true, false);
            #ifdef ATM_COLOR_MULTS
                cloudSkyColor *= sqrtAtmColorMult; // C72380KD - Reduced atmColorMult impact on some things
            #endif
            float distanceRatio = (distanceThreshold - lTracePosXZ) / distanceThreshold;
            float cloudDistanceFactor = clamp(distanceRatio, 0.0, 0.8) * 1.25;
            float cloudFogFactor = pow2(pow1_5(clamp(distanceRatio, 0.0, 1.0)));
            float skyMult1 = 1.0 - 0.2 * (1.0 - skyFade) * max(sunVisibility2, nightFactor);
            float skyMult2 = 1.0 - 0.33333 * skyFade;
            colorSample = mix(cloudSkyColor, colorSample * skyMult1, cloudFogFactor * skyMult2 * 0.72);
            colorSample *= pow2(1.0 - maxBlindnessDarkness);

            volumetricClouds.rgb = mix(volumetricClouds.rgb, colorSample, 1.0 - min1(volumetricClouds.a));
            volumetricClouds.a += opacityFactor * pow(cloudDistanceFactor, 0.5 + 10.0 * pow(abs(VdotSM1M), 90.0)) * cloudMult;

            if (volumetricClouds.a > 0.9) {
                volumetricClouds.a = 1.0;
                break;
            }
        }
    }

    if (volumetricClouds.a > 0.5) cloudLinearDepth = sqrt(firstHitPos / renderDistance);

    return volumetricClouds;
}