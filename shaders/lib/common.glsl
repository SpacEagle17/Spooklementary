/*---------------------------------------------------------------------
         ___ __  __ ____   ___  ____ _____  _    _   _ _____ 
        |_ _|  \/  |  _ \ / _ \|  _ \_   _|/ \  | \ | |_   _|
         | || |\/| | |_) | | | | |_) || | / _ \ |  \| | | |  
         | || |  | |  __/| |_| |  _ < | |/ ___ \| |\  | | |  
        |___|_|  |_|_|    \___/|_| \_\|_/_/   \_\_| \_| |_|  
         .
  -> -> -> EDITING THIS FILE HAS A HIGH CHANCE TO BREAK THE SHADER PACK
  -> -> -> DO NOT CHANGE ANYTHING UNLESS YOU KNOW WHAT YOU ARE DOING
  -> -> -> DO NOT EXPECT SUPPORT AFTER MODIFYING SHADER FILES
---------------------------------------------------------------------*/
uniform float frameTimeCounter;
uniform vec4 lightningBoltPosition;
uniform float lightningFlashOptifine;
uniform float lightning;
uniform int moonPhase;

//User Settings//
    #define SHADER_STYLE 4 //[1 4]

    #define RP_MODE 1 //[1 0 3 2]
    #if RP_MODE == 1
        #define IPBR
        //#define GENERATED_NORMALS
        //#define COATED_TEXTURES
        //#define FANCY_GLASS
        //#define GREEN_SCREEN_LIME
    #endif
    #if RP_MODE >= 2
        #define CUSTOM_PBR
        #define POM
    #endif

    #define REALTIME_SHADOWS
    #define SHADOW_QUALITY 2 //[0 1 2 3 4 5]
    const float shadowDistance = 192.0; //[64.0 80.0 96.0 112.0 128.0 160.0 192.0 224.0 256.0 320.0 384.0 512.0 768.0 1024.0]
    //#define ENTITY_SHADOWS
    #define SSAO_QUALI_DEFINE 2 //[0 2 3]
    #define FXAA
    #define DETAIL_QUALITY 2 //[0 2 3]
    #define CLOUD_QUALITY 2 //[0 1 2 3]
    #define LIGHTSHAFT_QUALI_DEFINE 2 //[0 1 2 3 4]
    #define WATER_QUALITY 2 //[1 2 3]
    #define WATER_REFLECT_QUALITY 2 //[0 1 2]
    #define BLOCK_REFLECT_QUALITY 3 //[0 1 2 3]

    #define WATER_STYLE_DEFINE -1 //[-1 1 2 3]
    #define WATER_CAUSTIC_STYLE_DEFINE -1 //[-1 1 3]
    #define WATER_REFRACTION_INTENSITY 2.0 //[1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0]
    #define WATER_FOAM_I 100 //[0 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150]
    #define WATER_ALPHA_MULT 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300 325 350 375 400 425 450 475 500 550 600 650 700 750 800 850 900]
    #define WATER_FOG_MULT 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300 325 350 375 400 425 450 475 500 550 600 650 700 750 800 850 900]
    #define WATERCOLOR_MODE 3 //[3 2 0]
    #define BRIGHT_CAVE_WATER
    #define WATERCOLOR_R 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
    #define WATERCOLOR_G 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
    #define WATERCOLOR_B 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
    #define UNDERWATERCOLOR_R 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150]
    #define UNDERWATERCOLOR_G 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150]
    #define UNDERWATERCOLOR_B 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150]
    #define WATER_BUMPINESS 1.25 //[0.05 0.10 0.15 0.20 0.25 0.30 0.40 0.50 0.65 0.80 1.00 1.25 1.50 2.00 2.50]
    #define WATER_BUMP_SMALL 0.75 //[0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00 4.50 5.00]
    #define WATER_BUMP_MED 1.70 //[0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00 4.50 5.00]
    #define WATER_BUMP_BIG 2.00 //[0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00 4.50 5.00]
    #define WATER_SPEED_MULT 1.10 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00 4.50 5.00]
    #define WATER_SIZE_MULT 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]

    #define PIXEL_SHADOW 0 //[0 8 16 32 64 128]
    #define RAIN_PUDDLES 1 //[0 1 2 3 4]
    #define SSAO_I 100 //[0 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
    #define VANILLAAO_I 100 //[0 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
    
    #define AURORA_STYLE_DEFINE -1 //[-1 0 1 2]
    #define AURORA_CONDITION 3 //[0 1 2 3 4]
    //#define NIGHT_NEBULA
    #define NIGHT_NEBULA_I 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
    #define WEATHER_TEX_OPACITY 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300 325 350 375 400 425 450 475 500 550 600 650 700 750 800 850 900]
    #define SUN_MOON_STYLE_DEFINE -1 //[-1 1 2 3]
    #define SUN_MOON_HORIZON
    #define NIGHT_STAR_AMOUNT 2 //[2 3]
    #define CLOUD_STYLE_DEFINE -1 //[-1 0 1 3 50]
    //#define CLOUD_SHADOWS
    #define CLOUD_CLOSED_AREA_CHECK
    #define CLOUD_ALT1 192 //[-96 -92 -88 -84 -80 -76 -72 -68 -64 -60 -56 -52 -48 -44 -40 -36 -32 -28 -24 -20 -16 -10 -8 -4 0 4 8 12 16 20 22 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 256 260 264 268 272 276 280 284 288 292 296 300 304 308 312 316 320 324 328 332 336 340 344 348 352 356 360 364 368 372 376 380 384 388 392 396 400 404 408 412 416 420 424 428 432 436 440 444 448 452 456 460 464 468 472 476 480 484 488 492 496 500 510 520 530 540 550 560 570 580 590 600 610 620 630 640 650 660 670 680 690 700 710 720 730 740 750 760 770 780 790 800]
    #define CLOUD_SPEED_MULT 100 //[0 5 7 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300 325 350 375 400 425 450 475 500 550 600 650 700 750 800 850 900]

    #define CLOUD_UNBOUND_AMOUNT 1.00 //[0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00 1.02 1.04 1.06 1.08 1.10 1.12 1.14 1.16 1.18 1.20 1.22 1.24 1.26 1.28 1.30 1.32 1.34 1.36 1.38 1.40 1.42 1.44 1.46 1.48 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00 2.10 2.20 2.30 2.40 2.50 2.60 2.70 2.80 2.90 3.00]
    #define CLOUD_UNBOUND_SIZE_MULT 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]

    //#define DOUBLE_REIM_CLOUDS
    #define CLOUD_ALT2 288 //[-96 -92 -88 -84 -80 -76 -72 -68 -64 -60 -56 -52 -48 -44 -40 -36 -32 -28 -24 -20 -16 -10 -8 -4 0 4 8 12 16 20 22 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 256 260 264 268 272 276 280 284 288 292 296 300 304 308 312 316 320 324 328 332 336 340 344 348 352 356 360 364 368 372 376 380 384 388 392 396 400 404 408 412 416 420 424 428 432 436 440 444 448 452 456 460 464 468 472 476 480 484 488 492 496 500 510 520 530 540 550 560 570 580 590 600 610 620 630 640 650 660 670 680 690 700 710 720 730 740 750 760 770 780 790 800]

    #define NETHER_COLOR_MODE 3 //[3 2 0]
    #define NETHER_STORM
    #define NETHER_STORM_LOWER_ALT 28 //[-296 -292 -288 -284 -280 -276 -272 -268 -264 -260 -256 -252 -248 -244 -240 -236 -232 -228 -224 -220 -216 -212 -208 -204 -200 -196 -192 -188 -184 -180 -176 -172 -168 -164 -160 -156 -152 -148 -144 -140 -136 -132 -128 -124 -120 -116 -112 -108 -104 -100 -96 -92 -88 -84 -80 -76 -72 -68 -64 -60 -56 -52 -48 -44 -40 -36 -32 -28 -24 -20 -16 -12 -8 -4 0 4 8 12 16 20 22 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 256 260 264 268 272 276 280 284 288 292 296 300]
    #define NETHER_STORM_HEIGHT 200 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300 325 350 375 400 425 450 475 500 550 600 650 700 750 800 850 900]
    #define NETHER_STORM_I 0.40 //[0.05 0.06 0.07 0.08 0.09 0.10 0.12 0.14 0.16 0.18 0.22 0.26 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50]

    #define BORDER_FOG
    #define ATM_FOG_MULT 0.95 //[0.50 0.65 0.80 0.95]
    #define ATM_FOG_DISTANCE 100 //[10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
    #define ATM_FOG_ALTITUDE 63 //[0 5 10 15 20 25 30 35 40 45 50 52 54 56 58 60 61 62 63 64 65 66 67 68 69 70 72 74 76 78 80 85 90 95 100 105 110 115 120 125 130 135 140 145 150 155 160 165 170 175 180 185 190 195 200 210 220 230 240 250 260 270 280 290 300]
    #define CAVE_FOG
    #define LIGHTSHAFT_BEHAVIOUR 1 //[0 1 2 3]
    #define LIGHTSHAFT_DAY_I 100 //[1 3 5 7 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200]
    #define LIGHTSHAFT_NIGHT_I 100 //[1 3 5 7 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200]
    #define LIGHTSHAFT_RAIN_I 100 //[1 3 5 7 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200]

    #define BLOOM
    #define BLOOM_STRENGTH 0.12 //[0.027 0.036 0.045 0.054 0.063 0.072 0.081 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.21 0.23 0.25 0.28 0.32 10.00]
    #define IMAGE_SHARPENING 3 //[0 1 2 3 4 5 6 7 8 9 10]
    //#define MOTION_BLURRING
    #define MOTION_BLURRING_STRENGTH 1.00 //[0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
    #define VIGNETTE_R
    #define CHROMA_ABERRATION 0 //[0 1 2 3 4 5 6 7 8]
    #define UNDERWATER_DISTORTION
    //#define LENSFLARE
    #define LENSFLARE_I 1.00 //[0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00 4.50 5.00]

    #define WORLD_BLUR 0 //[0 1 2]
    //#define WB_FOV_SCALED
    //#define WB_CHROMATIC
    //#define WB_ANAMORPHIC
    #define WB_DOF_I 64.0 //[1.0 1.5 2.0 3.0 4.5 6.0 9.0 12.0 18.0 24.0 32.0 48.0 64.0 96.0 128.0 192.0 256.0 384.0 512.0 768.0 1024.0 1536.0 2048.0 3072.0 4096.0]
    #define WB_DOF_FOCUS 0 //[-1 0 1 2 3 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 65 67 69 72 74 76 79 81 83 86 88 91 94 96 99 102 104 107 110 113 115 118 121 124 127 130 133 136 140 143 146 149 153 156 160 163 167 170 174 178 182 185 189 193 197 201 206 210 214 219 223 227 232 237 242 246 251 256 261 267 272 277 283 288 294 300 306 312 318 324 330 337 344 350 357 364 371 379 386 394 402 410 418 427 435 444 453 462 472 481 491 501 512 530 550 575 600 625 650 675 700 725 750 800 850 900]
    #define WB_DB_DAY_I 64.0 //[1.0 1.5 2.0 3.0 4.5 6.0 9.0 12.0 18.0 24.0 32.0 48.0 64.0 96.0 128.0 192.0 256.0 384.0 512.0 768.0 1024.0 1536.0 2048.0 3072.0 4096.0]
    #define WB_DB_NIGHT_I 64.0 //[1.0 1.5 2.0 3.0 4.5 6.0 9.0 12.0 18.0 24.0 32.0 48.0 64.0 96.0 128.0 192.0 256.0 384.0 512.0 768.0 1024.0 1536.0 2048.0 3072.0 4096.0]
    #define WB_DB_RAIN_I 64.0 //[1.0 1.5 2.0 3.0 4.5 6.0 9.0 12.0 18.0 24.0 32.0 48.0 64.0 96.0 128.0 192.0 256.0 384.0 512.0 768.0 1024.0 1536.0 2048.0 3072.0 4096.0]
    #define WB_DB_WATER_I 64.0 //[1.0 1.5 2.0 3.0 4.5 6.0 9.0 12.0 18.0 24.0 32.0 48.0 64.0 96.0 128.0 192.0 256.0 384.0 512.0 768.0 1024.0 1536.0 2048.0 3072.0 4096.0]
    #define WB_DB_NETHER_I 64.0 //[1.0 1.5 2.0 3.0 4.5 6.0 9.0 12.0 18.0 24.0 32.0 48.0 64.0 96.0 128.0 192.0 256.0 384.0 512.0 768.0 1024.0 1536.0 2048.0 3072.0 4096.0]
    #define WB_DB_END_I 64.0 //[1.0 1.5 2.0 3.0 4.5 6.0 9.0 12.0 18.0 24.0 32.0 48.0 64.0 96.0 128.0 192.0 256.0 384.0 512.0 768.0 1024.0 1536.0 2048.0 3072.0 4096.0]

    #define ENTITY_GN_AND_CT
    #define GENERATED_NORMAL_MULT 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200]
    #define COATED_TEXTURE_MULT 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200]

    #define GLOWING_ORE_MASTER 0 //[0 1 2]
    #define GLOWING_ORE_MULT 1.00 //[0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #if GLOWING_ORE_MASTER == 2 || SHADER_STYLE == 4 && GLOWING_ORE_MASTER == 1
        #define GLOWING_ORE_IRON
        #define GLOWING_ORE_GOLD
        #define GLOWING_ORE_COPPER
        #define GLOWING_ORE_REDSTONE
        #define GLOWING_ORE_LAPIS
        #define GLOWING_ORE_EMERALD
        #define GLOWING_ORE_DIAMOND
        #define GLOWING_ORE_NETHERQUARTZ
        #define GLOWING_ORE_NETHERGOLD
        #define GLOWING_ORE_GILDEDBLACKSTONE
        #define GLOWING_ORE_ANCIENTDEBRIS
        #define GLOWING_ORE_MODDED
    #endif

    #define GLOWING_AMETHYST 1 //[0 1 2]
    #define GLOWING_LICHEN 1 //[0 1 2]
    //#define EMISSIVE_REDSTONE_BLOCK
    //#define EMISSIVE_LAPIS_BLOCK
    //#define GLOWING_ARMOR_TRIM

    #define NORMAL_MAP_STRENGTH 100 //[0 10 15 20 30 40 60 80 100 120 140 160 180 200]
    #define CUSTOM_EMISSION_INTENSITY 100 //[0 5 7 10 15 20 25 30 35 40 45 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 225 250]
    #define POM_DEPTH 0.80 //[0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
    #define POM_QUALITY 128 //[16 32 64 128 256 512]
    #define POM_DISTANCE 32 //[16 24 32 48 64 128 256 512 1024]
    #define POM_LIGHTING_MODE 2 //[1 2]
    //#define POM_ALLOW_CUTOUT
    #define DIRECTIONAL_BLOCKLIGHT 0 //[0 3 7 11]

    #define MINIMUM_LIGHT_MODE 2 //[0 1 2 3 4]
    #define HELD_LIGHTING_MODE 2 //[0 1 2]
    #define AMBIENT_MULT 100 //[50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200]

    #define WAVING_SPEED 1.00 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00 4.50 5.00]
    #define WAVING_I 1.00 //[0.25 0.50 0.75 1.00 1.25 1.50 1.75 2.00 50.0]
    #define NO_WAVING_INDOORS
    #define WAVING_FOLIAGE
    #define WAVING_LEAVES
    #define WAVING_LAVA
    #define WAVING_WATER_VERTEX
    #define WAVING_RAIN

    #define SUN_ANGLE -1 //[-1 0 -20 -30 -40 -50 -60 60 50 40 30 20]

    #define SELECT_OUTLINE 1 //[0 1 3 4 2]
    #define SELECT_OUTLINE_I 1.00 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00 4.50 5.00]
    #define SELECT_OUTLINE_R 1.35 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
    #define SELECT_OUTLINE_G 0.35 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
    #define SELECT_OUTLINE_B 1.75 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]

    //#define WORLD_OUTLINE
    #define WORLD_OUTLINE_THICKNESS 1 //[1 2 3 4]
    #define WORLD_OUTLINE_I 1.50 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00]
    //#define DARK_OUTLINE
    #define DARK_OUTLINE_THICKNESS 1 //[1 2]

    #define HAND_SWAYING 0 //[0 1 2 3]
    #define SHOW_LIGHT_LEVEL 0 //[0 1 2 3]
    //#define REDUCE_CLOSE_PARTICLES
    //#define LESS_LAVA_FOG
    //#define SNOWY_WORLD
    //#define COLOR_CODED_PROGRAMS

    //#define MOON_PHASE_INF_LIGHT
    #define MOON_PHASE_INF_REFLECTION
    #define MOON_PHASE_FULL 1.00 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define MOON_PHASE_PARTIAL 0.85 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define MOON_PHASE_DARK 0.60 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]

    #define T_EXPOSURE 1.40 //[0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00 2.10 2.20 2.30 2.40 2.50 2.60 2.70 2.80]
    #define TM_WHITE_CURVE 2.0 //[1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]
    #define T_LOWER_CURVE 1.20 //[0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
    #define T_UPPER_CURVE 1.30 //[0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
    #define T_SATURATION 1.00 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
    #define T_VIBRANCE 1.00 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
    //#define COLORGRADING
    #define GR_RR 100 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 108 116 124 132 140 148 156 164 172 180 188 196 200 212 224 236 248 260 272 284 296 300 316 332 348 364 380 396 400 424 448 472 496 500]
    #define GR_RG 0 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 108 116 124 132 140 148 156 164 172 180 188 196 200 212 224 236 248 260 272 284 296 300 316 332 348 364 380 396 400 424 448 472 496 500]
    #define GR_RB 0 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 108 116 124 132 140 148 156 164 172 180 188 196 200 212 224 236 248 260 272 284 296 300 316 332 348 364 380 396 400 424 448 472 496 500]
    #define GR_RC 1.00 //[0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00 4.50 5.00]
    #define GR_GR 0 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 108 116 124 132 140 148 156 164 172 180 188 196 200 212 224 236 248 260 272 284 296 300 316 332 348 364 380 396 400 424 448 472 496 500]
    #define GR_GG 100 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 108 116 124 132 140 148 156 164 172 180 188 196 200 212 224 236 248 260 272 284 296 300 316 332 348 364 380 396 400 424 448 472 496 500]
    #define GR_GB 0 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 108 116 124 132 140 148 156 164 172 180 188 196 200 212 224 236 248 260 272 284 296 300 316 332 348 364 380 396 400 424 448 472 496 500]
    #define GR_GC 1.00 //[0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00 4.50 5.00]
    #define GR_BR 0 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 108 116 124 132 140 148 156 164 172 180 188 196 200 212 224 236 248 260 272 284 296 300 316 332 348 364 380 396 400 424 448 472 496 500]
    #define GR_BG 0 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 108 116 124 132 140 148 156 164 172 180 188 196 200 212 224 236 248 260 272 284 296 300 316 332 348 364 380 396 400 424 448 472 496 500]
    #define GR_BB 100 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 108 116 124 132 140 148 156 164 172 180 188 196 200 212 224 236 248 260 272 284 296 300 316 332 348 364 380 396 400 424 448 472 496 500]
    #define GR_BC 1.00 //[0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00 4.50 5.00]

    //#define LIGHT_COLOR_MULTS
    //#define ATM_COLOR_MULTS
    #define LIGHT_MORNING_R 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_MORNING_G 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_MORNING_B 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_MORNING_I 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_MORNING_R 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_MORNING_G 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_MORNING_B 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_MORNING_I 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_NOON_R 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_NOON_G 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_NOON_B 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_NOON_I 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_NOON_R 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_NOON_G 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_NOON_B 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_NOON_I 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_NIGHT_R 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_NIGHT_G 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_NIGHT_B 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_NIGHT_I 1.00 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_NIGHT_R 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_NIGHT_G 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_NIGHT_B 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_NIGHT_I 1.00 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_RAIN_R 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_RAIN_G 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_RAIN_B 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_RAIN_I 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_RAIN_R 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_RAIN_G 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_RAIN_B 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_RAIN_I 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_NETHER_R 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_NETHER_G 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_NETHER_B 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_NETHER_I 1.00 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_NETHER_R 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_NETHER_G 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_NETHER_B 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_NETHER_I 1.00 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_END_R 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_END_G 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_END_B 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define LIGHT_END_I 1.00 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_END_R 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_END_G 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_END_B 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define ATM_END_I 1.00 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]

    #define XLIGHT_R 1.00 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define XLIGHT_G 1.00 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define XLIGHT_B 1.00 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]

    //#define LIGHT_COLORING

