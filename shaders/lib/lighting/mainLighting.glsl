//Lighting Includes//
#include "/lib/colors/lightAndAmbientColors.glsl"
#include "/lib/lighting/ggx.glsl"

#if SHADOW_QUALITY > -1 && (defined OVERWORLD || defined END)
    #include "/lib/lighting/shadowSampling.glsl"
#endif

#ifdef CLOUD_SHADOWS
    #include "/lib/lighting/cloudShadows.glsl"
#endif

#ifdef LIGHT_COLOR_MULTS
    #include "/lib/colors/colorMultipliers.glsl"
#endif

#if defined MOON_PHASE_INF_LIGHT || defined MOON_PHASE_INF_REFLECTION
    #include "/lib/colors/moonPhaseInfluence.glsl"
#endif

#if COLORED_LIGHTING_INTERNAL > 0
    #include "/lib/voxelization/lightVoxelization.glsl"
#endif

#ifdef DO_PIXELATION_EFFECTS
    #include "/lib/misc/pixelation.glsl"
#endif

#include "/lib/lighting/powerOutage.glsl"

vec3 highlightColor = normalize(pow(lightColor, vec3(0.37))) * (0.3 + 1.5 * sunVisibility2) * (1.0 - 0.85 * rainFactor);

//Lighting//
void DoLighting(inout vec4 color, inout vec3 shadowMult, vec3 playerPos, vec3 viewPos, float lViewPos, vec3 geoNormal, vec3 normalM, float dither,
                vec3 worldGeoNormal, vec2 lightmap, bool noSmoothLighting, bool noDirectionalShading, bool noVanillaAO,
                bool centerShadowBias, int subsurfaceMode, float smoothnessG, float highlightMult, float emission, inout float purkinjeOverwrite, bool isLightSource) {
    vec3 worldPos = playerPos + cameraPosition;

    float nearPlayerOutage = 1.0;
    doPowerOutage(emission, lightmap, worldPos, nearPlayerOutage, false);

    lightmap.x *= 0.85;
    #ifdef DO_PIXELATION_EFFECTS
        vec2 pixelationOffset = ComputeTexelOffset(tex, texCoord);

        #if defined PIXELATED_SHADOWS || defined PIXELATED_BLOCKLIGHT
            vec3 playerPosPixelated = TexelSnap(playerPos, pixelationOffset);
        #endif

        #ifdef PIXELATED_SHADOWS
            #ifdef GBUFFERS_ENTITIES
                if (entityId == 50076) { // Boats
                    playerPosPixelated.y += 0.38; // consistentBOAT2176
                }
            #endif
            #ifdef GBUFFERS_TERRAIN
                if (subsurfaceMode == 1) {
                    playerPosPixelated.y += 0.05; // Fixes grounded foliage having dark bottom pixels depending on the random y-offset
                }
            #endif
        #endif
        #ifdef PIXELATED_BLOCKLIGHT
            if (!noSmoothLighting) {
                lightmap = clamp(TexelSnap(lightmap, pixelationOffset), 0.0, 1.0);
            }
        #endif
    #endif

    float NdotN = dot(normalM, northVec);
    float absNdotN = abs(NdotN);
    float NdotE = dot(normalM, eastVec);
    float absNdotE = abs(NdotE);
    float NdotL = dot(normalM, lightVec);

    float lightmapY2 = pow2(lightmap.y);
    float lightmapYM = smoothstep1(lightmap.y);
    float subsurfaceHighlight = 0.0;
    float ambientMult = 1.0;
    vec3 subsurfaceColor = vec3(1.0);
    #if BLOOD_MOON > 0
        auroraSpookyMix = getBloodMoon(sunVisibility);
        lightColor *= 1.0 + auroraSpookyMix * vec3(1.7, -0.65, -0.65);
        ambientColor *= 1.0 + auroraSpookyMix * vec3(1.7, -0.65, -0.65);
        subsurfaceColor = mix(vec3(1.0), vec3(1.3, 0.2, 0.2), auroraSpookyMix);
    #endif
    vec3 lightColorM = lightColor;
    vec3 ambientColorM = ambientColor;
    vec3 nViewPos = normalize(viewPos);

    #if defined LIGHT_COLOR_MULTS && !defined GBUFFERS_WATER // lightColorMult is defined early in gbuffers_water
        lightColorMult = GetLightColorMult();
    #endif

    float lightningDistance = 550.0;
    vec3 lightningPos = getLightningPos(playerPos, lightningBoltPosition.xyz, false);
    float lightningFadeOut = max(1.0 - length(lightningPos) / lightningDistance, 0.0);
    float lightningFadeOutExp = exp((1.0 - lightningFadeOut) * -15.0);
    vec3 normalLightning = mat3(gbufferModelViewInverse) * mix(geoNormal, normalM, 0.25);
    float lightningNormalGradient = 0.12;
    if (subsurfaceMode == 1) lightningNormalGradient = mix(lightningNormalGradient, 0.45, lightningFadeOutExp);
    vec2 lightningAdd = (lightningFlashEffect(lightningPos, normalLightning, lightningDistance, lightningNormalGradient, subsurfaceMode) * 10.0 + mix(0.1, 0.0 , lightningFadeOut)) * isLightningActive();
    ambientColorM += lightningAdd.x;

    #ifdef OVERWORLD
        float skyLightShadowMult = pow2(pow2(lightmapY2));
    #else
        float skyLightShadowMult = 1.0;
    #endif

    #if defined CUSTOM_PBR || defined GENERATED_NORMALS
        float NPdotU = abs(dot(geoNormal, upVec));
    #endif

    // Shadows
    #if defined OVERWORLD || defined END
        #ifdef GBUFFERS_WATER
            //NdotL = mix(NdotL, 1.0, 1.0 - color.a);
        #endif
        #ifdef CUSTOM_PBR
            float geoNdotL = dot(geoNormal, lightVec);
            float geoNdotLM = geoNdotL > 0.0 ? geoNdotL * 10.0 : geoNdotL;
            NdotL = min(geoNdotLM, NdotL);

            NdotL *= 1.0 - 0.7 * (1.0 - pow2(pow2(NdotUmax0))) * NPdotU;
        #endif
        #if SHADOW_QUALITY == -1 && defined GBUFFERS_TERRAIN
            if (subsurfaceMode == 1) {
                NdotU = 1.0;
                NdotUmax0 = 1.0;
                NdotL = dot(upVec, lightVec);
            } else if (subsurfaceMode == 2) {
                highlightMult *= NdotL;
                NdotL = mix(NdotL, 1.0, 0.35);
            }

            subsurfaceMode = 0;
        #endif
        float NdotLmax0 = max0(NdotL);
        float NdotLM = NdotLmax0 * 0.9999;

        #ifdef GBUFFERS_TEXTURED
            NdotLM = 1.0;
        #else
            #ifdef GBUFFERS_TERRAIN
                if (subsurfaceMode != 0) {
                    #if defined CUSTOM_PBR && defined POM && POM_QUALITY >= 128 && POM_LIGHTING_MODE == 2
                        shadowMult *= max(pow2(pow2(dot(normalM, geoNormal))), sqrt2(NdotLmax0));
                    #endif
                    NdotLM = 1.0;
                }
                #ifdef SIDE_SHADOWING
                    else
                #endif
            #endif
            #ifdef SIDE_SHADOWING
                NdotLM = max0(NdotL + 0.4) * 0.714;

                #ifdef END
                    NdotLM = sqrt3(NdotLM);
                #endif
            #endif
        #endif

        #if ENTITY_SHADOW == -1 && defined GBUFFERS_ENTITIES || ENTITY_SHADOW <= 1 && defined GBUFFERS_BLOCK
            lightColorM = mix(lightColorM * 0.75, ambientColorM, 0.5 * pow2(pow2(1.0 - NdotLM)));
            NdotLM = NdotLM * 0.75 + 0.25;
        #endif

        if (shadowMult.r > 0.00001) {
            #if SHADOW_QUALITY > -1
                if (NdotLM > 0.0001) {
                    vec3 shadowMultBeforeLighting = shadowMult;

                    #if !defined DH_TERRAIN && !defined DH_WATER
                        float shadowLength = shadowDistance * 0.9166667 - lViewPos; //consistent08JJ622
                    #else
                        float shadowLength = 0.0;
                    #endif

                    if (shadowLength > 0.000001) {
                        #if SHADOW_SMOOTHING == 4 || SHADOW_QUALITY == 0
                            float offset = 0.00098;
                        #elif SHADOW_SMOOTHING == 3
                            float offset = 0.00075;
                        #elif SHADOW_SMOOTHING == 2
                            float offset = 0.0005;
                        #elif SHADOW_SMOOTHING == 1
                            float offset = 0.0003;
                        #endif

                        vec3 playerPosM = playerPos;
                        vec3 centerPlayerPos = floor(playerPos + cameraPosition + worldGeoNormal * 0.01) - cameraPosition + 0.5;

                        #if defined DO_PIXELATION_EFFECTS && defined PIXELATED_SHADOWS
                            playerPosM = playerPosPixelated;
                            offset *= 0.75;
                        #endif

                        // Fix light leaking in caves //
                        #ifdef GBUFFERS_TERRAIN
                            if (centerShadowBias || subsurfaceMode == 1) {
                                #ifdef OVERWORLD
                                    playerPosM = mix(centerPlayerPos, playerPosM, 0.5 + 0.5 * lightmapYM);
                                #endif
                            } else {
                                float centerFactor = max(glColor.a, lightmapYM);

                                #if defined PERPENDICULAR_TWEAKS && SHADOW_QUALITY >= 2 && !defined DH_TERRAIN
                                    // Fake Variable Penumbra Shadows
                                    // Making centerFactor also work in daylight if AO gradient is facing towards sun
                                    if (geoNdotU > 0.99) {
                                        vec3 aoGradView = dFdx(glColor.a) * normalize(dFdx(playerPos.xyz))
                                                        + dFdy(glColor.a) * normalize(dFdy(playerPos.xyz));
                                        if (dot(normalize(aoGradView.xz), normalize(ViewToPlayer(lightVec).xz)) < 0.3 + 0.4 * dither)
                                            if (dot(lightVec, upVec) < 0.99999) centerFactor = sqrt1(max0(glColor.a - 0.55) / 0.45);
                                    }
                                #endif

                                playerPosM = mix(playerPosM, centerPlayerPos, 0.2 * (1.0 - pow2(pow2(centerFactor))));
                            }
                        #elif defined GBUFFERS_HAND
                            playerPosM = mix(vec3(0.0), playerPosM, 0.2 + 0.8 * lightmapYM);
                        #elif defined GBUFFERS_TEXTURED
                            playerPosM = mix(centerPlayerPos, playerPosM + vec3(0.0, 0.02, 0.0), lightmapYM);
                        #else
                            playerPosM = mix(playerPosM, centerPlayerPos, 0.2 * (1.0 - lightmapYM));
                        #endif

                        // Shadow bias without peter-panning //
                        #ifndef GBUFFERS_TEXTURED
                            #ifdef GBUFFERS_TERRAIN
                                if (subsurfaceMode != 1)
                            #endif
                            {
                                float distanceBias = pow(dot(playerPos, playerPos), 0.75);
                                distanceBias = 0.12 + 0.0008 * distanceBias;
                                vec3 bias = worldGeoNormal * distanceBias * (2.0 - 0.95 * NdotLmax0); // 0.95 fixes pink petals noon shadows

                                #if defined GBUFFERS_TERRAIN && !defined DH_TERRAIN
                                    if (subsurfaceMode == 2) {
                                        bias *= vec3(0.0, 0.0, -0.5);
                                        bias.z += distanceBias * signMidCoordPos.x * NdotE;
                                    }
                                #endif

                                playerPosM += bias;
                            }
                        #endif

                        vec3 shadowPos = GetShadowPos(playerPosM);

                        bool leaves = false;
                        #ifdef GBUFFERS_TERRAIN
                            if (subsurfaceMode == 0) {
                                #if defined PERPENDICULAR_TWEAKS && defined SIDE_SHADOWING
                                    offset *= 1.0 + pow2(absNdotN);
                                #endif
                            } else {
                                float VdotL = dot(nViewPos, lightVec);
                                float lightFactor = pow(max(VdotL, 0.0), 10.0) * float(isEyeInWater == 0);
                                if (subsurfaceMode == 1) {
                                    offset = 0.0005235 * lightmapYM + 0.0009765;
                                    shadowPos.z -= max(NdotL * 0.0001, 0.0) * lightmapYM;
                                    subsurfaceHighlight = lightFactor * 0.8;
                                    #ifndef SHADOW_FILTERING
                                        shadowPos.z -= 0.0002;
                                    #endif
                                } else if (subsurfaceMode == 2) {
                                    leaves = true;
                                    offset = 0.0005235 * lightmapYM + 0.0009765;
                                    shadowPos.z -= 0.000175 * lightmapYM;
                                    subsurfaceHighlight = lightFactor * 0.6;
                                    #ifndef SHADOW_FILTERING
                                        NdotLM = mix(NdotL, NdotLM, 0.5);
                                    #endif
                                } else {
                                    
                                }
                            }
                        #endif
                        
                        int shadowSampleBooster = int(subsurfaceMode > 0 && lViewPos < 10.0);
                        #if SHADOW_QUALITY == 0
                            int shadowSamples = 0; // We don't use SampleTAAFilteredShadow on Shadow Quality 0
                        #elif SHADOW_QUALITY == 1
                            int shadowSamples = 1 + shadowSampleBooster;
                        #elif SHADOW_QUALITY == 2 || SHADOW_QUALITY == 3
                            int shadowSamples = 2 + 2 * shadowSampleBooster;
                        #elif SHADOW_QUALITY == 4
                            int shadowSamples = 4 + 4 * shadowSampleBooster;
                        #elif SHADOW_QUALITY == 5
                            int shadowSamples = 8 + 8 * shadowSampleBooster;
                        #endif

                        shadowMult *= GetShadow(shadowPos, lightmap.y, offset, shadowSamples, leaves);
                    }

                    float shadowSmooth = 16.0;
                    if (shadowLength < shadowSmooth) {
                        float shadowMixer = max0(shadowLength / shadowSmooth);

                        #ifdef GBUFFERS_TERRAIN
                            if (subsurfaceMode != 0) {
                                float shadowMixerM = pow2(shadowMixer);

                                if (subsurfaceMode == 1) skyLightShadowMult *= mix(0.6 + 0.3 * pow2(noonFactor), 1.0, shadowMixerM);
                                else skyLightShadowMult *= mix(NdotL * 0.4999 + 0.5, 1.0, shadowMixerM);

                                subsurfaceHighlight *= shadowMixer;
                            }
                        #endif

                        shadowMult = mix(vec3(skyLightShadowMult * shadowMultBeforeLighting), shadowMult, shadowMixer);
                    }
                }
            #else
                shadowMult *= skyLightShadowMult;
            #endif

            #ifdef CLOUD_SHADOWS
                shadowMult *= GetCloudShadow(playerPos);
            #endif

            shadowMult *= max(NdotLM * shadowTime, 0.0);
        }
        #ifdef GBUFFERS_WATER
            else { // Low Quality Water
                shadowMult = vec3(pow2(lightmapY2) * max(NdotLM * shadowTime, 0.0));
            }
        #endif
    #endif

    #define UPPER_LIGHTMAP_CURVE 1.55 //[0.0 0.05 0.10 1.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.0 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.0]
    #define LOWER_LIGHTMAP_CURVE 0.55 //[0.0 0.05 0.10 1.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.0 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.0]

    // Blocklight
    float lightmapXM;
    #ifndef GBUFFERS_TEXTURED
        if (!noSmoothLighting || subsurfaceMode > 0 && !isLightSource) {
            float lx4 = pow2(pow2(lightmap.x));
            float lx8 = pow2(lx4);
            float vsBrightFactor = 3.8 - 0.6 * vsBrightness;
            
            float transitionFactor = ((UPPER_LIGHTMAP_CURVE * 0.1 + 0.9) - 1.0) * 
                                    mix(1.0, 10.0, float(int(max(0.0, UPPER_LIGHTMAP_CURVE - 0.01))));
                                    
            float transitions = (pow2(lx8) * (10 - vsBrightness) * 2 +
                            lx8 * (3.8 - vsBrightness) * 0.8 +
                            lx4 * (3.8 - vsBrightness * 0.7)) * transitionFactor;
            
            float lightmapXMSteep = max(0.0, pow2(pow2(lightmap.x * lightmap.x)) * vsBrightFactor + transitions);
            float lightmapXMCalm = lightmap.x * (1.8 + 0.6 * vsBrightness) * LOWER_LIGHTMAP_CURVE;
            lightmapXM = pow(lightmapXMSteep + lightmapXMCalm, 2.25);
        } else lightmapXM = pow2(lightmap.x) * 10.0 * pow(lightmap.x, pow2(UPPER_LIGHTMAP_CURVE)) * UPPER_LIGHTMAP_CURVE * (UPPER_LIGHTMAP_CURVE * 0.7 + 0.3);
    #else
        if (!noSmoothLighting) {
            float lightmapXMSteep = pow2(pow2(lightmap.x * lightmap.x)) * (3.8 - 0.6 * vsBrightness);
            float lightmapXMCalm = lightmap.x * (1.8 + 0.6 * vsBrightness);
            lightmapXM = pow(lightmapXMSteep + lightmapXMCalm, 2.25);
        } else lightmapXM = pow2(lightmap.x) * lightmap.x * 10.0;
    #endif

    float daylightFactor = lightmapYM * invRainFactor * sunVisibility;
    emission *= 1.0 - 0.25 * daylightFactor; // Less emission under direct skylight

    #ifdef GBUFFERS_TEXTURED
        lightmapXM *= 1.5 - 0.5 * daylightFactor; // Brighter lit particles
    #endif

    #if BLOCKLIGHT_FLICKERING > 0
        vec2 flickerNoise = texture2DLod(noisetex, vec2(frameTimeCounter * 0.06), 0.0).rb;
        lightmapXM *= mix(1.0, min1(max(flickerNoise.r, flickerNoise.g) * 1.7), pow2(BLOCKLIGHT_FLICKERING * 0.1 + 0.05));
    #endif

    vec3 blockLighting = lightmapXM * blocklightCol;

    #if COLORED_LIGHTING_INTERNAL > 0
        // Prepare
        #if defined GBUFFERS_HAND
            vec3 voxelPos = SceneToVoxel(vec3(0.0));
        #elif defined GBUFFERS_TEXTURED
            vec3 voxelPos = SceneToVoxel(playerPos);
        #else
            vec3 voxelPos = SceneToVoxel(playerPos);
            voxelPos = voxelPos + worldGeoNormal * 0.55; // should be close to 0.5 for ACT_CORNER_LEAK_FIX but 0.5 makes slabs flicker
        #endif

        vec3 specialLighting = vec3(0.0);
        vec4 lightVolume = vec4(0.0);
        if (CheckInsideVoxelVolume(voxelPos)) {
            vec3 voxelPosM = clamp01(voxelPos / vec3(voxelVolumeSize));
            lightVolume = GetLightVolume(voxelPosM);
            lightVolume = sqrt(lightVolume);
            specialLighting = lightVolume.rgb;
        }

        // Add extra articial light for blocks that request it
        lightmapXM = max(lightmapXM, mix(lightmapXM, 10.0, lightVolume.a));
        specialLighting *= 1.0 + 50.0 * lightVolume.a;

        purkinjeOverwrite += 17.0 * lightVolume.a;

        // Color Balance
        specialLighting = lightmapXM * 0.13 * DoLuminanceCorrection(specialLighting + blocklightCol * 0.05);

        // Add some extra non-contrasty detail
        AddSpecialLightDetail(specialLighting, color.rgb, emission);

        #if COLORED_LIGHT_SATURATION != 100
            specialLighting = mix(blockLighting, specialLighting, COLORED_LIGHT_SATURATION * 0.01);
        #endif

        // Serve with distance fade
        vec3 absPlayerPosM = abs(playerPos);
        #if COLORED_LIGHTING_INTERNAL <= 512
            absPlayerPosM.y *= 2.0;
        #elif COLORED_LIGHTING_INTERNAL == 768
            absPlayerPosM.y *= 3.0;
        #elif COLORED_LIGHTING_INTERNAL == 1024
            absPlayerPosM.y *= 4.0;
        #endif
        float maxPlayerPos = max(absPlayerPosM.x, max(absPlayerPosM.y, absPlayerPosM.z));
        float blocklightDecider = pow2(min1(maxPlayerPos / effectiveACTdistance * 2.0));
        //if (heldItemId != 40000 || heldItemId2 == 40000) // Hold spider eye to see vanilla lighting
        blockLighting = mix(specialLighting, blockLighting, blocklightDecider);
        //if (heldItemId2 == 40000 && heldItemId != 40000) blockLighting = lightVolume.rgb; // Hold spider eye to see light volume
    #endif

    #if HELD_LIGHTING_MODE >= 1
        float heldLight = heldBlockLightValue; float heldLight2 = heldBlockLightValue2;

        #ifndef IS_IRIS
            if (heldLight > 15.1) heldLight = 0.0;
            if (heldLight2 > 15.1) heldLight2 = 0.0;
        #endif

        #if COLORED_LIGHTING_INTERNAL == 0
            vec3 heldLightCol = blocklightCol; vec3 heldLightCol2 = blocklightCol;

            if (heldItemId == 45032) heldLight = 15; if (heldItemId2 == 45032) heldLight2 = 15; // Lava Bucket
        #else
            vec3 heldLightCol = GetSpecialBlocklightColor(heldItemId - 44000).rgb;
            vec3 heldLightCol2 = GetSpecialBlocklightColor(heldItemId2 - 44000).rgb;

            if (heldItemId == 45032) { heldLightCol = lavaSpecialLightColor; heldLight = 15; } // Lava Bucket
            if (heldItemId2 == 45032) { heldLightCol2 = lavaSpecialLightColor; heldLight2 = 15; }

            #if COLORED_LIGHT_SATURATION != 100
                heldLightCol = mix(blocklightCol, heldLightCol, COLORED_LIGHT_SATURATION * 0.01);
                heldLightCol2 = mix(blocklightCol, heldLightCol2, COLORED_LIGHT_SATURATION * 0.01);
            #endif
        #endif

        vec3 playerPosLightM = playerPos + relativeEyePosition;
        #if defined DO_PIXELATION_EFFECTS && defined PIXELATED_BLOCKLIGHT
            playerPosLightM = playerPosPixelated + relativeEyePosition;
        #endif
        playerPosLightM.y += 0.7;
        float lViewPosL = pow(length(playerPosLightM), 1.45) + 6.0;
        #if HELD_LIGHTING_MODE == 1
            lViewPosL *= 1.5;
        #endif

        #ifdef SPACEAGLE17
            if (heldLight == 0 && heldLight2 == 0 && !firstPersonCamera && entityId != 50017 && !isSpectator && currentPlayerArmor < 0.4 && isOnGround) {
                float powVal = 1.0 + 1.0 * (cos(frameTimeCounter * 1.5) * 0.5 + 0.5);
                float anim = 2.8 * max(pow(0.8, powVal), 0.12);
                heldLight = anim;
                heldLight2 = anim;
                heldLightCol = vec3(0.2392, 0.8235, 0.8667);
                heldLightCol2 = vec3(0.2392, 0.8235, 0.8667);
                playerPosLightM.y += 0.8;
                lViewPosL = length(playerPosLightM) + 6.0;
                lViewPosL = sqrt2(lViewPosL * 0.35) * 1.2;
            }
        #endif

        lViewPosL *= 0.8;

        heldLight = pow2(pow2(heldLight * 0.47 / lViewPosL));
        heldLight2 = pow2(pow2(heldLight2 * 0.47 / lViewPosL));

        vec3 heldLighting = pow2(heldLight * DoLuminanceCorrection(heldLightCol + 0.001))
                          + pow2(heldLight2 * DoLuminanceCorrection(heldLightCol2 + 0.001));

        #if COLORED_LIGHTING_INTERNAL > 0
            AddSpecialLightDetail(heldLighting, color.rgb, emission);
        #endif

        #ifdef GBUFFERS_HAND
            blockLighting *= 0.5;
            heldLighting *= 2.0;
        #endif

        #if HAND_BLOCKLIGHT_FLICKERING > 0
            vec2 flickerNoiseHand = texture2DLod(noisetex, vec2(frameTimeCounter * 0.06), 0.0).rb;
            float flickerMix = mix(1.0, min1(max(flickerNoiseHand.r, flickerNoiseHand.g) * 1.7), pow2(HAND_BLOCKLIGHT_FLICKERING * 0.1));

            heldLighting *= flickerMix;
            #ifdef GBUFFERS_HAND
                emission *= mix(1.0, flickerMix, heldLight + heldLight2);
            #endif
        #endif

        heldLighting *= nearPlayerOutage;
    #endif

    // Minimum Light
    float fadeMinLightDistance = 1.0;
    #if DISTANCE_MIN_LIGHT > 0 
    float blockMinLightFadeDistance = 120;
        float distMinLightIntensity = DISTANCE_MIN_LIGHT * 0.1;
        fadeMinLightDistance = max(1.0 - length(playerPos) / blockMinLightFadeDistance, 0.0);
        fadeMinLightDistance = exp((1.0 - fadeMinLightDistance) * -15.0 * distMinLightIntensity) * (1.0 - nightVision) + nightVision;
    #endif
    
    #if !defined END && CAVE_LIGHTING > 0
        vec3 minLighting = vec3(0.005625 + vsBrightness * 0.043) * fadeMinLightDistance;
        #if CAVE_LIGHTING != 100
            #define CAVE_LIGHTING_M CAVE_LIGHTING * 0.01
            minLighting *= CAVE_LIGHTING_M;
        #endif
        minLighting *= vec3(0.45, 0.475, 0.6);
        minLighting *= 1.0 - lightmapYM;
    #else
        vec3 minLighting = vec3(0.0);
    #endif

    minLighting += nightVision * vec3(0.5, 0.5, 0.75);

    // Lighting Tweaks
    #ifdef OVERWORLD
        ambientMult = mix(lightmapYM, pow2(lightmapYM) * lightmapYM, rainFactor);

        #if SHADOW_QUALITY == -1
            float tweakFactor = 1.0 + 0.6 * (1.0 - pow2(pow2(pow2(noonFactor))));
            lightColorM /= tweakFactor;
            ambientMult *= mix(tweakFactor, 1.0, 0.5 * NdotUmax0);
        #endif

        #if AMBIENT_MULT != 100
            #define AMBIENT_MULT_M (AMBIENT_MULT - 100) * 0.006
            vec3 shadowMultP = shadowMult / (0.1 + 0.9 * sqrt2(max0(NdotLM)));
            ambientMult *= 1.0 + pow2(pow2(max0(1.0 - dot(shadowMultP, shadowMultP)))) * AMBIENT_MULT_M *
                           (0.5 + 0.2 * sunFactor + 0.8 * noonFactor) * (1.0 - rainFactor * 0.5);
        #endif

        if (isEyeInWater != 1) {
            float lxFactor = (sunVisibility2 * 0.4 + (0.6 - 0.6 * pow2(invNoonFactor))) * (6.0 - 5.0 * rainFactor);
            lxFactor *= lightmapY2 + lightmapY2 * 2.0 * pow2(shadowMult.r);
            lxFactor = max0(lxFactor - emission * 1000000.0);
            blockLighting *= pow(lightmapXM / 60.0 + 0.001, 0.09 * lxFactor);

            // Less light in the distance / more light closer to the camera during rain or night to simulate thicker fog
            float rainLF = 0.1 * rainFactor;
            float lightFogTweaks = 1.0 + max0(96.0 - lViewPos) * (0.002 * (1.0 - sunVisibility2) + 0.0104 * rainLF) - rainLF;
            ambientMult *= lightFogTweaks;
            lightColorM *= lightFogTweaks;
        }
    #endif
    #ifdef END
        #if defined IS_IRIS && MC_VERSION >= 12109
            vec3 worldEndFlashPosition = mat3(gbufferModelViewInverse) * endFlashPosition;
            worldEndFlashPosition = normalize(vec3(worldEndFlashPosition.x, 0.0, worldEndFlashPosition.z));
            float endFlashDirectionFactor = max0(1.0 + dot(worldGeoNormal, normalize(worldEndFlashPosition))) * 0.5;
                  endFlashDirectionFactor = pow2(pow2(endFlashDirectionFactor));

            vec3 endFlashColor = (endOrangeCol + 0.5 * endLightColor) * endFlashIntensity * pow2(lightmapYM);
            ambientColorM += endFlashColor * (0.2 * endFlashDirectionFactor);
        #endif
    #endif

    #ifdef GBUFFERS_HAND
        ambientMult *= 1.3; // To improve held map visibility
        emission *= 0.75;
    #endif

    // Directional Shading
    float directionShade = 1.0;
    #ifdef DIRECTIONAL_SHADING
        if (!noDirectionalShading) {
            float absNdotE2 = pow2(absNdotE);

            #if !defined NETHER
                float NdotUM = 0.75 + NdotU * 0.25;
            #else
                float NdotUM = 0.75 + abs(NdotU + 0.5) * 0.16666;
            #endif
            float NdotNM = 1.0 + 0.075 * absNdotN;
            float NdotEM = 1.0 - 0.1 * absNdotE2;
            directionShade = NdotUM * NdotEM * NdotNM;

            #ifdef OVERWORLD
                lightColorM *= 1.0 + absNdotE2 * 0.75;
            #elif defined NETHER
                directionShade *= directionShade;
                ambientColorM += lavaLightColor * pow2(absNdotN * 0.5 + max0(-NdotU)) * (0.7 + 0.35 * vsBrightness);
            #endif

            #if defined CUSTOM_PBR || defined GENERATED_NORMALS
                float cpbrAmbFactor = NdotN * NPdotU;
                cpbrAmbFactor = 1.0 - 0.3 * cpbrAmbFactor;
                ambientColorM *= cpbrAmbFactor;
                minLighting *= cpbrAmbFactor;
            #endif

            #if defined OVERWORLD && defined PERPENDICULAR_TWEAKS && defined SIDE_SHADOWING
                // Fake bounced light
                ambientColorM = mix(ambientColorM, lightColorM, (0.05 + 0.03 * subsurfaceMode) * absNdotN * lightmapY2);

                // Get a bit more natural looking lighting during noon
                lightColorM *= 1.0 + max0(1.0 - subsurfaceMode) * pow(noonFactor, 20.0) * (pow2(absNdotN) * 0.8 - absNdotE2 * 0.2);
            #endif
        }
    #endif

    // Scene Lighting Stuff
    vec3 sceneLighting = lightColorM * shadowMult + ambientColorM * ambientMult;
    float dotSceneLighting = dot(sceneLighting, sceneLighting);

    #if HELD_LIGHTING_MODE >= 1
        blockLighting = sqrt(pow2(blockLighting) + heldLighting);
    #endif

    blockLighting *= XLIGHT_I;

    #ifdef LIGHT_COLOR_MULTS
        sceneLighting *= lightColorMult;
    #endif
    #ifdef MOON_PHASE_INF_LIGHT
        sceneLighting *= moonPhaseInfluence;
    #endif

    // Vanilla Ambient Occlusion
    float vanillaAO = 1.0;
    #if VANILLAAO_I > 0
        vanillaAO = glColor.a;

        #if defined DO_PIXELATION_EFFECTS && defined PIXELATED_AO
            vanillaAO = TexelSnap(vanillaAO, pixelationOffset);
        #endif

        if (subsurfaceMode != 0) vanillaAO = mix(min1(vanillaAO * 1.15), 1.0, shadowMult.g);
        else if (!noVanillaAO) {
            #ifdef GBUFFERS_TERRAIN
                vanillaAO = min1(vanillaAO + 0.08);
                #ifdef OVERWORLD
                    vanillaAO = pow(
                        pow1_5(vanillaAO),
                        1.0 + dotSceneLighting * 0.02 + NdotUmax0 * (0.15 + 0.25 * pow2(noonFactor * pow2(lightmapY2)))
                    );
                #elif defined NETHER
                    vanillaAO = pow(
                        pow1_5(vanillaAO),
                        1.0 + NdotUmax0 * 0.5
                    );
                #else
                    vanillaAO = pow(
                        vanillaAO,
                        0.75 + NdotUmax0 * 0.25
                    );
                #endif
            #endif
            vanillaAO = vanillaAO * 0.9 + 0.1;

            #if VANILLAAO_I != 100
                #define VANILLAAO_IM VANILLAAO_I * 0.01
                vanillaAO = pow(vanillaAO, VANILLAAO_IM);
            #endif
        }
    #endif

    // Light Highlight
    vec3 lightHighlight = vec3(0.0);
    #ifdef LIGHT_HIGHLIGHT
        float specularHighlight = GGX(normalM, nViewPos, lightVec, NdotLmax0, smoothnessG);

        specularHighlight *= highlightMult;

        lightHighlight = isEyeInWater != 1 ? shadowMult : pow(shadowMult, vec3(0.25)) * 0.35;
        lightHighlight *= (subsurfaceHighlight * subsurfaceColor + specularHighlight) * highlightColor;

        #ifdef LIGHT_COLOR_MULTS
            lightHighlight *= lightColorMult;
        #endif
        #ifdef MOON_PHASE_INF_REFLECTION
            lightHighlight *= pow2(moonPhaseInfluence);
        #endif
    #endif

    // Mix Colors
    vec3 finalDiffuse = pow2(directionShade * vanillaAO) * (blockLighting + pow2(sceneLighting) + minLighting) + pow2(emission);
    finalDiffuse = sqrt(max(finalDiffuse, vec3(0.0))); // sqrt() for a bit more realistic light mix, max() to prevent NaNs

    // Apply Lighting
    color.rgb *= finalDiffuse;
    color.rgb += lightHighlight;
    color.rgb *= pow2(1.0 - darknessLightFactor);
}