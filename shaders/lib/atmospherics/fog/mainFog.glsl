#ifdef ATM_COLOR_MULTS
    #include "/lib/colors/colorMultipliers.glsl"
#endif
#ifdef MOON_PHASE_INF_ATMOSPHERE
    #include "/lib/colors/moonPhaseInfluence.glsl"
#endif

#ifdef BORDER_FOG
    #ifdef OVERWORLD
        #include "/lib/atmospherics/sky.glsl"
    #elif defined NETHER
        #include "/lib/colors/skyColors.glsl"
    #endif

    void DoBorderFog(inout vec4 color, inout float skyFade, float lPos, float VdotU, float VdotS, float dither) {
        #ifdef OVERWORLD
            float fog = lPos / renderDistance;
            float rainMix = mix(1.0, 2.5, rainFactor);
            #ifndef DISTANT_HORIZONS
                fog *= fog;
                fog = 1.0 - exp(-3.0 * fog * rainMix);
            #else
                fog = 1.0 - exp(-5.0 * fog * rainMix);
            #endif
            if (isEyeInWater > 0) fog *= pow3(fog);
        #endif
        #ifdef NETHER
            float farM = min(renderDistance, NETHER_VIEW_LIMIT); // consistency9023HFUE85JG
            float fog = lPos / farM;
            fog = fog * 0.3 + 0.7 * pow(fog, 256.0 / max(farM, 256.0));
        #endif
        #ifdef END
            float fog = lPos / renderDistance;
            fog = pow2(pow2(fog));
            fog = 1.0 - exp(-3.0 * fog);
        #endif

        if (fog > 0.0) {
            fog = clamp(fog, 0.0, 1.0);

            #ifdef OVERWORLD
                vec3 fogColorM = GetSky(VdotU, VdotS, dither, true, false);
            #elif defined NETHER
                vec3 fogColorM = netherColor;
            #else
                vec3 fogColorM = endSkyColor;
            #endif

            #ifdef ATM_COLOR_MULTS
                fogColorM *= atmColorMult;
            #endif
            #ifdef MOON_PHASE_INF_ATMOSPHERE
                fogColorM *= moonPhaseInfluence;
            #endif

            color = mix(color, vec4(fogColorM, 0.0), fog);

            #ifndef GBUFFERS_WATER
                skyFade = fog;
            #else
                skyFade = fog * (1.0 - isEyeInWater);
            #endif
        }
    }
#endif

#ifdef CAVE_FOG
    #include "/lib/atmospherics/fog/caveFactor.glsl"

    void DoCaveFog(inout vec4 color, float lViewPos) {
        float fog = GetCaveFactor() * (1.2 - 1.4 * exp(-lViewPos * 0.03));
        float fogSmooth = smoothstep(0.0, 1.0, fog);
        color = mix(color, vec4(caveFogColor, 0.0), fogSmooth);
    }
#endif

