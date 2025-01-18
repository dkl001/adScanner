# Ad Scanner - Détecteur de Publicités Intrusives

Une application Flutter pour détecter et gérer les applications qui utilisent des permissions potentiellement intrusives, comme les publicités superposées et les notifications.

## 🚀 Fonctionnalités

### Scanner d'Applications 📱
* Détection des applications installées
* Vérification des permissions sensibles
* Identification des applications système

### Détection des Publicités 🚨
* Surveillance des fenêtres superposées
* Détection des notifications intrusives
* Historique des détections

### Gestion des Permissions ⚙️
* Overlay (fenêtres superposées)
* Notifications
* Optimisation de la batterie

### Statistiques 📊
* Nombre d'applications suspectes
* Fréquence des détections
* État des permissions

## 📋 Prérequis

* Flutter SDK ≥ 3.0.0
* Android SDK ≥ 21 (Android 5.0)
* Permissions Android requises

## 🛠️ Installation

1. Clonez le dépôt :
```bash
git clone https://github.com/dkl001/ad_scanner.git
```

2. Installez les dépendances :
```bash
flutter pub get
```

3. Ajoutez les permissions dans `android/app/src/main/AndroidManifest.xml` :
```xml
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />
<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS"/>
<uses-permission android:name="android.permission.GET_TASKS"/>
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS"/>
```

## 📱 Utilisation

1. Lancez l'application
2. Accordez les permissions demandées
3. Utilisez les différents onglets pour :
   * Voir la liste des applications
   * Consulter les statistiques
   * Gérer les paramètres

## 📁 Structure du Projet

### Code Flutter
```
lib/
├── main.dart                    # Point d'entrée de l'application
├── models/               
│   └── app_info.dart           # Modèle pour les informations d'applications
├── services/
│   └── platform_service.dart    # Services natifs Android
└── ui/
    └── screens/                 # Écrans de l'application
```

### Code Android Natif
```
android/
├── app/src/main/
    ├── kotlin/.../ad_scanner/
    │   └── MainActivity.kt      # Code natif Android pour la détection
    ├── AndroidManifest.xml      # Configuration Android et permissions
    └── build.gradle            # Configuration de build Android
```

## ⚠️ Problèmes Connus

### Erreurs Critiques
* `MissingPluginException` dans la méthode `getRunningApps`
* Canal de communication Flutter-Android incomplet
* Détection des applications en arrière-plan non fonctionnelle

### Limitations Techniques
* Liste des applications potentiellement incomplète
* Problèmes de détection des permissions
* Restrictions sur certaines versions d'Android

## 🔧 Solutions en Cours

1. Correction de l'implémentation MethodChannel
2. Amélioration de l'intégration Flutter-Android
3. Optimisation de la gestion des permissions
4. Stabilisation de la détection d'applications

## 📦 Dépendances

```yaml
dependencies:
  flutter:
    sdk: flutter
  permission_handler: ^10.2.0
  package_info_plus: ^4.0.0
```

## 🤝 Contribution

1. Fork le projet
2. Créez votre branche (`git checkout -b feature/Amelioration`)
3. Committez vos changements (`git commit -m 'Ajout amélioration'`)
4. Push vers la branche (`git push origin feature/Amelioration`)
5. Ouvrez une Pull Request

## 🔐 Sécurité

* Permissions système requises
* Fonctionnalités variables selon Android
* Aucune collecte de données personnelles

## 📝 Licence

MIT License - voir [LICENSE.md](LICENSE.md)

## 👤 Auteur

Salim L. - [dankobosalim@gmail.com]

## 🙏 Remerciements

* Flutter Team
* Communauté open source Flutter