//Internal Settings//
    #define SIDE_SHADOWING
    #define SHADOW_FILTERING

    #define GLASS_OPACITY 0.25
    #define FANCY_NETHERPORTAL

    #define DIRECTIONAL_SHADING

    #define ATMOSPHERIC_FOG
    #define BLOOM_FOG

    #define GLOWING_ENTITY_FIX
    #define FLICKERING_FIX
    //#define SAFER_GENERATED_NORMALS

//Extensions//
    #extension GL_ARB_shader_image_load_store : enable

//Information//
    #define info0 0 //[0]
    #define info1 0 //[0]
    #define info2 0 //[0]
    #define info3 0 //[0]
    #define info4 0 //[0]
    #define info5 0 //[0]
    #define info6 0 //[0]
    #define info7 0 //[0]
    #define info8 0 //[0]
    #define info9 0 //[0]
    #define info10 0 //[0]

//Visual Style and Performance Setting Handling//
    #if SHADER_STYLE == 1
        #define WATER_STYLE_DEFAULT 1
        //#define WATER_CAUSTIC_STYLE_DEFAULT 1
        #define AURORA_STYLE_DEFAULT 1
        #define SUN_MOON_STYLE_DEFAULT 1
        #define CLOUD_STYLE_DEFAULT 1
    #elif SHADER_STYLE == 4
        #define WATER_STYLE_DEFAULT 3
        //#define WATER_CAUSTIC_STYLE_DEFAULT 3
        #define AURORA_STYLE_DEFAULT 2
        #define SUN_MOON_STYLE_DEFAULT 3
        #define CLOUD_STYLE_DEFAULT 3
    #endif
    #if WATER_STYLE_DEFINE == -1
        #define WATER_STYLE WATER_STYLE_DEFAULT
    #else
        #define WATER_STYLE WATER_STYLE_DEFINE
    #endif
    #if WATER_CAUSTIC_STYLE_DEFINE == -1
        #define WATER_CAUSTIC_STYLE WATER_STYLE
    #else
        #define WATER_CAUSTIC_STYLE WATER_CAUSTIC_STYLE_DEFINE
    #endif
    #if AURORA_STYLE_DEFINE == -1
        #define AURORA_STYLE AURORA_STYLE_DEFAULT
    #else
        #define AURORA_STYLE AURORA_STYLE_DEFINE
    #endif
    #if SUN_MOON_STYLE_DEFINE == -1
        #define SUN_MOON_STYLE SUN_MOON_STYLE_DEFAULT
    #else
        #define SUN_MOON_STYLE SUN_MOON_STYLE_DEFINE
    #endif
    #if CLOUD_STYLE_DEFINE == -1
        #define CLOUD_STYLE CLOUD_STYLE_DEFAULT
    #else
        #define CLOUD_STYLE CLOUD_STYLE_DEFINE
    #endif
    // Thanks to SpacEagle17 and isuewo for the sun angle handling
    #if SUN_ANGLE == -1
        #if SHADER_STYLE == 1
            const float sunPathRotation = 0.0;
            #define PERPENDICULAR_TWEAKS
        #elif SHADER_STYLE == 4
            const float sunPathRotation = -40.0;
        #endif
    #elif SUN_ANGLE == 0
        const float sunPathRotation = 0.0;
        #define PERPENDICULAR_TWEAKS
    #elif SUN_ANGLE == 20
        const float sunPathRotation = 20.0;
    #elif SUN_ANGLE == 30
        const float sunPathRotation = 30.0;
    #elif SUN_ANGLE == 40
        const float sunPathRotation = 40.0;
    #elif SUN_ANGLE == 50
        const float sunPathRotation = 50.0;
    #elif SUN_ANGLE == 60
        const float sunPathRotation = 60.0;
    #elif SUN_ANGLE == -20
        const float sunPathRotation = -20.0;
    #elif SUN_ANGLE == -30
        const float sunPathRotation = -30.0;
    #elif SUN_ANGLE == -40
        const float sunPathRotation = -40.0;
    #elif SUN_ANGLE == -50
        const float sunPathRotation = -50.0;
    #elif SUN_ANGLE == -60
        const float sunPathRotation = -60.0;
    #endif
    
    #if SHADOW_QUALITY >= 1
        const int shadowMapResolution = 2048;
    #else
        const int shadowMapResolution = 1024;
    #endif

    #if SSAO_I > 0
        #define SSAO_QUALI SSAO_QUALI_DEFINE
    #else
        #define SSAO_QUALI 0
    #endif
    #if LIGHTSHAFT_BEHAVIOUR > 0
        #define LIGHTSHAFT_QUALI LIGHTSHAFT_QUALI_DEFINE
    #else
        #define LIGHTSHAFT_QUALI 0
    #endif
    
    #if BLOCK_REFLECT_QUALITY >= 1
        #define LIGHT_HIGHLIGHT
    #endif
    #if BLOCK_REFLECT_QUALITY >= 2 && RP_MODE >= 1
        #define PBR_REFLECTIONS
    #endif
    #if BLOCK_REFLECT_QUALITY >= 3
        #define TEMPORAL_FILTER
    #endif

    #if DETAIL_QUALITY == 0
        #undef PERPENDICULAR_TWEAKS
        #define LOW_QUALITY_NETHER_STORM
        #define LOW_QUALITY_ENDER_NEBULA
    #endif
    #if DETAIL_QUALITY >= 1
        #define TAA
    #endif
    #if DETAIL_QUALITY >= 2
    
    #endif
    #if DETAIL_QUALITY >= 3
        #define HQ_NIGHT_NEBULA
    #endif

