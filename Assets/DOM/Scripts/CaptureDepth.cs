using UnityEngine;
using System.Collections;

public class CaptureDepth : MonoBehaviour
{
	public RenderTexture depthTexture;
	public RenderTexture opacityMapTexture;

	private Camera mCam;
	private Shader mSampleDepthShader;
	private Shader mOpacityMapShader;

	void Awake()
	{
		mCam = GetComponent<Camera>();
		mSampleDepthShader = Shader.Find("DOM/DOMDepthShader");
		mOpacityMapShader = Shader.Find("DOM/DOMOpacityMapShader");

		if(mCam != null)
		{
			// LightProjMat
			Matrix4x4 lightProjecionMatrix = GetLightProjectMatrix(mCam);
			Shader.SetGlobalMatrix("_LightProjection", lightProjecionMatrix);

			// Light ZBufferParamsXY
			Vector4 ZBufferParams = GetLightZBufferParams(mCam);
			Shader.SetGlobalVector("_LightZBufferParams", ZBufferParams);

			// Depth
			mCam.backgroundColor = Color.white;
			mCam.clearFlags = CameraClearFlags.Color;
			mCam.targetTexture = depthTexture;
			mCam.enabled = false;
			Shader.SetGlobalTexture ("_LightDepthTex", depthTexture);
			mCam.RenderWithShader(mSampleDepthShader, "RenderType"); //mCam.SetReplacementShader (mSampleDepthShader, "RenderType");

			// OpacityMap
			mCam.backgroundColor = Color.clear;
			mCam.clearFlags = CameraClearFlags.Color;
			mCam.targetTexture = opacityMapTexture;
			mCam.enabled = false;
			Shader.SetGlobalTexture("_OpacityMapTex", opacityMapTexture);
			mCam.RenderWithShader(mOpacityMapShader, "RenderType");
		}
	}

	Matrix4x4 GetLightProjectMatrix(Camera lightCam)
	{
		Matrix4x4 posToUV = new Matrix4x4();
		posToUV.SetRow(0, new Vector4(0.5f, 0, 0, 0.5f));
		posToUV.SetRow(1, new Vector4(0, 0.5f, 0, 0.5f));
		posToUV.SetRow(2, new Vector4(0, 0, 1, 0));
		posToUV.SetRow(3, new Vector4(0, 0, 0, 1));

		Matrix4x4 worldToView = lightCam.worldToCameraMatrix;
        
		Matrix4x4 projection = GL.GetGPUProjectionMatrix(lightCam.projectionMatrix, false);

		return projection * worldToView;
	}

	Vector4 GetLightZBufferParams(Camera lightCam)
	{
		float far = lightCam.farClipPlane;
		float near = lightCam.nearClipPlane;
		float zc0 = (1.0f - far) / near;
		float zc1 = far / near;
		return new Vector4(zc0,zc1,0,0);
    }
}