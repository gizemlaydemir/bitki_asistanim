🌱 Bitki Asistanım

Bitki Asistanım, kullanıcıların bitkilerini daha düzenli, bilinçli ve kolay şekilde takip edebilmesi için geliştirilmiş bir Flutter tabanlı mobil uygulamadır.
Uygulama; bitki bilgilerini yerel veritabanında saklar, sulama zamanlarını planlar ve yapay zekâ desteğiyle bitki bakımında rehberlik eder.

🎯 Amaç ve Senaryo
❓ Bu uygulama kimin işine yarar?

Bu uygulama;

Evinde, ofisinde veya bahçesinde bitki yetiştiren,

Birden fazla bitkinin bakımını takip etmekte zorlanan,

Sulama zamanlarını unutan,

Bitki sorunlarında hızlı çözüm arayan

kullanıcılar için geliştirilmiştir.

❓ Hangi problemi çözer?

Bitki sahiplerinin en sık yaşadığı problemler:

Bitkilerin ne zaman sulanacağının unutulması

Bakım süreçlerinin düzensiz olması

Yaprak sararması, lekelenme gibi sorunlarda ne yapılacağının bilinmemesi

Bitki Asistanım;

Bitkilere ait bilgileri veritabanında düzenli şekilde saklayarak

Sulama zamanlarını otomatik hesaplayarak

Yapay zekâ destekli öneriler sunarak

bu problemleri ortadan kaldırır.

❓ Nerede ve nasıl kullanılır?

Uygulama, mobil cihazlar üzerinden günlük hayatta kolayca kullanılabilir.

Kullanıcı:

Bitkilerini uygulamaya ekler

Sulama sıklığını belirler

Günlük ve takvim ekranlarından bakım planını takip eder

Bitkide bir sorun olduğunda AI Asistan’dan destek alır

Bu sayede bitki bakımı daha düzenli ve bilinçli hale gelir.

🤖 Yapay Zekâ Desteği

Uygulamada yer alan Bitki Asistanı (AI) bölümü sayesinde kullanıcı:

Bitki adını (isteğe bağlı),

Yaşadığı problemi (ör. yaprak sararması, lekelenme)

yazarak yapay zekâ destekli bakım önerileri alabilir.

Teknik yapı:

Flutter frontend

Node.js tabanlı backend

OpenAI API entegrasyonu

Günlük kullanım limiti ile kontrollü AI erişimi

Not: Yapay zekâ kısmı danışmanlık amaçlıdır, kesin tanı iddiası içermez.

🗄️ Veritabanı Yapısı

Uygulamada yerel veritabanı (SQLite) kullanılmıştır.

Veritabanı üzerinden:

Bitki ekleme

Bitki listeleme

Sulama bilgilerini saklama

Son sulama tarihine göre hesaplama

işlemleri yapılmaktadır.

Bu sayede kullanıcı verileri uygulama kapatılsa bile kaybolmaz.

🛠️ Kullanılan Teknolojiler

Flutter

Dart

SQLite (sqflite)

Material Design

Node.js (AI backend)

OpenAI API

VS Code / Android Studio

✨ Uygulama Özellikleri

Bitki ekleme ve listeleme

Sulama sıklığı belirleme

Günlük ve takvim görünümü

Bildirim sistemi

Yapay zekâ destekli bitki danışmanı

Kullanıcı dostu ve sade arayüz

🖼️ Uygulama Ekran Görüntüleri

Aşağıya 9 adet ekran görüntüsünü ekleyebilirsin:

![Ekran 1](indirilenler/homepage.png)
![Ekran 2](indirilenler/addplantpage.png)
![Ekran 3](indirilenler/plantdate.png)
![Ekran 4](indirilenler/todaypage.png)
![Ekran 5](indirilenler/calenderpage.png)
![Ekran 6](indirilenler/donatepage.png)
![Ekran 7](indirilenler/settingpage.png)
![Ekran 8](indirilenler/notespage.png)
![Ekran 9](indirilenler/aipage.png)

🎥 YouTube Tanıtım Videosu

📺 Proje Tanıtım Videosu:
👉 https://www.youtube.com/VIDEO_LINKİNİ_BURAYA_YAZ

Videoda:

Uygulamanın amacı

Ekranların tanıtımı

Veritabanı işlemleri (ekleme, listeleme)

Yapay zekâ desteği

detaylı şekilde anlatılmıştır.

⚙️ Kurulum ve Çalıştırma
git clone https://github.com/gizemlaydemir/bitki_asistanim.git
cd bitki_asistanim
flutter pub get
flutter run

👩‍💻 Geliştirici

Gizem Aydemir
Bursa Uludağ Üniversitesi
Yönetim Bilişim Sistemleri
