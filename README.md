# Ad Scanner - Détecteur de Publicités Intrusives

Une application Flutter pour détecter et gérer les applications qui utilisent des permissions potentiellement intrusives, comme les publicités superposées et les notifications.

## Fonctionnalités

- 📱 **Scanner d'Applications**
  - Détection des applications installées
  - Vérification des permissions sensibles
  - Identification des applications système

- 🚨 **Détection des Publicités**
  - Surveillance des fenêtres superposées
  - Détection des notifications intrusives
  - Historique des détections

- ⚙️ **Gestion des Permissions**
  - Overlay (fenêtres superposées)
  - Notifications
  - Optimisation de la batterie

- 📊 **Statistiques**
  - Nombre d'applications suspectes
  - Fréquence des détections
  - État des permissions

## Configuration Requise

- Flutter SDK ≥ 3.0.0
- Android SDK ≥ 21 (Android 5.0)
- Permissions Android requises

## Installation

1. Clonez le dépôt :
```bash
git clone https://github.com/dkl001/ad_scanner.git
```

2. Installez les dépendances :
```bash
flutter pub get
```

3. Ajoutez les permissions nécessaires dans `android/app/src/main/AndroidManifest.xml` :
```xml
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />
<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS"/>
<uses-permission android:name="android.permission.GET_TASKS"/>
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS"/>
```

## Utilisation

1. Lancez l'application
2. Accordez les permissions demandées
3. Utilisez les différents onglets pour :
   - Voir la liste des applications
   - Consulter les statistiques
   - Gérer les paramètres

## Structure du Projet

```
lib/
├── main.dart              # Point d'entrée de l'application
├── models/               
│   └── app_info.dart      # Modèle pour les informations d'applications
├── services/
│   └── platform_service.dart  # Services natifs Android
└── ui/
    └── screens/           # Écrans de l'application
```

android/
├── app/
│   └── src/
│       └── main/
│           ├── kotlin/
│           │   └── com/
│           │       └── example/
│           │           └── ad_scanner/
│           │               └── MainActivity.kt    # Code natif Android pour la détection
│           ├── AndroidManifest.xml              # Configuration Android et permissions
│           └── build.gradle                     # Configuration de build Android
```

### 📱 Code Android Natif

Le code natif Android (`MainActivity.kt`) gère :
- La détection des applications installées
- La surveillance des processus en cours
- La vérification des permissions
- La détection des fenêtres superposées


### ⚠️ Problèmes Connus

L'application présente actuellement plusieurs limitations et bugs :

1. **Erreurs Critiques**
   - `MissingPluginException(No implementation found for method getRunningApps on channel app.scanner/apps)`
   - Cette erreur empêche la détection des applications en cours d'exécution
   - Le canal de communication Flutter-Android n'est pas correctement implémenté

2. **Détection des Applications**
   - La liste des applications installées peut être incomplète
   - Certaines permissions peuvent ne pas être détectées correctement
   - Les services en arrière-plan ne sont pas détectés à cause de l'erreur MissingPluginException

3. **Permissions Android**
   - Certaines permissions système peuvent ne pas être accordées correctement
   - Les versions récentes d'Android peuvent bloquer certaines fonctionnalités

4. **Interface Utilisateur**
   - Problèmes de mise en page avec les listes imbriquées
   - Les mises à jour en temps réel peuvent causer des problèmes d'affichage

### 🔧 Solutions en Cours

Nous travaillons sur les corrections suivantes :
1. Correction de l'implémentation du MethodChannel pour `getRunningApps`
2. Amélioration de l'intégration Flutter-Android
3. Implémentation d'une meilleure gestion des permissions
4. Optimisation de la détection des applications en arrière-plan

### 💡 Contributions Bienvenues

Si vous souhaitez contribuer à l'amélioration de l'application, voici les domaines prioritaires :
- Correction du MissingPluginException dans le code natif Android
- Amélioration de la stabilité de l'interface
- Optimisation de l'utilisation des ressources système
- Tests sur différentes versions d'Android

## Dépendances Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  permission_handler: ^10.2.0
  package_info_plus: ^4.0.0
```

## Contribution

1. Fork le projet
2. Créez votre branche de fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## Capture d'écran

[à ajouter plus tard]

## Notes de Sécurité

- L'application nécessite des permissions système pour fonctionner correctement
- Certaines fonctionnalités peuvent être limitées selon la version d'Android
- L'application ne collecte aucune donnée personnelle

## Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE.md](LICENSE.md) pour plus de détails.

## Auteur

Salim L. - [dankobosalim@gmail.com]

## Remerciements

- Flutter Team pour le framework
- La communauté open source pour les packages utilisés