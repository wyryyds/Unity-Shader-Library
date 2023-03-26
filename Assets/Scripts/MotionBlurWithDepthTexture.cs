using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurWithDepthTexture : PostEffectsBase
{
    public Shader motionBlurShader;
    private Material motionBlurMaterial=null;

    public Material MotionBlurMaterial
    {
        get
        {
            motionBlurMaterial=CheckShaderAndCreateMaterial(motionBlurShader,motionBlurMaterial);
            return motionBlurMaterial;
        }
    }

    [Range(0.0f, 1.0f)]
    public float blurSize = 0.5f;

    private Camera _camera;
    public Camera Camera
    {
        get
        {
            if( _camera == null )_camera = GetComponent<Camera>();
            return _camera;
        }
    }
    /// <summary>
    /// 保存上一帧摄像机的视角*投影矩阵
    /// </summary>
    private Matrix4x4 previousViewProjectionMatrix;

    private void OnEnable()
    {
        Camera.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(MotionBlurMaterial!=null)
        {
            MotionBlurMaterial.SetFloat("_BlurSize", blurSize);
            MotionBlurMaterial.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
            Matrix4x4 curViewProjectionMatrix = Camera.projectionMatrix * Camera.worldToCameraMatrix;
            Matrix4x4 curViewProjectionInverseMatrix = curViewProjectionMatrix.inverse;
            MotionBlurMaterial.SetMatrix("_CurrentViewProjectionInverseMatrix", curViewProjectionInverseMatrix);
            previousViewProjectionMatrix = curViewProjectionMatrix;
            Graphics.Blit(source, destination, motionBlurMaterial );
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
