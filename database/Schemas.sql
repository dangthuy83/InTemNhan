-- LabelPrint schema
-- Chỉ giữ các object thực sự được dự án sử dụng.

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP VIEW IF EXISTS `v_dropdown_san_pham`;
DROP VIEW IF EXISTS `v_dropdown_loai_giay`;

DROP PROCEDURE IF EXISTS `sp_dong_phien`;

DROP TABLE IF EXISTS `chi_tiet_in_tem`;
DROP TABLE IF EXISTS `lich_su_in_tem`;
DROP TABLE IF EXISTS `phien_in_tem`;
DROP TABLE IF EXISTS `mau_in`;
DROP TABLE IF EXISTS `ca_san_xuat`;
DROP TABLE IF EXISTS `cau_hinh_he_thong`;

CREATE TABLE `ca_san_xuat` (
  `ma_ca` int NOT NULL AUTO_INCREMENT,
  `ten_ca` varchar(50) NOT NULL,
  `thu_tu` tinyint DEFAULT NULL,
  `trang_thai` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ma_ca`),
  UNIQUE KEY `uq_ten_ca` (`ten_ca`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `cau_hinh_he_thong` (
  `ma_cau_hinh` int NOT NULL AUTO_INCREMENT,
  `khoa` varchar(100) NOT NULL,
  `gia_tri` varchar(500) NOT NULL,
  `mo_ta` varchar(255) DEFAULT NULL,
  `ngay_cap_nhat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_cau_hinh`),
  UNIQUE KEY `uq_khoa` (`khoa`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `mau_in` (
  `ma_mau_in` int NOT NULL AUTO_INCREMENT,
  `ten_mau` varchar(100) NOT NULL,
  `kho_giay` enum('letter','a4') NOT NULL DEFAULT 'letter',
  `so_nhan_moi_trang` tinyint NOT NULL DEFAULT '8',
  `cau_hinh_truong` json NOT NULL,
  `la_mac_dinh` tinyint NOT NULL DEFAULT '0',
  `ghi_chu` varchar(255) DEFAULT NULL,
  `ngay_tao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ngay_cap_nhat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_mau_in`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `phien_in_tem` (
  `ma_phien` int NOT NULL AUTO_INCREMENT,
  `ma_mau_in` int NOT NULL,
  `tong_so_nhan` int NOT NULL DEFAULT '0',
  `tong_so_trang` int NOT NULL DEFAULT '0',
  `trang_thai` enum('nhap','da_in','huy') NOT NULL DEFAULT 'nhap',
  `ghi_chu` text,
  `ten_may_tinh` varchar(100) DEFAULT NULL,
  `ngay_tao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ngay_cap_nhat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_phien`),
  KEY `idx_ma_mau_in` (`ma_mau_in`),
  KEY `idx_trang_thai` (`trang_thai`),
  KEY `idx_ngay_tao` (`ngay_tao`),
  CONSTRAINT `fk_phien_mau_in`
    FOREIGN KEY (`ma_mau_in`) REFERENCES `mau_in` (`ma_mau_in`)
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `lich_su_in_tem` (
  `ma_lich_su` int NOT NULL AUTO_INCREMENT,
  `ma_phien` int NOT NULL,
  `stt` int NOT NULL,
  `ten_san_pham` varchar(255) NOT NULL,
  `ma_code` varchar(50) DEFAULT NULL,
  `phieu_san_pham` varchar(80) NOT NULL,
  `ten_loai_giay` varchar(150) NOT NULL,
  `so_luong_psp` int unsigned DEFAULT NULL,
  `so_luong_san_pham` int NOT NULL,
  `so_luong_nhan` int NOT NULL,
  `ten_ca` varchar(50) DEFAULT NULL,
  `ngay_san_xuat` date DEFAULT NULL,
  `nguoi_kiem` varchar(100) DEFAULT NULL,
  `nguoi_dong_goi` varchar(100) DEFAULT NULL,
  `ghi_chu` varchar(500) DEFAULT NULL,
  `ten_mau_in` varchar(100) DEFAULT NULL,
  `ma_mau_in` int DEFAULT NULL,
  `kho_giay` varchar(10) DEFAULT NULL,
  `ten_may_tinh` varchar(100) DEFAULT NULL,
  `so_lan_in_lai` int NOT NULL DEFAULT '0',
  `thoi_gian_tao_tem` datetime NOT NULL,
  PRIMARY KEY (`ma_lich_su`),
  UNIQUE KEY `uq_ls_phien_stt` (`ma_phien`, `stt`),
  KEY `idx_ls_ma_phien` (`ma_phien`),
  KEY `idx_ls_ma_code` (`ma_code`),
  KEY `idx_ls_ten_san_pham` (`ten_san_pham`),
  KEY `idx_ls_phieu_san_pham` (`phieu_san_pham`),
  KEY `idx_ls_ngay_san_xuat` (`ngay_san_xuat`),
  KEY `idx_ls_thoi_gian_tao` (`thoi_gian_tao_tem`),
  CONSTRAINT `fk_lichsu_phien`
    FOREIGN KEY (`ma_phien`) REFERENCES `phien_in_tem` (`ma_phien`)
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `chi_tiet_in_tem` (
  `ma_chi_tiet` int NOT NULL AUTO_INCREMENT,
  `ma_phien` int NOT NULL,
  `stt` int NOT NULL,
  `ten_san_pham` varchar(255) NOT NULL,
  `ma_code` varchar(50) DEFAULT NULL,
  `so_phieu` varchar(20) NOT NULL,
  `nam_phieu` year NOT NULL,
  `chi_nhanh` varchar(30) NOT NULL,
  `ten_loai_giay` varchar(150) NOT NULL,
  `so_luong_psp` int unsigned DEFAULT NULL,
  `so_luong_san_pham` int NOT NULL,
  `so_luong_nhan` int NOT NULL,
  `so_trang` int NOT NULL,
  `ma_ca` int DEFAULT NULL,
  `ngay_san_xuat` date DEFAULT NULL,
  `nguoi_kiem` varchar(100) DEFAULT NULL,
  `nguoi_dong_goi` varchar(100) DEFAULT NULL,
  `ghi_chu` varchar(500) DEFAULT NULL,
  `loai_tao` enum('moi','copy') NOT NULL DEFAULT 'moi',
  `ma_lich_su_goc` int DEFAULT NULL,
  `ngay_tao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_chi_tiet`),
  UNIQUE KEY `uq_phien_stt` (`ma_phien`, `stt`),
  KEY `idx_ma_code` (`ma_code`),
  KEY `idx_ten_san_pham` (`ten_san_pham`),
  KEY `idx_nam_phieu` (`nam_phieu`),
  KEY `idx_ma_ca` (`ma_ca`),
  KEY `idx_ma_lich_su_goc` (`ma_lich_su_goc`),
  CONSTRAINT `fk_chitiet_ca`
    FOREIGN KEY (`ma_ca`) REFERENCES `ca_san_xuat` (`ma_ca`)
    ON DELETE SET NULL,
  CONSTRAINT `fk_chitiet_lichsu`
    FOREIGN KEY (`ma_lich_su_goc`) REFERENCES `lich_su_in_tem` (`ma_lich_su`)
    ON DELETE SET NULL,
  CONSTRAINT `fk_chitiet_phien`
    FOREIGN KEY (`ma_phien`) REFERENCES `phien_in_tem` (`ma_phien`)
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE OR REPLACE VIEW `v_dropdown_san_pham` AS
SELECT DISTINCT
  `ten_san_pham`,
  `ma_code`
FROM `lich_su_in_tem`
ORDER BY `ten_san_pham`;

CREATE OR REPLACE VIEW `v_dropdown_loai_giay` AS
SELECT DISTINCT
  `ten_loai_giay`
FROM `lich_su_in_tem`
ORDER BY `ten_loai_giay`;

DELIMITER $$
CREATE PROCEDURE `sp_dong_phien`(
    IN p_ma_phien INT,
    IN p_ten_may VARCHAR(100)
)
BEGIN
    DECLARE v_tong_nhan  INT DEFAULT 0;
    DECLARE v_tong_trang INT DEFAULT 0;
    DECLARE v_ten_mau    VARCHAR(100);
    DECLARE v_kho_giay   VARCHAR(10);
    DECLARE v_ma_mau_in  INT;

    SELECT
        COALESCE(SUM(so_luong_nhan), 0),
        COALESCE(SUM(so_trang), 0)
    INTO v_tong_nhan, v_tong_trang
    FROM chi_tiet_in_tem
    WHERE ma_phien = p_ma_phien;

    SELECT mi.ten_mau, mi.kho_giay, mi.ma_mau_in
    INTO v_ten_mau, v_kho_giay, v_ma_mau_in
    FROM phien_in_tem p
    JOIN mau_in mi ON p.ma_mau_in = mi.ma_mau_in
    WHERE p.ma_phien = p_ma_phien;

    UPDATE phien_in_tem
    SET tong_so_nhan  = v_tong_nhan,
        tong_so_trang = v_tong_trang,
        trang_thai    = 'da_in',
        ten_may_tinh  = p_ten_may
    WHERE ma_phien = p_ma_phien;

    INSERT INTO lich_su_in_tem (
        ma_phien, stt, ten_san_pham, ma_code, phieu_san_pham,
        ten_loai_giay, so_luong_san_pham, so_luong_nhan,
        so_luong_psp, ghi_chu,
        ten_ca, ngay_san_xuat, nguoi_kiem, nguoi_dong_goi,
        ten_mau_in, kho_giay, ma_mau_in, ten_may_tinh, thoi_gian_tao_tem
    )
    SELECT
        ct.ma_phien,
        ct.stt,
        ct.ten_san_pham,
        ct.ma_code,
        CONCAT(ct.so_phieu, '/', ct.nam_phieu, '/', ct.chi_nhanh),
        ct.ten_loai_giay,
        ct.so_luong_san_pham,
        ct.so_luong_nhan,
        ct.so_luong_psp,
        ct.ghi_chu,
        ca.ten_ca,
        ct.ngay_san_xuat,
        ct.nguoi_kiem,
        ct.nguoi_dong_goi,
        v_ten_mau,
        v_kho_giay,
        v_ma_mau_in,
        p_ten_may,
        p.ngay_tao
    FROM chi_tiet_in_tem ct
    JOIN phien_in_tem p ON ct.ma_phien = p.ma_phien
    LEFT JOIN ca_san_xuat ca ON ct.ma_ca = ca.ma_ca
    WHERE ct.ma_phien = p_ma_phien
      AND NOT EXISTS (
          SELECT 1
          FROM lich_su_in_tem ls
          WHERE ls.ma_phien = p_ma_phien
      );

    SELECT CONCAT(
        'Phien #', p_ma_phien, ' da dong. ',
        'Nhan: ', v_tong_nhan, ' | ',
        'Trang: ', v_tong_trang
    ) AS ket_qua;
END$$
DELIMITER ;

SET FOREIGN_KEY_CHECKS = 1;
