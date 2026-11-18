# Görevlerim

Mor temalı, Türkçe Flutter görev yönetimi uygulaması.

## Özellikler

- Görev ekleme, düzenleme, tamamlama ve silme.
- Silinen görevi sırası ve tamamlanma durumuyla geri alma.
- Tümü, bekleyen ve tamamlanan filtreleri ile görev sayıları.
- Uygulama yeniden açıldığında görevleri cihazdan yükleme.
- Boş giriş kontrolü, 200 karakter sınırı ve uzun metin desteği.
- Yükleme ve kayıt hatası bildirimi; yükleme başarısızsa kaydın üzerine yazılmaz.

## Çalıştırma

Proje Flutter **3.38.6** / Dart **3.10.7** ile doğrulandı. GitHub Actions aynı
Flutter sürümünü kullanır.

```sh
flutter pub get
flutter run
```

Windows'ta eklentiler için sembolik bağlantı desteği gerekir. `flutter pub get`
Developer Mode uyarısı verirse Windows Ayarları'ndan Geliştirici Modu'nu açın.
Flutter PATH içinde değilse kurulumdaki `bin/flutter.bat` dosyasını kullanın.

## Kontroller

```sh
flutter analyze
flutter test
flutter build web
```

Bu Windows ortamında varsayılan çıktı yolundaki Türkçe karakterler shader
derleyicisinde dosya yazma hatasına yol açtı. ASCII karakterli bir çıktı yolu
ile derleme başarılı oldu:

```sh
flutter build web --output C:/Users/Public/Documents/gorevlerim-web
```

Testler form doğrulama, iptal, filtreleme, düzenleme, silme/geri alma,
kayıt ve yükleme hataları, eşzamanlı işlem koruması, dar ekran ve kayıt
verilerinin doğrulanmasını kapsar.

## Yapı ve veri

`lib/task.dart` görev modelini, `lib/task_store.dart` yerel kayıt katmanını,
`lib/homepage.dart` liste ve işlemleri içerir. Kayıt katmanı testlerde bellek
içi bir uygulama ile değiştirilebilir.

Görevler [shared_preferences](https://pub.dev/packages/shared_preferences)
paketinin `SharedPreferencesAsync` API'si ile `tasks.v1` anahtarında JSON olarak saklanır.
Hesap veya bulut senkronizasyonu yoktur. Uygulama verilerini ya da tarayıcının
site verilerini temizlemek görevleri siler. Bozuk kayıt otomatik silinmez;
yükleme hatası gösterilir.

## GitHub'a gönderme

Yerel depo `main` dalında hazırlandıktan ve ilk commit oluşturulduktan sonra,
GitHub'da boş bir depo oluşturun. Otomatik README, lisans veya `.gitignore`
eklemeyin. Aşağıdaki URL'yi kendi depo adresinizle değiştirin:

```sh
git remote add origin https://github.com/KULLANICI/DEPO.git
git push -u origin main
```

GitHub kimlik doğrulaması bilgisayarınızdaki Git Credential Manager veya SSH
kurulumunuz üzerinden yapılır. Erişim belirteçlerini dosyalara yazmayın.

Kaynak kodu, platform proje dosyaları, `.metadata` ve uygulamanın bağımlılık
sürümlerini sabitleyen `pubspec.lock` depoya dahildir. Derleme çıktıları,
SDK yolları, IDE ayarları, `.env` dosyaları ve imzalama anahtarları dışlanır.

Push ve pull request işlemlerinde `.github/workflows/flutter.yml` biçimlendirme,
analiz, test ve web derlemesini çalıştırır. İş akışı
[checkout](https://github.com/actions/checkout) ve
[flutter-action](https://github.com/subosito/flutter-action) kullanır.