//Define Handling//
    #ifdef OVERWORLD
        #if CLOUD_STYLE > 0 && CLOUD_STYLE != 50 && CLOUD_QUALITY > 0
            #define VL_CLOUDS_ACTIVE
            #if CLOUD_STYLE == 1
                #define CLOUDS_REIMAGINED
            #endif
            #if CLOUD_STYLE == 3
                #define CLOUDS_UNBOUND
            #endif
        #endif
    #else
        #undef LIGHT_HIGHLIGHT
        #undef CAVE_FOG
        #undef CLOUD_SHADOWS
        #undef SNOWY_WORLD
        #undef LENSFLARE
    #endif
    #ifdef NETHER
        #undef ATMOSPHERIC_FOG
    #else
        #undef NETHER_STORM
    #endif
    #ifdef END
        #undef BLOOM_FOG
    #endif

    #ifndef BLOOM
        #undef BLOOM_FOG
    #endif

    #ifdef BLOOM_FOG
        #if WORLD_BLUR > 0
            #define BLOOM_FOG_COMPOSITE3
        #elif defined MOTION_BLURRING
            #define BLOOM_FOG_COMPOSITE2
        #else
            #define BLOOM_FOG_COMPOSITE
        #endif
    #endif

    #if defined GBUFFERS_HAND || defined GBUFFERS_ENTITIES
        #undef SNOWY_WORLD
    #endif
    #if defined GBUFFERS_TEXTURED || defined GBUFFERS_BASIC
        #undef LIGHT_HIGHLIGHT
        #undef DIRECTIONAL_SHADING
        #undef SIDE_SHADOWING
    #endif
    #ifdef GBUFFERS_WATER
        #undef LIGHT_HIGHLIGHT
    #endif

    #ifndef GLOWING_ENTITY_FIX
        #undef GBUFFERS_ENTITIES_GLOWING
    #endif

    #if LIGHTSHAFT_QUALI > 0 && defined OVERWORLD && defined REALTIME_SHADOWS || defined END
        #define LIGHTSHAFTS_ACTIVE
    #endif

    #if defined WAVING_FOLIAGE || defined WAVING_LEAVES || defined WAVING_LAVA
        #define WAVING_ANYTHING_TERRAIN
    #endif

    #ifdef IS_IRIS
        #undef FANCY_GLASS
    #endif

    #if WATERCOLOR_R != 100 || WATERCOLOR_G != 100 || WATERCOLOR_B != 100
        #define WATERCOLOR_RM WATERCOLOR_R * 0.01
        #define WATERCOLOR_GM WATERCOLOR_G * 0.01
        #define WATERCOLOR_BM WATERCOLOR_B * 0.01
        #define WATERCOLOR_CHANGED
    #endif

    #if UNDERWATERCOLOR_R != 100 || UNDERWATERCOLOR_G != 100 || UNDERWATERCOLOR_B != 100
        #define UNDERWATERCOLOR_RM UNDERWATERCOLOR_R * 0.01
        #define UNDERWATERCOLOR_GM UNDERWATERCOLOR_G * 0.01
        #define UNDERWATERCOLOR_BM UNDERWATERCOLOR_B * 0.01
        #define UNDERWATERCOLOR_CHANGED
    #endif

