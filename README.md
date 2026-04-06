# Proje 2: Veritabanı Yedekleme ve Felaketten Kurtarma Planı (Disaster Recovery)

Bu çalışma, **Ağ Tabanlı Paralel Dağıtım Sistemleri** dersi kapsamında, kritik veritabanı sistemlerinde veri güvenliğini ve sürekliliğini sağlamak amacıyla geliştirilmiştir. Proje, sadece periyodik yedekleme işlemlerini değil, gerçek bir veri kaybı senaryosunda sistemin saniyeler içerisinde nasıl ayağa kaldırılacağını (Point-in-Time Recovery) uygulamalı olarak göstermektedir.

## 🎯 Proje Hedefleri
- Veritabanı yönetiminde **Full Recovery Model** yapısını kurmak.
- **Full**, **Differential** ve **Transaction Log** yedekleme zincirini (Backup Chain) oluşturmak.
- Yanlışlıkla yapılan veri silme işlemlerine karşı **Zamana Dönüş (Point-in-Time)** stratejisini simüle etmek.
- Veritabanı kilitlenmesi (Exclusive Access) gibi gerçek dünya hatalarını yönetmek.

## 📂 Proje Yapısı

```text
├── Rapor/
│   └── Proje_Raporu.md                   # Felaket ve kurtarma adımlarını içeren teknik rapor
├── SQL_Scriptleri/
│   ├── 01_Full_ve_Diff_Yedekler.sql      # Başlangıç yedekleme stratejisi kodları
│   ├── 02_Disaster_ve_Point_In_Time.sql  # Felaket simülasyonu ve kurtarma operasyonu
├── Ekran_Goruntuleri/                    # Veri kaybı ve geri getirme anlarının kanıtları
└── README.md                             # Genel bilgilendirme ve kullanım kılavuzu