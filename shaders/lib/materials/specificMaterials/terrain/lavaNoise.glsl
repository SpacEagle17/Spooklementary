#ifdef GBUFFERS_TERRAIN
    float columnNoise = 0.0;
    float noise = 0.0;
    vec3 lavaNoiseColor = color.rgb + 0.1;
    float lavaNoiseEmission = emission;
    if (mat == 10068 || columnNoise == 1.0) {
        #ifdef NETHER
            if (worldPos.y > 30 && worldPos.y < 32) {
                noise += texture2D(noisetex, lavaPos * 0.2 + wind * 0.1).r;
                noise += texture2D(noisetex, lavaPos * 0.8 + wind * 0.04).r * 0.5;
                noise *= texture2D(noisetex, lavaPos * 0.1 + wind * 0.02).r * 0.5;
                lavaNoiseEmission *= 1.6;
                lavaNoiseColor *= smoothstep(0.00, 0.50, noise);
                lavaNoiseColor.r *= 1.2;
            }
            else {
                noise += texture2D(noisetex, lavaPos * 0.05 + wind * 0.01).r;
                noise -= texture2D(noisetex, lavaPos * 1.5 + wind * 0.05).r * 0.3;
                noise += texture2D(noisetex, lavaPos * 0.1).r * 0.7;
                lavaNoiseColor *= smoothstep(0.00, 0.70, noise);
                lavaNoiseColor.r *= 1.5;
            }
        #else
            noise += texture2D(noisetex, lavaPos * 0.2 + wind * 0.01).g;
            noise -= texture2D(noisetex, lavaPos * 2.0 + wind * 0.05).g * 0.3;
            noise += texture2D(noisetex, lavaPos * 0.1).g * 0.3;
            lavaNoiseColor *= smoothstep(0.00, 0.70, noise);
            lavaNoiseColor.r *= 1.25;
            lavaNoiseEmission *= 1.1;
        #endif
    }

    color.rgb = mix(color.rgb, lavaNoiseColor, lavaNoiseIntensity);
    emission = mix(emission, lavaNoiseEmission, lavaNoiseIntensity);
#endif