#ifdef ATMOSPHERIC_FOG
    #include "/lib/colors/lightAndAmbientColors.glsl"
    #include "/lib/colors/skyColors.glsl"

    // SRATA: Atm. fog starts reducing above this altitude
    // CRFTM: Atm. fog continues reducing for this meters
    #ifdef OVERWORLD
        #define atmFogSRATA ATM_FOG_ALTITUDE + 0.1
        #ifndef DISTANT_HORIZONS
            float atmFogCRFTM = 60.0;
        #else
            float atmFogCRFTM = 90.0;
        #endif

        vec3 GetAtmFogColor(float altitudeFactorRaw, float VdotS) {
            float nightFogMult = 2.5 - 0.625 * max(pow2(pow2(altitudeFactorRaw)), rainFactor);
            float dayNightFogBlend = pow(invNightFactor, 4.0 - VdotS - 2.5 * sunVisibility2);
            vec3 bloodMoonColor = vec3(1.0);
            #if BLOOD_MOON > 0
                auroraSpookyMix = getBloodMoon(sunVisibility);
                bloodMoonColor = mix(bloodMoonColor, vec3(2.5, 1, 1), auroraSpookyMix);
            #endif
            return mix(
                nightUpSkyColor * bloodMoonColor * (nightFogMult - dayNightFogBlend * nightFogMult),
                dayDownSkyColor * (0.9 + 0.2 * noonFactor),
                dayNightFogBlend
            );
        }
    #else
        float atmFogSRATA = 55.1;
        float atmFogCRFTM = 30.0;
    #endif

    float GetAtmFogAltitudeFactor(float altitude) {
        float altitudeFactor = pow2(1.07 - clamp(altitude - atmFogSRATA, 0.0, atmFogCRFTM) / atmFogCRFTM);
        #ifndef LIGHTSHAFTS_ACTIVE
            altitudeFactor = mix(altitudeFactor, 1.0, rainFactor * 0.2);
        #endif
        return altitudeFactor;
    }

    #define VOL_FOG_AMOUNT 0.6

    void DoAtmosphericFog(inout vec4 color, vec3 playerPos, float lViewPos, float VdotS, vec2 lmCoord) {
        #ifndef DISTANT_HORIZONS
            float renDisFactor = min1(192.0 / renderDistance);

            #if ATM_FOG_DISTANCE != 100
                #define ATM_FOG_DISTANCE_M 100.0 / ATM_FOG_DISTANCE;
                renDisFactor *= ATM_FOG_DISTANCE_M;
            #endif

            float fog = 1.0 - exp(-pow(lViewPos * (mix(0.00015, 0.001, pow2(invNoonFactor))), 2.0 - rainFactor2) * lViewPos * renDisFactor * 100.0);
        #else
            float fog = pow2(1.0 - exp(-max0(lViewPos) * (mix(0.2, 1.0, pow2(invNoonFactor)) + 0.7 * rainFactor) / ATM_FOG_DISTANCE));
        #endif

        float volumeHeightStart = 95.0;
        float volumeHeightRange = 130.0;
        float volumeHeightFactor = 1.0 - clamp((cameraPosition.y - volumeHeightStart) / volumeHeightRange, 0.0, 1.0);

        float volumeDistStart = 90.0;
        float volumeDistRange = 300.0;
        float t = clamp((lViewPos - volumeDistStart) / volumeDistRange, 0.0, 1.0);
        t = pow(t, 0.66);
        float volumeDistanceFactor = 1.0 - smoothstep(0.0, 1.0, t);

        float finalVolumeFactor = volumeHeightFactor * volumeDistanceFactor;
        finalVolumeFactor = clamp(finalVolumeFactor, 0.0, 1.0);
        vec3 worldPos = playerPos + cameraPosition;

        if (finalVolumeFactor > 0.0) {
            vec3 fogPos = 0.0008 * (worldPos * 0.85 + vec3(cameraPosition.x, 0.0, cameraPosition.z) * 0.15);
            fogPos.y *= 2.0;
            vec3 fogWind = frameTimeCounter * vec3(0.002, 0.001, 0.00007) * 0.8;

            #if defined GBUFFERS_WATER || defined DH_WATER
                finalVolumeFactor *= mix(0.3, 1.0, pow2(invNoonFactor));
                fogPos *= 0.6;
            #endif

            // Multi-octave noise for varied fog detail
            float noise = 0.65 * Noise3D(fogPos + fogWind)
                        + 0.25 * Noise3D((fogPos - fogWind) * 3.0)
                        + 0.10 * Noise3D((fogPos + fogWind) * 9.0);
            
            noise = smoothstep(0.3, 0.7, noise);
            
            float heightFactor = 1.0 - smoothstep(5.0, 40.0, worldPos.y);
            
            float volAmount = VOL_FOG_AMOUNT * finalVolumeFactor;
            fog = mix(fog, fog * (0.8 + 0.4 * noise) * (1.0 + heightFactor), volAmount);
        }
        
        fog *= ATM_FOG_MULT - 0.1 - 0.15 * invRainFactor;

        float altitudeFactorRaw = GetAtmFogAltitudeFactor(playerPos.y + cameraPosition.y);
        
        #ifndef DISTANT_HORIZONS
            float altitudeFactor = altitudeFactorRaw * 0.9 + 0.1;
        #else
            float altitudeFactor = altitudeFactorRaw * 0.8 + 0.2;
        #endif

        #ifdef OVERWORLD
            altitudeFactor *= 1.0 - 0.15 * GetAtmFogAltitudeFactor(cameraPosition.y) * invRainFactor;

            #if defined SPECIAL_BIOME_WEATHER || RAIN_STYLE == 2
                #if RAIN_STYLE == 2
                    float factor = 1.0;
                #else
                    float factor = max(inSnowy, inDry);
                #endif

                float fogFactor = 4.0;
                #ifdef SPECIAL_BIOME_WEATHER
                    fogFactor += 2.0 * inDry;
                #endif
                fogFactor *= 0.5 + 0.5 * sunVisibility;

                float fogIntense = pow2(1.0 - exp(-lViewPos * fogFactor / ATM_FOG_DISTANCE));
                fog = mix(fog, fogIntense / altitudeFactor, 0.8 * rainFactor * factor);
            #endif

            #ifdef CAVE_FOG
                fog *= 0.2 + 0.8 * sqrt2(eyeBrightnessM);
                fog *= 1.0 - GetCaveFactor();
            #else
                fog *= eyeBrightnessM;
            #endif
            float heightBlend = clamp01(smoothstep(atmFogSRATA, 0.0, worldPos.y));
            float brightnessMult = mix(0.3, 0.85, heightBlend);
            float brightnessAdd = mix(0.7, 0.15, heightBlend);
            fog *= mix(smoothstep(0.0, 0.9, lmCoord.y) * brightnessMult + brightnessAdd, 1.0, clamp(abs(cameraPosition.y - 66) / 50.0, 0.0, 1.0));
        #else
            fog *= 0.5;
        #endif

        float fogPlayerFade = 1.0 - clamp((atmFogSRATA - cameraPosition.y) / atmFogCRFTM, 0.0, 0.7);
        fog *= fogPlayerFade;

        fog *= altitudeFactor;

        if (fog > 0.0) {
            fog = clamp(fog, 0.0, 1.0);

            #ifdef OVERWORLD
                vec3 fogColorM = GetAtmFogColor(altitudeFactorRaw, VdotS);
                
                float moonValue = (moonPhase == 0) ? 0.5 : (moonPhase == 4) ? 0.0 : 0.3;
                float nightMix = smoothstep(0.0, 0.5, 1.0 - sunVisibility);
                float dayMix = 1.0 - nightMix;
                fogColorM = mix(
                    mix(fogColorM, vec3(0.4118, 0.4471, 0.5216), 0.25 * moonValue * nightMix),
                    mix(fogColorM, vec3(0.9686, 0.5686, 0.302) * dayDownSkyColor, 0.15 * dayMix),
                    dayMix
                );
            #else
                vec3 fogColorM = endSkyColor * 2.8;
            #endif

            #ifdef ATM_COLOR_MULTS
                fogColorM *= atmColorMult;
            #endif
            #ifdef MOON_PHASE_INF_ATMOSPHERE
                fogColorM *= moonPhaseInfluence;
            #endif

            color = mix(color, vec4(fogColorM, 0.0), fog);

            // color.rgb = vec3(smoothstep(0.0, 0.9, lmCoord.y) * 0.4 + 0.6);
        }
    }
