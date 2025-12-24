<div align="center">

# 🎯 Kim Ne Yaptı?

### Takım Takip Mobil Uygulaması

[![Flutter](https://img.shields.io/badge/Flutter-3.24.5-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

*Küçük ekipler için gerçek zamanlı görev takip ve durum paylaşım uygulaması*

[Özellikler](#-özellikler) • [Kurulum](#-kurulum) • [Ekran Görüntüleri](#-ekran-görüntüleri) • [Mimari](#-mimari)

---

</div>

## ✨ Özellikler

<table>
<tr>
<td width="50%">

### 📋 Görev Yönetimi
- **Kanban-tarzı** görev panosu
- **4 kategori**: Active, Bug, Logic, Fikir
- **3 durum**: Yapılacak, Yapılıyor, Tamamlandı
- Öncelik seviyeleri (Düşük, Orta, Yüksek)
- Görev atama ve takip

</td>
<td width="50%">

### 👥 Takım İşbirliği
- **Workspace** tabanlı çalışma alanları
- Davet kodu ile kolay katılım
- Gerçek zamanlı senkronizasyon
- Üye yönetimi ve roller

</td>
</tr>
<tr>
<td width="50%">

### 🟢 Presence Sistemi
- **Anlık durum**: Active, Idle, Busy, Away
- Özel durum mesajları
- "Şu anda ne üzerinde çalışıyor?" görünümü
- Takım üyelerinin aktiflik durumu

</td>
<td width="50%">

### 📊 Aktivite Takibi
- Gerçek zamanlı aktivite akışı
- Görev oluşturma, atama, tamamlama logları
- Tarih bazlı gruplama
- Detaylı değişiklik geçmişi

</td>
</tr>
<tr>
<td width="50%">

### 💡 Fikir Kutusu
- Hızlı fikir kaydetme
- **Tek tıkla** fikri göreve dönüştür
- Bug veya Logic olarak işaretle
- Backlog yönetimi

</td>
<td width="50%">

### 🔔 Bildirimler
- Push notification altyapısı (FCM)
- "Sana iş atandı" bildirimleri
- In-app bildirimler
- Cloud Functions entegrasyonu

</td>
</tr>
</table>

---

## 🚀 Kurulum

### Gereksinimler

| Gereksinim | Versiyon |
|------------|----------|
| Flutter SDK | ≥ 3.2.0 |
| Dart SDK | ≥ 3.0.0 |
| Firebase CLI | Latest |
| Node.js | ≥ 18.0.0 |

### 1️⃣ Projeyi Klonla

```bash
git clone https://github.com/YOUR_USERNAME/kim-ne-yapti.git
cd kim-ne-yapti
```

### 2️⃣ Firebase Kurulumu

```bash
# Firebase CLI'a giriş yap
firebase login

# FlutterFire CLI'ı aktifleştir
dart pub global activate flutterfire_cli

# Firebase projesini yapılandır
flutterfire configure --project=YOUR_PROJECT_ID
```

### 3️⃣ Firebase Console Ayarları

1. [Firebase Console](https://console.firebase.google.com)'a git
2. **Authentication** → Anonymous sign-in'i aktifleştir
3. **Cloud Firestore** → Database oluştur

### 4️⃣ Firestore Rules'ı Deploy Et

```bash
firebase deploy --only firestore:rules
```

### 5️⃣ Uygulamayı Çalıştır

```bash
# Bağımlılıkları yükle
flutter pub get

# Android'de çalıştır
flutter run -d android

# iOS'ta çalıştır
flutter run -d ios
```

---

## 📱 Ekran Görüntüleri

<div align="center">

| Workspace Listesi | Görev Panosu | Aktivite Logu |
|:-----------------:|:------------:|:-------------:|
| *Çalışma alanlarınız* | *Keep-tarzı görev kartları* | *Gerçek zamanlı aktiviteler* |

| Görev Detayı | Durum Güncelleme | Fikir Kutusu |
|:------------:|:----------------:|:------------:|
| *Detaylı görev görünümü* | *Presence sistemi* | *Hızlı fikir-görev dönüşümü* |

</div>

---

## 🏗 Mimari

```
lib/
├── 📱 main.dart                 # Uygulama giriş noktası
├── 🎨 app.dart                  # MaterialApp + Tema
├── 🧭 router.dart               # GoRouter navigasyon
│
├── 📦 models/                   # Veri modelleri
│   ├── user.dart                # Kullanıcı modeli
│   ├── workspace.dart           # Çalışma alanı
│   ├── item.dart                # Görev/Bug/Fikir
│   ├── presence.dart            # Durum bilgisi
│   └── activity.dart            # Aktivite logu
│
├── 🗄 repositories/             # Firestore CRUD
│   ├── user_repository.dart
│   ├── workspace_repository.dart
│   ├── item_repository.dart
│   ├── presence_repository.dart
│   └── activity_repository.dart
│
├── ⚙️ services/                 # İş mantığı
│   ├── auth_service.dart        # Firebase Auth
│   └── notification_service.dart # FCM
│
├── 🔄 providers/                # Riverpod state
│   ├── auth_providers.dart
│   ├── workspace_providers.dart
│   ├── item_providers.dart
│   ├── presence_providers.dart
│   └── activity_providers.dart
│
└── 🖼 ui/                       # Ekranlar
    ├── onboarding/
    ├── workspace_list/
    ├── board/
    │   └── widgets/
    │       ├── board_section_widget.dart
    │       ├── item_card.dart
    │       ├── item_detail_dialog.dart
    │       └── active_users_section.dart
    └── activity/
```

---

## 🛠 Teknoloji Stack

<div align="center">

| Kategori | Teknoloji |
|----------|-----------|
| **Framework** | Flutter 3.24.5 |
| **Dil** | Dart 3.x |
| **State Management** | Riverpod |
| **Backend** | Firebase (Firestore, Auth, FCM) |
| **Routing** | GoRouter |
| **Cloud Functions** | TypeScript |

</div>

---

## 📋 Roadmap

- [x] **Phase 1**: Temel Altyapı ve Grup Sistemi
- [x] **Phase 2**: Board (Keep Replika) MVP
- [x] **Phase 3**: Presence ve "Active/Şu Anda Kimde?"
- [x] **Phase 4**: Aktivite Log'u ve Basit Bildirim
- [x] **Phase 5**: Fikir Kutusu → Görevleştir
- [ ] **Phase 6**: Gelişmiş Özellikler (Takvim, Hatırlatıcı)
- [ ] **Phase 7**: UI/UX İyileştirmeler

---

## 🤝 Katkıda Bulunma

1. Fork'layın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit'leyin (`git commit -m 'feat: Add amazing feature'`)
4. Push'layın (`git push origin feature/amazing-feature`)
5. Pull Request açın

---

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

<div align="center">

**[⬆ Başa Dön](#-kim-ne-yaptı)**

Made with ❤️ and Flutter

</div>
