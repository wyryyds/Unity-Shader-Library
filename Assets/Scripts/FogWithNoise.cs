using System.Collections;
using System.Collections.Generic;
using System.Net.Http.Headers;
using UnityEngine;

public class FogWithNoise : PostEffectsBase
{
    public Shader fogShader;
    private Material fogMaterial=null;
    public Material FogMaterial
    {
        get
        {
            fogMaterial = CheckShaderAndCreateMaterial(fogShader, fogMaterial); 
            return fogMaterial;
        }
    }

    private Camera _camera;
    public Camera Camera
    {
        get
        {
            if(_camera == null)
            {
                _camera=GetComponent<Camera>();
            }
            return _camera;
        }
    }

    private Transform _cameraTransform;
    public Transform CameraTransform
    {
        get
        {
            if(_cameraTransform == null)
            {
                _cameraTransform = Camera.transform;
            }
            return _cameraTransform;
        }
    }

    /// <summary>
    /// 控制雾的浓度
    /// </summary>
    [Range(0.0f, 3.0f)]
    public float fogDensity = 1.0f;
    public Color fogColor = Color.white;
    //基于高度
    public float fogStart = 0.0f;
    public float fogEnd = 2.0f;

    public Texture noiseTexture;
    [Range(-0.5f, 0.5f)]
    public float fogXSpeed = 0.1f;
    [Range(-0.5f, 0.5f)]
    public float fogYSpeed = 0.1f;
    [Range(0.0f, 3.0f)]
    public float noiseAmount = 1.0f;

    private void OnEnable()
    {
        Camera.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(FogMaterial != null) 
        {
            Matrix4x4 frustumCorners = Matrix4x4.identity;
            float fov = Camera.fieldOfView;
            float near = Camera.nearClipPlane;
            float aspect = Camera.aspect;

            float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
            Vector3 toRight = aspect * halfHeight * CameraTransform.right;
            Vector3 toTop = halfHeight * CameraTransform.up;
            //计算近裁剪平面的四个角对应的向量
            Vector3 topLeft = CameraTransform.forward * near + toTop - toRight;
            float scale = topLeft.magnitude / near;
            topLeft.Normalize();
            topLeft *= scale;

            Vector3 topRight = CameraTransform.forward * near + toRight + toTop;
            topRight.Normalize();
            topRight *= scale;

            Vector3 bottonLeft = CameraTransform.forward * near - toTop - toRight;
            bottonLeft.Normalize();
            bottonLeft *= scale;

            Vector3 bottonRight = CameraTransform.forward * near + toRight - toTop;
            bottonRight.Normalize();
            bottonRight *= scale;

            frustumCorners.SetRow(0, bottonLeft);
            frustumCorners.SetRow(1, bottonRight);
            frustumCorners.SetRow(2, topRight);
            frustumCorners.SetRow(3, topLeft);

            FogMaterial.SetMatrix("_FrustumCornerRay", frustumCorners);
            FogMaterial.SetFloat("_FogDensity", fogDensity);
            FogMaterial.SetColor("_FogColor", fogColor);
            FogMaterial.SetFloat("_FogStart", fogStart);
            FogMaterial.SetFloat("_FogEnd", fogEnd);
            FogMaterial.SetTexture("_NoiseTex", noiseTexture);
            FogMaterial.SetFloat("_FogXSpeed", fogXSpeed);
            FogMaterial.SetFloat("_FogYSpeed", fogYSpeed);
            FogMaterial.SetFloat("_NoiseAmount", noiseAmount);
            Graphics.Blit(source,destination, FogMaterial);
        }
        else
        {
            Graphics.Blit (source, destination);
        }
    }
}
