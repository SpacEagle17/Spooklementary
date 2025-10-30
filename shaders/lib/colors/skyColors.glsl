#ifndef INCLUDE_SKY_COLORS
    #define INCLUDE_SKY_COLORS

    #ifdef OVERWORLD
        vec3 skyColorSqrt = sqrt(skyColor);
        // Doing these things because vanilla skyColor gets to 0 during a thunderstorm
        float invRainStrength2 = (1.0 - rainStrength) * (1.0 - rainStrength);
        vec3 skyColorM = mix(max(skyColorSqrt, vec3(0.63, 0.67, 0.73)), skyColorSqrt, invRainStrength2) * overallColorTone;
        vec3 skyColorM2 = mix(max(skyColor, sunFactor * vec3(0.265, 0.295, 0.35)), skyColor, invRainStrength2);

        #ifdef SPECIAL_BIOME_WEATHER
            vec3 nmscSnowM = inSnowy * vec3(-0.1, 0.3, 0.6);
            vec3 nmscDryM = inDry * vec3(-0.1, -0.2, -0.3);
            vec3 ndscSnowM = inSnowy * vec3(-0.25, -0.01, 0.25);
            vec3 ndscDryM = inDry * vec3(-0.05, -0.09, -0.1);
        #else
            vec3 nmscSnowM = vec3(0.0), nmscDryM = vec3(0.0), ndscSnowM = vec3(0.0), ndscDryM = vec3(0.0);
        #endif
        #if RAIN_STYLE == 2
            vec3 nmscRainMP = vec3(-0.15, 0.025, 0.1);
            vec3 ndscRainMP = vec3(-0.125, -0.005, 0.125);
            #ifdef SPECIAL_BIOME_WEATHER
                vec3 nmscRainM = inRainy * ndscRainMP;
                vec3 ndscRainM = inRainy * ndscRainMP;
            #else
                vec3 nmscRainM = ndscRainMP;
                vec3 ndscRainM = ndscRainMP;
            #endif
        #else
            vec3 nmscRainM = vec3(0.0), ndscRainM = vec3(0.0);
        #endif
        vec3 nuscWeatherM = vec3(0.1, 0.0, 0.1);
        vec3 nmscWeatherM = vec3(-0.1, -0.4, -0.6) + vec3(0.0, 0.06, 0.12) * noonFactor;
        vec3 ndscWeatherM = vec3(-0.15, -0.3, -0.42) + vec3(0.0, 0.02, 0.08) * noonFactor;

        vec3 noonUpSkyColor     = pow(skyColorM, vec3(0.8)) * (vec3(0.7255, 0.7098, 0.6824) + rainFactor * nuscWeatherM);
        vec3 noonMiddleSkyColor = pow(skyColorM, vec3(2.3)) * 1.35 * (vec3(1.35) + rainFactor * (nmscWeatherM + nmscRainM + nmscSnowM + nmscDryM))
                                + noonUpSkyColor * 0.75 - vec3(0.0, 0.1, 0.13);
        vec3 noonDownSkyColor   = skyColorM * (vec3(0.95) + rainFactor * (ndscWeatherM + ndscRainM + ndscSnowM + ndscDryM))
                                + noonUpSkyColor * 0.25;

        vec3 sunsetUpSkyColor     = skyColorM2 * (vec3(0.4471, 0.3333, 0.3059) + vec3(0.1, 0.2, 0.35) * rainFactor2);
        vec3 sunsetMiddleSkyColor = skyColorM2 * (vec3(1.8, 1.3, 1.2) + vec3(0.15, 0.25, -0.05) * rainFactor2);
        vec3 sunsetDownSkyColorP  = vec3(1.2, 0.86, 0.5) - vec3(0.8, 0.3, 0.0) * rainFactor;
        vec3 sunsetDownSkyColor   = sunsetDownSkyColorP * 0.5 + 0.25 * sunsetMiddleSkyColor;

        vec3 dayUpSkyColor     = mix(noonUpSkyColor, sunsetUpSkyColor, invNoonFactor2);
        vec3 dayMiddleSkyColor = mix(noonMiddleSkyColor, sunsetMiddleSkyColor, invNoonFactor2) * 1.2;
        vec3 dayDownSkyColor   = mix(noonDownSkyColor, sunsetDownSkyColor, invNoonFactor2) * 1.4;

        vec3 nightColFactor      = 0.9 * vec3(0.0098, 0.0196, 0.03335) * (1.0 - 0.5 * rainFactor) + skyColor;
        vec3 nightUpSkyColor     = pow(nightColFactor, vec3(0.6118, 0.6118, 0.6118)) * 0.45;
        vec3 nightMiddleSkyColor = sqrt(nightUpSkyColor) * 0.25;
        vec3 nightDownSkyColor   = nightMiddleSkyColor * vec3(0.6588, 0.6588, 0.7059);
    #endif

#endif //INCLUDE_SKY_COLORS