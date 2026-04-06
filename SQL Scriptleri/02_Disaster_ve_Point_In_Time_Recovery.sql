USE DersDB;
GO

-- 1. Çok kritik bir veriyi sisteme giriyoruz.
INSERT INTO dbo.KritikFinansVerileri (IslemAdi, Miktar) VALUES ('Gizli_Yatirim_Bütcesi', 5000000.00);
GO

-- 2. ŞU ANKİ SAATİ EKRANA YAZDIRIYORUZ (BUNU VİDEODA GÖSTER VE KOPYALA!)
SELECT GETDATE() AS 'Kurtarma_Noktamiz_Zaman_Makinesi';
GO

-- (Burada kasten 5 saniye bekletiyoruz ki araya zaman girsin)
WAITFOR DELAY '00:00:05';
GO

-- 3. FELAKET ANI! (WHERE şartı koymayı unutarak tüm verileri siliyoruz)
DELETE FROM dbo.KritikFinansVerileri;
GO

-- 4. Kontrol ediyoruz... Eyvah, milyon dolarlık bütçe dahil her şey gitmiş!
SELECT * FROM dbo.KritikFinansVerileri;
GO

USE master;
GO

-- 1. Veritabanının son anını garantiye almak için Tail-Log Backup alıyoruz.
-- Bu işlem veritabanını RESTORING moduna sokar ve dışarıdan erişimi keser.
BACKUP LOG DersDB
TO DISK = 'C:\Temp\DersDB_TailLog.trn'
WITH NORECOVERY, INIT;
GO

-- 2. ZAMAN YOLCULUĞU BAŞLIYOR (Sırasıyla geri yükleme yapıyoruz)
-- Önce FULL yedek (NO RECOVERY ile, çünkü üstüne log işleyeceğiz)
RESTORE DATABASE DersDB
FROM DISK = 'C:\Temp\DersDB_Full.bak'
WITH NORECOVERY, REPLACE;
GO

-- Sonra DIFF (Fark) yedeği
RESTORE DATABASE DersDB
FROM DISK = 'C:\Temp\DersDB_Diff.bak'
WITH NORECOVERY;
GO

-- 3. KRİTİK NOKTA: Tail-Log yedeğini dönüyoruz ama tam olarak sildiğimiz anın 1 saniye öncesine!
-- ASAGIDAKI TARIH/SAATI KENDİ KOPYALADIĞIN SAATLE DEĞİŞTİR
RESTORE LOG DersDB
FROM DISK = 'C:\Temp\DersDB_TailLog.trn'
WITH RECOVERY, STOPAT = '2026-04-06 20:38:15.123'; 
GO

-- 4. MUTLU SON: Tablomuz ve milyon dolarlık verimiz yerinde duruyor mu?
USE DersDB;
GO
SELECT * FROM dbo.KritikFinansVerileri;
GO