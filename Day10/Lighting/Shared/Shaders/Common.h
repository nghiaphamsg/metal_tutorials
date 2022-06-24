//
//  Common.h
//  Lighting
//
//  Created by Pham Nghia on 2022/06/19.
//

#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef enum {
  Position = 0,
  Normal = 1,
  UV = 2,
  Color = 3
} Attributes;

typedef enum {
  VertexBuffer = 0,
  UVBuffer = 1,
  ColorBuffer = 2,
  UniformsBuffer = 11,
  ParamsBuffer = 12,
  LightBuffer = 13
} BufferIndices;

typedef enum {
  BaseColor = 0
} TextureIndices;

typedef enum {
  unused = 0,
  Sun = 1,
  Spot = 2,
  Point = 3,
  Ambient = 4
} LightType;

typedef struct {
  matrix_float3x3 normalMatrix;
  matrix_float4x4 modelMatrix;
  matrix_float4x4 viewMatrix;
  matrix_float4x4 projectionMatrix;
  float pointSize;
} Uniforms;

typedef struct {
  uint width;
  uint height;
  uint tiling;
  uint lightCount;
  vector_float3 cameraPosition;
} Params;

typedef struct {
  LightType type;
  vector_float3 position;
  vector_float3 color;
  vector_float3 specularColor;
  float radius;
  vector_float3 attenuation;
  float coneAngle;
  vector_float3 coneDirection;
  float coneAttenuation;
} Light;

#endif /* Common_h */
