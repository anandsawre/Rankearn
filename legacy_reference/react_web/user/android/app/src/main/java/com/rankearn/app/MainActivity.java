package com.rankearn.app;

import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onStart() {
        super.onStart();
        // Force the WebView to ignore system-wide font scaling, ensuring identical scaling to PWAs/browsers.
        WebView webView = this.bridge.getWebView();
        if (webView != null) {
            WebSettings webSettings = webView.getSettings();
            webSettings.setTextZoom(100);
        }
    }
}
