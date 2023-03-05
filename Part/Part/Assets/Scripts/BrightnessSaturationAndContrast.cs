using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightnessSaturationAndContrast : PostEffectBase
{
    public Shader briSatConShader;

    private Material briSatConMaterial;

    public Material Material
    {
        get
        {
            briSatConMaterial = CheckShaderAndCreatMaterial(briSatConShader, briSatConMaterial);
            return briSatConMaterial;
        }
    }

    [Range(0.0f, 3.0f)]
    public float brightness = 1.0f;
    [Range(0.0f, 3.0f)]
    public float saturation = 1.0f;
    [Range(0.0f, 3.0f)]
    public float constrast = 1.0f;

    public void OnRenderIamge(RenderTexture src,RenderTexture dest)
    {
        if(Material!=null)
        {
            Material.SetFloat("_Brightness", brightness);
            Material.SetFloat("_Saturation", saturation);
            Material.SetFloat("_Contrast", constrast);
            Graphics.Blit(src, dest, Material);
        }
        Graphics.Blit(src, dest);
    }
}
