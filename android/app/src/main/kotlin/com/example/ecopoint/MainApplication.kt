package com.example.ecopoint

import android.app.Application
import com.yandex.mapkit.MapKitFactory

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        MapKitFactory.setLocale("ru_RU")
        MapKitFactory.setApiKey("bbae5e08-32ca-413f-be08-dbb00fdd64c7")
    }
}