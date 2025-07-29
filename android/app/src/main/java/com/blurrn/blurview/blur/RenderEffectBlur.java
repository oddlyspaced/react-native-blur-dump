package com.blurrn.blurview.blur;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.RenderEffect;
import android.graphics.RenderNode;
import android.graphics.Shader;
import android.graphics.BlendMode;
import android.graphics.BlendModeColorFilter;

import androidx.annotation.NonNull;

/**
 * Leverages the new RenderEffect.createBlurEffect API to perform blur.
 * Hardware accelerated.
 * Blur is performed on a separate thread - native RenderThread.
 * It doesn't block the Main thread, however it can still cause an FPS drop,
 * because it's just in a different part of the rendering pipeline.
 */
public class RenderEffectBlur {

    private final RenderNode node = new RenderNode("BlurViewNode");

    private int height, width;

    // Tint strength (0–255). Adjust to taste.
    private static final int TINT_ALPHA = 120; // ~47% opacity

    public RenderEffectBlur() {
    }

    public Bitmap blur(@NonNull Bitmap bitmap, float blurRadius) {

        if (bitmap.getHeight() != height || bitmap.getWidth() != width) {
            height = bitmap.getHeight();
            width = bitmap.getWidth();
            node.setPosition(0, 0, width, height);
        }

        Canvas canvas = node.beginRecording();
        canvas.drawBitmap(bitmap, 0, 0, null);
        node.endRecording();

        // --- blur + red‑tint chain ---
        RenderEffect blurEffect =
                RenderEffect.createBlurEffect(blurRadius, blurRadius, Shader.TileMode.MIRROR);

        RenderEffect tintEffect =
                RenderEffect.createColorFilterEffect(
                        new BlendModeColorFilter(
                                Color.argb(TINT_ALPHA, 255, 0, 255), // red
                                BlendMode.SRC_ATOP));

        // First blur, then apply tint
        RenderEffect chained = RenderEffect.createChainEffect(tintEffect, blurEffect);
        node.setRenderEffect(chained);
        // --------------------------------

        // returning the original bitmap; rendering happens via RenderNode
        return bitmap;
    }

    public void destroy() {
        node.discardDisplayList();
    }

    public boolean canModifyBitmap() {
        return true;
    }

    @NonNull
    public Bitmap.Config getSupportedBitmapConfig() {
        return Bitmap.Config.ARGB_8888;
    }

    public void render(@NonNull Canvas canvas, @NonNull Bitmap bitmap) {
        canvas.drawRenderNode(node);
    }
}
