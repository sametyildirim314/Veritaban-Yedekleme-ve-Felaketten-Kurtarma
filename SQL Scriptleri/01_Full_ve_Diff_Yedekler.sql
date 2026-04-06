USE master;
GO

-------------------------------------------------------
-- 1. KURTARMA MODELİ (RECOVERY MODEL) AYARI
-------------------------------------------------------
-- Veritabanını 'Full' kurtarma modeline alıyoruz. 
-- Bu, veritabanında yapılan her hareketin saniye saniye loglanmasını sağlar.
ALTER DATABASE DersDB SET RECOVERY FULL;
GO

-------------------------------------------------------
-- 2. FULL BACKUP (TAM YEDEK)
-------------------------------------------------------
-- Sistemin sıfır noktası (Baseline). Tüm veritabanının yedeğini alıyoruz.
BACKUP DATABASE DersDB 
TO DISK = 'C:\Temp\DersDB_Full.bak' 
WITH FORMAT, INIT, 
NAME = 'DersDB Tam Yedek', STATS = 10;
GO

-------------------------------------------------------
-- 3. TEST İÇİN YENİ BİR TABLO VE VERİ EKLİYORUZ
-------------------------------------------------------
USE DersDB;
GO
CREATE TABLE dbo.KritikFinansVerileri (
    ID INT IDENTITY(1,1),
    IslemAdi NVARCHAR(50),
    Miktar DECIMAL(18,2)
);
INSERT INTO dbo.KritikFinansVerileri (IslemAdi, Miktar) VALUES ('Q1_Gelir', 500000.00);
GO

-------------------------------------------------------
-- 4. DIFFERENTIAL BACKUP (FARK YEDEĞİ)
-------------------------------------------------------
-- Sadece Full Backup'tan SONRA değişen kısımların (yani üstteki tablonun) yedeğini alırız.
-- Boyutu küçüktür, hızlı alınır.
BACKUP DATABASE DersDB 
TO DISK = 'C:\Temp\DersDB_Diff.bak' 
WITH DIFFERENTIAL, INIT, 
NAME = 'DersDB Fark Yedeği', STATS = 10;
GO