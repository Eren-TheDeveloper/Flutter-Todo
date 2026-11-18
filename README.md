<div align="center">

<img src="docs/readme-banner.svg" alt="Görevlerim — Günün daha sade, görevlerin daha düzenli." width="100%" />

<br />

# Küçük adımlar. Tamamlanan görevler. 💜

Günlük işlerini bir araya getir, önceliğine odaklan ve ilerlemeni takip et.<br />
**Türkçe arayüz · Mor tema · Cihazda kayıt**

<p>
  <img src="https://img.shields.io/badge/Flutter-3.38.6-02569B?style=flat-square&amp;logo=flutter&amp;logoColor=white" alt="Flutter 3.38.6" />
  <img src="https://img.shields.io/badge/Dart-3.10.7-0175C2?style=flat-square&amp;logo=dart&amp;logoColor=white" alt="Dart 3.10.7" />
  <img src="https://img.shields.io/badge/Material-3-6750A4?style=flat-square&amp;logo=materialdesign&amp;logoColor=white" alt="Material 3" />
  <img src="https://img.shields.io/badge/Arayüz-Türkçe-8B5CF6?style=flat-square" alt="Türkçe arayüz" />
</p>

[Özellikler](#-görevlerine-yer-aç) · [Kurulum](#-hemen-başla) · [Kullanım](#-akışın-bu-kadar-basit) · [Geliştirme](#-geliştirme-ve-kontroller)

</div>

---

## ✨ Görevlerine yer aç

**Görevlerim**, Flutter ile geliştirilmiş sade bir yapılacaklar listesi uygulaması. Görevlerini ekle, tamamladıklarını işaretle ve kalanları tek bakışta gör.

| | Özellik | Sana ne sağlar? |
| :---: | :--- | :--- |
| 📝 | **Ekle ve düzenle** | Yeni görevler oluştur, planın değiştiğinde başlıklarını güncelle. |
| ✅ | **Tamamla ve takip et** | Biten görevleri işaretle; toplam, tamamlanan ve bekleyen sayılarını gör. |
| 🔎 | **Duruma göre filtrele** | Tümü, Bekleyen ve Tamamlanan görünümleri arasında geçiş yap. |
| ↩️ | **Sil ve geri al** | Yanlışlıkla sildiğin görevi sırası ve tamamlanma durumuyla geri getir. |
| 💾 | **Kaldığın yerden devam et** | Uygulamayı yeniden açtığında cihazına kaydedilen görevlerini bul. |
| 🎨 | **Rahat bir görünüm** | Material 3 bileşenleri, mor tema ve ekran genişliğine uyarlanan liste. |

> **Ayrıntılar da düşünülmüş:** Boş görevler engellenir, başlıklar 200 karakterle sınırlanır ve uzun metinler kart içinde satırlara bölünür. Kayıt hataları bildirilir; yükleme başarısızsa mevcut kayıtların üzerine yazılmaz.

## 🚀 Hemen başla

**Doğrulanan ortam:** Flutter `3.38.6` · Dart `3.10.7`

Projeyi bilgisayarına aldıktan sonra kök klasörde çalıştır:

```sh
flutter pub get
flutter run
```

Web üzerinde çalıştırmak için:

```sh
flutter run -d chrome
```

<details>
<summary><strong>Windows kurulum notları</strong></summary>

Windows'ta eklentiler için sembolik bağlantı desteği gerekir. `flutter pub get` bir Developer Mode uyarısı verirse Windows Ayarları'ndan **Geliştirici Modu**'nu aç.

Flutter PATH içinde değilse kurulum klasöründeki `bin/flutter.bat` dosyasını kullan.

Bu ortamda Türkçe karakter içeren çıktı yolu, web shader derleyicisinde dosya yazma hatasına yol açtı. ASCII karakterli bir çıktı yolu ile derleme başarılı oldu:

```sh
flutter build web --output C:/Users/Public/Documents/gorevlerim-web
```

</details>

## 🧭 Akışın bu kadar basit

1. **Görev ekle** düğmesine dokun, başlığını yaz ve kaydet.
2. Bitirdiğin görevin **kutucuğunu işaretle**.
3. **Bekleyen** veya **Tamamlanan** filtresiyle görmek istediklerine odaklan.
4. Görev menüsünden **Düzenle** ya da **Sil** seçeneğini kullan.
5. Silme işlemini geri çevirmek için bildirimdeki **Geri al** düğmesine dokun.

## 🛠 Geliştirme ve kontroller

```sh
# Biçimlendirmeyi doğrula
dart format --output=none --set-exit-if-changed lib test

# Statik analiz
flutter analyze

# Testler
flutter test

# Web çıktısı
flutter build web
```

**12 test**; form doğrulama, iptal, filtreleme, düzenleme, silme ve geri alma, kayıt/yükleme hataları, eşzamanlı işlem koruması, dar ekran ve kayıt verilerinin doğrulanmasını kapsar.

[GitHub Actions iş akışı](.github/workflows/flutter.yml), push ve pull request işlemlerinde biçimlendirme, analiz, test ve web derlemesini çalıştıracak şekilde yapılandırılmıştır. Yerelde doğrulanan Flutter sürümünü kullanır.

<details>
<summary><strong>📁 Proje yapısını keşfet</strong></summary>

```text
lib/
├── main.dart          # Uygulama başlangıcı ve tema
├── homepage.dart      # Görev listesi, filtreler ve işlemler
├── task.dart          # Tip güvenli görev modeli
├── task_store.dart    # Yerel kayıt katmanı
├── alertbox.dart      # Ekleme ve düzenleme formu
├── todolist.dart      # Görev kartı
└── buton.dart         # Ortak metin düğmesi

test/
├── app_test.dart         # Arayüz ve kullanıcı akışları
└── task_store_test.dart  # Kayıt ve veri doğrulama
```

Kayıt katmanı `TaskStore` arayüzüyle ayrılır; testlerde bellek içi bir uygulamayla değiştirilebilir.

</details>

## 💾 Görevlerin nerede saklanıyor?

Görevler, [shared_preferences](https://pub.dev/packages/shared_preferences) paketinin `SharedPreferencesAsync` API'siyle cihazda saklanır. Kayıt biçimi JSON, anahtar adı `tasks.v1` şeklindedir.

- Hesap oluşturma gerekmez; bulut senkronizasyonu bulunmaz.
- Uygulama verilerini veya tarayıcının site verilerini temizlemek görevleri siler.
- Bozuk kayıtlar otomatik silinmez; yükleme hatası gösterilir.

<details>
<summary><strong>📦 GitHub'a ilk gönderim</strong></summary>

GitHub'da boş bir depo oluştur; otomatik README, lisans veya `.gitignore` ekleme. Yerel `main` dalındaki commit'i göndermek için adresi kendi deponla değiştir:

```sh
git remote add origin https://github.com/KULLANICI/DEPO.git
git push -u origin main
```

Kimlik doğrulaması bilgisayarındaki Git Credential Manager veya SSH kurulumuyla yapılır. Erişim belirteçlerini proje dosyalarına yazma.

**Depoya dahil:** Kaynak kodu, platform proje dosyaları, `.metadata` ve `pubspec.lock`.<br />
**Dışlananlar:** Derleme çıktıları, yerel SDK yolları, IDE ayarları, `.env` dosyaları ve imzalama anahtarları.

</details>

---

<div align="center">
  <strong>Bugünün bir görevini daha tamamla. ✓</strong>
</div>
