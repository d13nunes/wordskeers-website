package com.rhenis.gridwords;

import com.getcapacitor.BridgeActivity;
import android.os.Build;
import android.view.View;
import android.view.WindowInsets;
import android.view.WindowInsetsController;
import android.os.Bundle;

public class MainActivity extends BridgeActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        initialPlugins.add(GetOwnedProductsPlugin.class);
        super.onCreate(savedInstanceState);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) { // API Level 30
            final WindowInsetsController insetsController = getWindow().getInsetsController();
            if (insetsController != null) {
                // Hide the system bars (status bar and navigation bar)
                insetsController.hide(WindowInsets.Type.systemBars());

                // Optional: Make the system bars appear temporarily when the user swipes from the edge
                // and then hide again. This is similar to IMMERSIVE_STICKY.
                insetsController.setSystemBarsBehavior(WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
            }
        } else {
            // Fallback for older API levels
            hideSystemUI_Legacy();
        }
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        if (hasFocus) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                // Re-apply hiding for API 30+
                final WindowInsetsController insetsController = getWindow().getInsetsController();
                if (insetsController != null) {
                    insetsController.hide(WindowInsets.Type.systemBars());
                }
            } else {
                // Re-apply hiding for older API levels
                hideSystemUI_Legacy();
            }
        }
    }

    private void hideSystemUI_Legacy() {
        // Existing immersive full-screen mode for API < 30
        View decorView = getWindow().getDecorView();
        decorView.setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                        | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                        | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                        | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                        | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                        | View.SYSTEM_UI_FLAG_FULLSCREEN
        );
    }}
