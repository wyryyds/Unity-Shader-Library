using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffectsBase
{
    public Shader bloomShader;

    private Material bloomMaterial;

    public Material BloomMaterial
    {
        get
        {
            bloomMaterial = CheckShaderAndCreateMaterial(bloomShader, bloomMaterial);
            return bloomMaterial; ;
        }
    }

    //Bloom效果是建立在高斯模糊的基础上的
    [Range(0, 4)]
    public int iterations = 3;
    [Range(0.2f, 3.0f)]
    public float blurSpread=2;
    [Range(1, 8)]
    public int downSample = 2;

    //提取较亮区域时的阈值大小
    [Range(0.0f, 4.0f)]
    public float luminanceThreshold = 0.6f;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(BloomMaterial != null)
        {
            BloomMaterial.SetFloat("_LuminanceThreshold", luminanceThreshold);

            int rtw = source.width / downSample;
            int rth = source.height / downSample;
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtw, rth, 0);
            buffer0.filterMode = FilterMode.Bilinear;
            Graphics.Blit(source, buffer0, BloomMaterial, 0);
            for(int i = 0; i < iterations; i++)
            {
                BloomMaterial.SetFloat("_BlurSize", 1.0f + i * blurSpread);
                RenderTexture buffer1 = RenderTexture.GetTemporary(rtw,rth, 0);
                Graphics.Blit(buffer0, buffer1, BloomMaterial, 1);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary (rtw,rth, 0);
                Graphics.Blit(buffer0, buffer1, BloomMaterial, 2);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0=buffer1;
            }
            BloomMaterial.SetTexture("_Bloom", buffer0);
            Graphics.Blit(source, destination, BloomMaterial, 3);
            RenderTexture.ReleaseTemporary (buffer0);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
