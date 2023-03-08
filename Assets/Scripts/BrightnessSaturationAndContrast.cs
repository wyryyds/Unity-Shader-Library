using UnityEngine;
using System.Collections;

public class BrightnessSaturationAndContrast : PostEffectsBase
{

	public Shader briSatConShader;
	private Material briSatConMaterial;
	public Material Material
	{
		get
		{
			briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader, briSatConMaterial);
			return briSatConMaterial;
		}
	}

	[Range(0.0f, 3.0f)]
	public float brightness = 1.0f;

	[Range(0.0f, 3.0f)]
	public float saturation = 1.0f;

	[Range(0.0f, 3.0f)]
	public float contrast = 1.0f;

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (Material != null)
		{
			Material.SetFloat("_Brightness", brightness);
			Material.SetFloat("_Saturation", saturation);
			Material.SetFloat("_Contrast", contrast);

			Graphics.Blit(src, dest, Material);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}
