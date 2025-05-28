package com.rhenis.gridwords;

import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.PendingPurchasesParams;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchasesUpdatedListener;
import com.android.billingclient.api.QueryPurchasesParams;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import android.app.Activity;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import org.json.JSONArray;

import java.util.ArrayList;
import java.util.List;

@CapacitorPlugin(name = "GetOwnedProductsPlugin")
public class GetOwnedProductsPlugin extends Plugin implements PurchasesUpdatedListener {

    private static final String TAG = "GetOwnedProductsPlugin";

    @PluginMethod
    public void getOwnedProducts(PluginCall call) {

        try {
            var pendingPurchasesParams = PendingPurchasesParams
                    .newBuilder()
                    .enableOneTimeProducts()
                    .build();

        var billingClient =  BillingClient.newBuilder(getActivity())
                .setListener(this)
                .enablePendingPurchases(pendingPurchasesParams)
                .build();

        billingClient.startConnection(new BillingClientStateListener() {
            @Override
            public void onBillingSetupFinished(BillingResult result) {
                if (result.getResponseCode() == BillingClient.BillingResponseCode.OK) {
                    QueryPurchasesParams params = QueryPurchasesParams.newBuilder()
                        .setProductType(BillingClient.ProductType.INAPP)
                        .build();

                    billingClient.queryPurchasesAsync(params, (billingResult, list) -> {
                        List<String> products = new ArrayList<String>();
                        for (int i = 0; i < list.size(); ++i) {
                            var order = list.get(i);
                            products.addAll(order.getProducts());
                        }
                        JSObject ret = new JSObject();
                        ret.put("productIds", new JSONArray(products));
                        call.resolve(ret);
                    });
                    billingClient.endConnection();
                }
            }
            @Override
            public void onBillingServiceDisconnected() {
                Log.e(TAG, "Billing service disconnected");
                call.reject("Billing service disconnected");
            }
        });

        } catch (Exception e) {
            Log.e(TAG, "getOwnedProducts error: " + e.getMessage());
            call.reject("getOwnedProducts error: " + e.getMessage());
        }
    }

    @Override
    public void onPurchasesUpdated(@NonNull BillingResult billingResult, @Nullable List<Purchase> list) {
        Log.d(TAG, "onPurchasesUpdated: "+ (list != null ? list.toString() : "null"));
    }
}