#endif

#include "/lib/atmospherics/fog/waterFog.glsl"

void DoWaterFog(inout vec4 color, float lViewPos) {
    float fog = GetWaterFog(lViewPos);

    vec3 bloodMoonColor = vec3(1.0);
    #if BLOOD_MOON > 0
        auroraSpookyMix = getBloodMoon(sunVisibility);
        bloodMoonColor = mix(bloodMoonColor, vec3(1.0, 0.5922, 0.5922), auroraSpookyMix);
    #endif

    waterFogColor *= bloodMoonColor; 

    color = mix(color, vec4(waterFogColor, 0), fog);
}

void DoLavaFog(inout vec4 color, float lViewPos) {
    float fog = (lViewPos * 3.0 - gl_Fog.start) * gl_Fog.scale;

    #ifdef LESS_LAVA_FOG
        fog = sqrt(fog) * 0.4;
    #endif

    fog = 1.0 - exp(-fog);

    fog = clamp(fog, 0.0, 1.0);
    color = mix(color, vec4(fogColor * 5.0, 0.0), fog);
}

void DoPowderSnowFog(inout vec4 color, float lViewPos) {
    float fog = lViewPos;

    #ifdef LESS_LAVA_FOG
        fog = sqrt(fog) * 0.4;
    #endif

    fog *= fog;
    fog = 1.0 - exp(-fog);

    fog = clamp(fog, 0.0, 1.0);
    color = mix(color, vec4(fogColor, 0.0), fog);
}

void DoBlindnessFog(inout vec4 color, float lViewPos) {
    float fog = lViewPos * 0.3 * blindness;
    fog *= fog;
    fog = 1.0 - exp(-fog);

    fog = clamp(fog, 0.0, 1.0);
    color *= 1.0 - fog;
}

void DoDarknessFog(inout vec4 color, float lViewPos) {
    float fog = lViewPos * 0.075 * darknessFactor;
    fog *= fog;
    fog *= fog;
    color *= exp(-fog);
}

void DoFog(inout vec4 color, inout float skyFade, float lViewPos, vec3 playerPos, float VdotU, float VdotS, float dither, vec2 lmCoord) {
    #ifdef CAVE_FOG
        DoCaveFog(color, lViewPos);
    #endif
    #ifdef ATMOSPHERIC_FOG
        DoAtmosphericFog(color, playerPos, lViewPos, VdotS, lmCoord);
    #endif
    #ifdef BORDER_FOG
        DoBorderFog(color, skyFade, max(length(playerPos.xz), abs(playerPos.y)), VdotU, VdotS, dither);
    #endif

    if (isEyeInWater == 1) DoWaterFog(color, lViewPos);
    else if (isEyeInWater == 2) DoLavaFog(color, lViewPos);
    else if (isEyeInWater == 3) DoPowderSnowFog(color, lViewPos);

    if (blindness > 0.00001) DoBlindnessFog(color, lViewPos);
    if (darknessFactor > 0.00001) DoDarknessFog(color, lViewPos);
}