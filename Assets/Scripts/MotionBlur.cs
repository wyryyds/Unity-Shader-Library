using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : PostEffectsBase
{
    public Shader motionBlurShader;
    private Material motionBlurMaterial=null;
    
    public Material MotionBlurMaterial
    {
        get
        {
            motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial); 
            return motionBlurMaterial;
        }
    }

    [Range(0.0f,0.9f)]
    public float blurAmount = 0.5f;
    private RenderTexture accumulationTexture;

    private void OnDisable()
    {
        DestroyImmediate(accumulationTexture);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(MotionBlurMaterial != null)
        {
            if(accumulationTexture == null||accumulationTexture.width!=source.width||accumulationTexture.height!=source.height) 
            {
                DestroyImmediate(accumulationTexture);
                accumulationTexture = new RenderTexture(source.width, source.height,0);
                accumulationTexture.hideFlags = HideFlags.HideAndDontSave;
                Graphics.Blit(source, accumulationTexture);
            }
            //进行纹理渲染的恢复操作
            accumulationTexture.MarkRestoreExpected();
            MotionBlurMaterial.SetFloat("_BlurAmount", 1.0f - blurAmount);
            Graphics.Blit(source, accumulationTexture, MotionBlurMaterial);
            Graphics.Blit(accumulationTexture,destination);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
