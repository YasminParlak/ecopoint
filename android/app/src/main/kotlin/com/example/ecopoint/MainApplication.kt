package com.example.ecopoint

import 'core/constants/env.dart';
import android.app.Application
import com.yandex.mapkit.MapKitFactory

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // ВСТАВЬ СЮДА СВОЙ РЕАЛЬНЫЙ КЛЮЧ ИЗ КАБИНЕТА ЯНДЕКСА!
        MapKitFactory.setApiKey(" yandexApiKey")
        MapKitFactory.setLocale("ru_RU")
    }
}