//Activate Settings//
    #ifdef ENTITY_SHADOWS
    #endif
    #ifdef POM_ALLOW_CUTOUT
    #endif
    #ifdef CLOUD_CLOSED_AREA_CHECK
    #endif
    #ifdef BRIGHT_CAVE_WATER
    #endif

//Very Common Uniforms//
    uniform int worldTime;
    uniform int worldDay;

    uniform float rainFactor;
    uniform float screenBrightness;
    uniform float eyeBrightnessM;

    uniform vec3 fogColor;

    #if NETHER_COLOR_MODE == 3
        uniform float inNetherWastes;
        uniform float inCrimsonForest;
        uniform float inWarpedForest;
        uniform float inBasaltDeltas;
        uniform float inSoulValley;
    #endif

    #ifdef VERTEX_SHADER
        uniform mat4 gbufferModelView;
    #endif

//Very Common Variables//
    const float OSIEBCA = 1.0 / 255.0; // One Step In Eight Bit Color Attachment
    /* materialMask steps
    IntegratedPBR:
        OSIEBCA * 1.0 = Intense Fresnel
        OSIEBCA * 2.0 = Copper Fresnel
        OSIEBCA * 3.0 = Gold Fresnel
        OSIEBCA * 4.0 = 
        OSIEBCA * 5.0 = Redstone Fresnel
        .
        OSIEBCA * 240.0 = Green Screen Lime Blocks
    PBR Independant: (Limited to 241 and above)
        OSIEBCA * 241.0 = Water
        .
        OSIEBCA * 252.0 = Versatile Selection Outline
        OSIEBCA * 253.0 = Reduced Edge TAA
        OSIEBCA * 254.0 = No SSAO, No TAA
        OSIEBCA * 255.0 = *Unused as 1.0 is the clear color*
    */

    float cloudMaxAdd = 5.0;
    uniform float cloudHeight = 192.0;
    uniform float eyeAltitude;
    #if defined DOUBLE_REIM_CLOUDS && defined CLOUDS_REIMAGINED
        float maximumCloudsHeight = max(CLOUD_ALT1, CLOUD_ALT2) + cloudMaxAdd;
    #elif CLOUD_STYLE_DEFINE == 50
        float maximumCloudsHeight = cloudHeight + cloudMaxAdd;
    #else
        float maximumCloudsHeight = CLOUD_ALT1 + cloudMaxAdd;
    #endif
    float cloudGradientLength = 30.0; // in blocks, probably...
    float heightRelativeToCloud = clamp(1.0 - (eyeAltitude - maximumCloudsHeight) / cloudGradientLength, 0.0, 1.0);

    const float shadowMapBias = 1.0 - 25.6 / shadowDistance;
    float timeAngle = worldTime / 24000.0;
    float noonFactor = sqrt(max(sin(timeAngle*6.28318530718),0.0));
    float nightFactor = max(sin(timeAngle*(-6.28318530718)),0.0);
    float invNightFactor = 1.0 - nightFactor;
    float rainFactor2 = rainFactor * rainFactor;
    float invRainFactor = 1.0 - rainFactor;
    float invRainFactorSqrt = 1.0 - rainFactor * rainFactor;
    float invNoonFactor = 1.0 - noonFactor;
    float invNoonFactor2 = invNoonFactor * invNoonFactor;

    float vsBrightness = clamp(screenBrightness, 0.0, 1.0);

    int modifiedWorldDay = int(mod(worldDay, 100) + 5.0);
    float syncedTime = (worldTime + modifiedWorldDay * 24000) * 0.05;

    const float pi = 3.14159265359;

    const float oceanAltitude = 61.9;

    const vec3 blocklightCol = vec3(0.2, 0.1098, 0.0431) * vec3(XLIGHT_R, XLIGHT_G, XLIGHT_B);

    const vec3 caveFogColorRaw = vec3(0.13, 0.13, 0.15);
    #if MINIMUM_LIGHT_MODE <= 1
        vec3 caveFogColor = caveFogColorRaw * 0.7;
    #elif MINIMUM_LIGHT_MODE == 2
        vec3 caveFogColor = caveFogColorRaw * (0.7 + 0.3 * vsBrightness); // Default
    #elif MINIMUM_LIGHT_MODE >= 3
        vec3 caveFogColor = caveFogColorRaw;
    #endif

    #if WATERCOLOR_MODE >= 2
        vec3 underwaterColorM1 = pow(fogColor, vec3(0.33, 0.21, 0.26));
    #else
        vec3 underwaterColorM1 = vec3(0.46, 0.62, 1.0);
    #endif
    #ifndef UNDERWATERCOLOR_CHANGED
        vec3 underwaterColorM2 = underwaterColorM1;
    #else
        vec3 underwaterColorM2 = underwaterColorM1 * vec3(UNDERWATERCOLOR_RM, UNDERWATERCOLOR_GM, UNDERWATERCOLOR_BM);
    #endif
    vec3 waterFogColor = underwaterColorM2 * vec3(0.2 + 0.1 * vsBrightness);

    #if NETHER_COLOR_MODE == 3 && defined FRAGMENT_SHADER
        float netherColorMixer = inNetherWastes + inCrimsonForest + inWarpedForest + inBasaltDeltas + inSoulValley;
        vec3 netherColor = mix(
            fogColor * 0.6 + 0.2 * normalize(fogColor + 0.0001),
            (
                inNetherWastes * vec3(0.38, 0.15, 0.05) + inCrimsonForest * vec3(0.33, 0.07, 0.04) +
                inWarpedForest * vec3(0.18, 0.1, 0.25) + inBasaltDeltas * vec3(0.25, 0.235, 0.23) +
                inSoulValley * vec3(0.1, vec2(0.24))
            ),
            netherColorMixer
        );
    #elif NETHER_COLOR_MODE == 2
        vec3 netherColor = fogColor * 0.6 + 0.2 * normalize(fogColor + 0.0001);
    #elif NETHER_COLOR_MODE == 0
        vec3 netherColor = vec3(0.7, 0.26, 0.08) * 0.6;
    #endif
    vec3 lavaLightColor = vec3(0.15, 0.06, 0.01);

    const vec3 endSkyColor = vec3(0.095, 0.07, 0.15) * 1.5;

	#if WEATHER_TEX_OPACITY == 100
		const float rainTexOpacity = 0.35;
		const float snowTexOpacity = 0.5;
	#else
		#define WEATHER_TEX_OPACITY_M 100.0 / WEATHER_TEX_OPACITY
		const float rainTexOpacity = pow(0.35, WEATHER_TEX_OPACITY_M);
		const float snowTexOpacity = pow(0.5, WEATHER_TEX_OPACITY_M);
	#endif

    #ifdef FRAGMENT_SHADER
        ivec2 texelCoord = ivec2(gl_FragCoord.xy);
    #endif

    const int cloudAlt1i = int(CLOUD_ALT1); // Old setting files can send float values
    const int cloudAlt2i = int(CLOUD_ALT2);

//Very Common Functions//
#include "/lib/util/commonFunctions.glsl"

// 62 75 74 20 74 68 4F 73 65 20 77 68 6F 20 68 6F 70 65 20 69 6E 20 74 68 65 20 6C 69 6D 69 4E 61 6C 0A 77 69 6C 6C 20 72 65 6E 65 77 20 74 68 65 69 72 20 73 54 72 65 6E 67 74 48 2E 0A 74 68 65 79 20 77 69 6C 6C 20 73 6F 41 72 20 6F 6E 20 65 6C 79 54 72 61 73 20 6C 69 6B 65 20 70 68 61 6E 74 6F 6D 73 3B 0A 74 68 65 79 20 77 69 6C 6C 20 72 75 6E 20 61 6E 44 20 6E 6F 74 20 67 72 6F 77 20 77 65 41 72 79 2C 0A 74 68 65 59 20 77 69 6C 6C 20 77 61 6C 6B 20 61 6E 64 20 6E 6F 74 20 62 65 20 66 61 69 6E 74 2E