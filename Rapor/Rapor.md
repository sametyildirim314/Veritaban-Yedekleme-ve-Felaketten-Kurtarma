# Proje 2: Veritabanı Yedekleme ve Felaketten Kurtarma Planı (Disaster Recovery) Raporu

## Proje Özeti ve Amacı
Bu proje, kurumsal bir veritabanı sisteminde oluşabilecek veri kayıplarına karşı "Yedekleme ve Felaketten Kurtarma (Backup & Disaster Recovery)" stratejilerinin uygulanmasını amaçlamaktadır. Sadece standart yedekleme işlemleriyle kalınmamış; sisteme kritik verilerin girildiği, ardından insan hatasıyla (yanlış `DELETE` kullanımı) verilerin silindiği bir felaket senaryosu simüle edilmiştir. Sorunun çözümü için Transaction Log yedekleri kullanılarak "Zamana Dönüş (Point-in-Time Recovery)" işlemi gerçekleştirilmiş ve veri kaybı sıfıra indirilerek sistem başarıyla kurtarılmıştır. İşlemler `DersDB` veritabanı üzerinde gerçekleştirilmiştir.

---

## Bölüm 1: Kurtarma Modeli ve Temel Yedekleme Stratejisi
Veritabanında "Zamana Dönüş" yapılabilmesi için sistemin buna uygun konfigüre edilmesi ve temel yedekleme zincirinin (Backup Chain) oluşturulması sağlanmıştır.

* **Kurtarma Modeli (Recovery Model):** Veritabanında yapılan her bir işlemin saniye saniye günlüklere (log) yazılabilmesi için `DersDB` veritabanının kurtarma modeli `FULL` olarak ayarlanmıştır.
* **Tam Yedek (Full Backup):** Sistemin sıfır noktasını (Baseline) oluşturmak amacıyla veritabanının `DersDB_Full.bak` adıyla tam yedeği alınmıştır.
* **Fark Yedeği (Differential Backup):** Veritabanına `KritikFinansVerileri` adında yeni bir tablo eklenmiş ve içine ilk veriler girilmiştir. Tam yedekten sonra değişen bu yapıyı kaydetmek için `DersDB_Diff.bak` adıyla bir fark yedeği alınarak yedekleme zinciri desteklenmiştir.

## Bölüm 2: Felaket Senaryosu Simülasyonu
Sistemin kurtarma yeteneklerini test etmek amacıyla bir felaket senaryosu (Disaster) kurgulanmıştır.

* **Kritik Veri Girişi ve Zamanın Kaydedilmesi:** `KritikFinansVerileri` tablosuna milyon dolarlık yeni bir bütçe verisi eklenmiştir. İşlemin yapıldığı anın zaman damgası (`GETDATE()`), kurtarma hedefi olarak belirlenmek üzere sisteme yazdırılmış ve not alınmıştır.
* **Felaket Anı (İnsan Hatası):** Sistemde 5 saniyelik bir gecikme (delay) yaratıldıktan sonra, `WHERE` koşulu unutulmuş bir `DELETE` komutu çalıştırılarak tablodaki tüm veriler kasten silinmiştir. Yapılan `SELECT` sorgusu ile tablonun tamamen boşaldığı ve kritik verinin kaybolduğu teyit edilmiştir.

## Bölüm 3: Zamana Dönüş ve Kurtarma Operasyonu (Point-in-Time Recovery)
Verilerin silinme anından tam 1 saniye öncesine dönerek sistemi kurtarmak için "Restore" operasyonu başlatılmıştır.

* **Hata Yönetimi ve Kilit Çözümü (Troubleshooting):** Kurtarma işlemi başlatılırken SSMS üzerinde açık kalan diğer bağlantılar nedeniyle `İleti 3101: Exclusive access could not be obtained because the database is in use` hatası alınmıştır. Bu gerçek dünya problemini çözmek için veritabanı acil durum müdahalesiyle `SINGLE_USER WITH ROLLBACK IMMEDIATE` moduna alınarak tüm açık kullanıcı bağlantıları zorla koparılmış ve veritabanı kilitleri açılmıştır.
* **Tail-Log Backup:** Veritabanının silinme anındaki son durumunu garantiye almak için `NORECOVERY` parametresi ile `DersDB_TailLog.trn` adında bir son işlem günlüğü yedeği alınmıştır. Bu işlem veritabanını dışarıdan erişime kapatarak `RESTORING` moduna sokmuştur.
* **Restore Zincirinin İşletilmesi:**
  1. Öncelikle `DersDB_Full.bak` (Tam Yedek) `NORECOVERY` moduyla geri yüklenmiştir.
  2. Üzerine `DersDB_Diff.bak` (Fark Yedeği) yine `NORECOVERY` moduyla yüklenmiştir.
  3. **Kritik Adım:** Son olarak Tail-Log yedeği geri yüklenirken `STOPAT` parametresi kullanılarak, hedef zaman çizgisi silinme anının tam öncesine (not alınan saat ve milisaniyeye) ayarlanmış ve veritabanı `RECOVERY` moduyla canlandırılmıştır.
* **Sonuç:** Kurtarma işlemi tamamlandıktan sonra veritabanı tekrar `MULTI_USER` moduna alınarak genel erişime açılmıştır. Yapılan `SELECT` sorgusu sonucunda, yanlışlıkla silinen milyon dolarlık bütçe verisinin eksiksiz bir şekilde geri geldiği kanıtlanmıştır.