package com.blurrn.blurview.blur;

import android.graphics.drawable.Drawable;

import androidx.annotation.ColorInt;
import androidx.annotation.Nullable;

public interface BlurViewFacade {

    /**
     * Enables/disables the blur. Enabled by default
     *
     * @param enabled true to enable, false otherwise
     * @return {@link BlurViewFacade}
     */
    BlurViewFacade setBlurEnabled(boolean enabled);

    /**
     * Can be used to stop blur auto update or resume if it was stopped before.
     * Enabled by default.
     *
     * @return {@link BlurViewFacade}
     */
    BlurViewFacade setBlurAutoUpdate(boolean enabled);

    /**
     * @param radius sets the blur radius
     *               Default value is {@link BlurController#DEFAULT_BLUR_RADIUS}
     * @return {@link BlurViewFacade}
     */
    BlurViewFacade setBlurRadius(float radius);

    /**
     * Sets the color overlay to be drawn on top of blurred content
     *
     * @param overlayColor int color
     * @return {@link BlurViewFacade}
     */
    BlurViewFacade setOverlayColor(@ColorInt int overlayColor);
}
