package com.example.oouchi_stock

import android.content.Intent
import android.os.Bundle
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.security.ProviderInstaller
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity(), ProviderInstaller.ProviderInstallListener {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Ensure Google Play services' security provider is installed when
        // Google Play services is available on the device. Some emulator
        // images do not include Play services and calling
        // ProviderInstaller without this check results in a
        // SecurityException.
        val availability = GoogleApiAvailability.getInstance()
        val result = availability.isGooglePlayServicesAvailable(this)
        if (result == ConnectionResult.SUCCESS) {
            ProviderInstaller.installIfNeededAsync(this, this)
        } else if (availability.isUserResolvableError(result)) {
            availability.showErrorDialogFragment(this, result, 0)
        }
    }

    override fun onProviderInstalled() {
        // Security provider successfully installed. Nothing to do.
    }

    override fun onProviderInstallFailed(errorCode: Int, intent: Intent?) {
        // If Google Play services is missing or needs to be updated, display a dialog.
        val availability = GoogleApiAvailability.getInstance()
        if (availability.isUserResolvableError(errorCode)) {
            availability.showErrorDialogFragment(this, errorCode, 0)
        }
    }
}
