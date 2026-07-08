-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: payroll_db
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ca_san_xuat`
--

DROP TABLE IF EXISTS `ca_san_xuat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ca_san_xuat` (
  `ma_ca` int NOT NULL AUTO_INCREMENT COMMENT 'Khóa chính',
  `ten_ca` varchar(50) NOT NULL COMMENT 'VD: Ca 1, Ca 2, Ca 3',
  `thu_tu` tinyint DEFAULT NULL COMMENT 'Thứ tự hiển thị',
  `trang_thai` tinyint NOT NULL DEFAULT '1' COMMENT '1=Đang dùng | 0=Ngừng',
  PRIMARY KEY (`ma_ca`),
  UNIQUE KEY `uq_ten_ca` (`ten_ca`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Danh mục ca sản xuất';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cau_hinh_he_thong`
--

DROP TABLE IF EXISTS `cau_hinh_he_thong`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cau_hinh_he_thong` (
  `ma_cau_hinh` int NOT NULL AUTO_INCREMENT,
  `khoa` varchar(100) NOT NULL COMMENT 'Tên cấu hình (key)',
  `gia_tri` varchar(500) NOT NULL COMMENT 'Giá trị cấu hình (value)',
  `mo_ta` varchar(255) DEFAULT NULL,
  `ngay_cap_nhat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_cau_hinh`),
  UNIQUE KEY `uq_khoa` (`khoa`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Cấu hình hệ thống — đọc bởi ASP.NET Core khi startup';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chi_tiet_in_tem`
--

DROP TABLE IF EXISTS `chi_tiet_in_tem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chi_tiet_in_tem` (
  `ma_chi_tiet` int NOT NULL AUTO_INCREMENT COMMENT 'Khóa chính',
  `ma_phien` int NOT NULL COMMENT 'FK → phien_in_tem',
  `stt` int NOT NULL COMMENT 'Số thứ tự trong phiên (tự sinh)',
  `ten_san_pham` varchar(255) NOT NULL COMMENT 'Tên sản phẩm',
  `ma_code` varchar(50) DEFAULT NULL,
  `so_phieu` varchar(20) NOT NULL COMMENT 'Số phiếu — VD: 1501',
  `nam_phieu` year NOT NULL COMMENT 'Năm phiếu — VD: 2026',
  `chi_nhanh` varchar(30) NOT NULL COMMENT 'Chi nhánh — VD: HNI-OFF',
  `ten_loai_giay` varchar(150) NOT NULL COMMENT 'VD: Duplex DH 300 gsm',
  `so_luong_psp` int unsigned DEFAULT NULL,
  `so_luong_san_pham` int NOT NULL COMMENT 'Số lượng sản phẩm trong lô (VD: 480 hộp)',
  `so_luong_nhan` int NOT NULL COMMENT 'Số nhãn cần in',
  `so_trang` int NOT NULL COMMENT 'CEIL(so_luong_nhan / so_nhan_moi_trang)',
  `ma_ca` int DEFAULT NULL COMMENT 'FK → ca_san_xuat',
  `ngay_san_xuat` date DEFAULT NULL,
  `nguoi_kiem` varchar(100) DEFAULT NULL COMMENT 'Người kiểm (nhập tự do)',
  `nguoi_dong_goi` varchar(100) DEFAULT NULL COMMENT 'Người đóng gói (nhập tự do)',
  `ghi_chu` varchar(500) DEFAULT NULL,
  `loai_tao` enum('moi','copy') NOT NULL DEFAULT 'moi' COMMENT 'moi=nhập mới | copy=copy từ lịch sử',
  `ma_lich_su_goc` int DEFAULT NULL COMMENT 'FK → lich_su_in_tem | NULL=mới | copy=id nguồn',
  `ngay_tao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_chi_tiet`),
  UNIQUE KEY `uq_phien_stt` (`ma_phien`,`stt`),
  KEY `idx_ma_code` (`ma_code`),
  KEY `idx_ten_san_pham` (`ten_san_pham`),
  KEY `idx_nam_phieu` (`nam_phieu`),
  KEY `idx_ma_ca` (`ma_ca`),
  KEY `idx_ma_lich_su_goc` (`ma_lich_su_goc`),
  CONSTRAINT `fk_chitiet_ca` FOREIGN KEY (`ma_ca`) REFERENCES `ca_san_xuat` (`ma_ca`) ON DELETE SET NULL,
  CONSTRAINT `fk_chitiet_lichsu` FOREIGN KEY (`ma_lich_su_goc`) REFERENCES `lich_su_in_tem` (`ma_lich_su`) ON DELETE SET NULL,
  CONSTRAINT `fk_chitiet_phien` FOREIGN KEY (`ma_phien`) REFERENCES `phien_in_tem` (`ma_phien`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=228 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Chi tiết nhãn trong phiên — 1 dòng = 1 cấu hình (chưa expanded)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lich_su_in_tem`
--

DROP TABLE IF EXISTS `lich_su_in_tem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lich_su_in_tem` (
  `ma_lich_su` int NOT NULL AUTO_INCREMENT COMMENT 'Khóa chính',
  `ma_phien` int NOT NULL COMMENT 'FK → phien_in_tem',
  `stt` int NOT NULL,
  `ten_san_pham` varchar(255) NOT NULL COMMENT 'Tên sản phẩm',
  `ma_code` varchar(50) DEFAULT NULL,
  `phieu_san_pham` varchar(80) NOT NULL COMMENT 'VD: 1501/2026/HNI-OFF',
  `ten_loai_giay` varchar(150) NOT NULL COMMENT 'Loại giấy',
  `so_luong_psp` int unsigned DEFAULT NULL,
  `so_luong_san_pham` int NOT NULL COMMENT 'Số lượng sản phẩm',
  `so_luong_nhan` int NOT NULL COMMENT 'Số nhãn đã in',
  `ten_ca` varchar(50) DEFAULT NULL COMMENT 'Ca sản xuất',
  `ngay_san_xuat` date DEFAULT NULL,
  `nguoi_kiem` varchar(100) DEFAULT NULL,
  `nguoi_dong_goi` varchar(100) DEFAULT NULL,
  `ghi_chu` varchar(500) DEFAULT NULL,
  `ten_mau_in` varchar(100) DEFAULT NULL COMMENT 'Tên template đã dùng',
  `ma_mau_in` int DEFAULT NULL COMMENT 'Template đã dùng lúc in gốc',
  `kho_giay` varchar(10) DEFAULT NULL COMMENT 'letter | a4',
  `ten_may_tinh` varchar(100) DEFAULT NULL COMMENT 'Tên máy tính đã in',
  `so_lan_in_lai` int NOT NULL DEFAULT '0' COMMENT 'Số lần in lại bản ghi này',
  `thoi_gian_tao_tem` datetime NOT NULL COMMENT 'Thời gian tạo tem',
  PRIMARY KEY (`ma_lich_su`),
  KEY `idx_ls_ma_phien` (`ma_phien`),
  KEY `idx_ls_ma_code` (`ma_code`),
  KEY `idx_ls_ten_san_pham` (`ten_san_pham`),
  KEY `idx_ls_phieu_san_pham` (`phieu_san_pham`),
  KEY `idx_ls_ngay_san_xuat` (`ngay_san_xuat`),
  KEY `idx_ls_thoi_gian_tao` (`thoi_gian_tao_tem`),
  CONSTRAINT `fk_lichsu_phien` FOREIGN KEY (`ma_phien`) REFERENCES `phien_in_tem` (`ma_phien`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=3123 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Lịch sử in tem — snapshot denormalized + nguồn dropdown SP và Loại giấy';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mau_in`
--

DROP TABLE IF EXISTS `mau_in`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mau_in` (
  `ma_mau_in` int NOT NULL AUTO_INCREMENT COMMENT 'Khóa chính',
  `ten_mau` varchar(100) NOT NULL COMMENT 'VD: Mẫu Letter mặc định',
  `kho_giay` enum('letter','a4') NOT NULL DEFAULT 'letter',
  `so_nhan_moi_trang` tinyint NOT NULL DEFAULT '8' COMMENT 'Số nhãn/tờ (layout 8-up)',
  `cau_hinh_truong` json NOT NULL COMMENT 'Style từng trường trên tem, đơn vị mm',
  `la_mac_dinh` tinyint NOT NULL DEFAULT '0' COMMENT '1=Template mặc định khi tạo phiên mới',
  `ghi_chu` varchar(255) DEFAULT NULL,
  `ngay_tao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ngay_cap_nhat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_mau_in`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Template in tem — layout khổ giấy và style từng trường';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `phien_in_tem`
--

DROP TABLE IF EXISTS `phien_in_tem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `phien_in_tem` (
  `ma_phien` int NOT NULL AUTO_INCREMENT COMMENT 'Khóa chính',
  `ma_mau_in` int NOT NULL COMMENT 'FK → mau_in',
  `tong_so_nhan` int NOT NULL DEFAULT '0' COMMENT 'Tổng số nhãn (SUM so_luong_nhan)',
  `tong_so_trang` int NOT NULL DEFAULT '0' COMMENT 'Tổng số trang (SUM so_trang từ chi_tiet_in_tem)',
  `trang_thai` enum('nhap','da_in','huy') NOT NULL DEFAULT 'nhap',
  `ghi_chu` text,
  `ten_may_tinh` varchar(100) DEFAULT NULL COMMENT 'Environment.MachineName',
  `ngay_tao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ngay_cap_nhat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_phien`),
  KEY `idx_ma_mau_in` (`ma_mau_in`),
  KEY `idx_trang_thai` (`trang_thai`),
  KEY `idx_ngay_tao` (`ngay_tao`),
  CONSTRAINT `fk_phien_mau_in` FOREIGN KEY (`ma_mau_in`) REFERENCES `mau_in` (`ma_mau_in`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=566 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Phiên in tem — 1 bản ghi = 1 đợt in';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `v_chi_tiet_day_du`
--

DROP TABLE IF EXISTS `v_chi_tiet_day_du`;
/*!50001 DROP VIEW IF EXISTS `v_chi_tiet_day_du`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_chi_tiet_day_du` AS SELECT 
 1 AS `ma_chi_tiet`,
 1 AS `ma_phien`,
 1 AS `ngay_tao_phien`,
 1 AS `trang_thai_phien`,
 1 AS `ten_may_tinh`,
 1 AS `ten_mau`,
 1 AS `kho_giay`,
 1 AS `so_nhan_moi_trang`,
 1 AS `stt`,
 1 AS `ten_san_pham`,
 1 AS `ma_code`,
 1 AS `phieu_san_pham`,
 1 AS `so_phieu`,
 1 AS `nam_phieu`,
 1 AS `chi_nhanh`,
 1 AS `ten_loai_giay`,
 1 AS `so_luong_san_pham`,
 1 AS `so_luong_nhan`,
 1 AS `so_trang`,
 1 AS `ten_ca`,
 1 AS `ngay_san_xuat`,
 1 AS `nguoi_kiem`,
 1 AS `nguoi_dong_goi`,
 1 AS `loai_tao`,
 1 AS `ma_lich_su_goc`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_dropdown_loai_giay`
--

DROP TABLE IF EXISTS `v_dropdown_loai_giay`;
/*!50001 DROP VIEW IF EXISTS `v_dropdown_loai_giay`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_dropdown_loai_giay` AS SELECT 
 1 AS `ten_loai_giay`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_dropdown_san_pham`
--

DROP TABLE IF EXISTS `v_dropdown_san_pham`;
/*!50001 DROP VIEW IF EXISTS `v_dropdown_san_pham`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_dropdown_san_pham` AS SELECT 
 1 AS `ten_san_pham`,
 1 AS `ma_code`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_xuat_in_expanded`
--

DROP TABLE IF EXISTS `v_xuat_in_expanded`;
/*!50001 DROP VIEW IF EXISTS `v_xuat_in_expanded`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_xuat_in_expanded` AS SELECT 
 1 AS `ma_phien`,
 1 AS `ma_chi_tiet`,
 1 AS `stt_cau_hinh`,
 1 AS `thu_tu_nhan`,
 1 AS `ten_san_pham`,
 1 AS `ma_code`,
 1 AS `phieu_san_pham`,
 1 AS `ten_loai_giay`,
 1 AS `so_luong_san_pham`,
 1 AS `ten_ca`,
 1 AS `ngay_san_xuat`,
 1 AS `nguoi_kiem`,
 1 AS `nguoi_dong_goi`,
 1 AS `so_trang_hien_tai`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'payroll_db'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_he_so_phan_bo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`OffsetSauin`@`%` FUNCTION `fn_he_so_phan_bo`(
  p_la_may_in       TINYINT,
  p_so_nguoi        TINYINT UNSIGNED,
  p_he_so_chuc_danh DECIMAL(4,2),
  p_loai_su_kien    VARCHAR(20)
) RETURNS decimal(8,4)
    NO SQL
    DETERMINISTIC
BEGIN
  DECLARE v_hs DECIMAL(8,4) DEFAULT 0;

  -- Máy khác hoặc số người = 0: chia đều
  IF p_la_may_in = 0 OR p_so_nguoi = 0 THEN
    RETURN ROUND(1 / GREATEST(p_so_nguoi, 1), 4);
  END IF;

  -- Máy in — phân bổ theo chức danh + số người
  IF p_loai_su_kien = 'new_job' THEN
    IF p_so_nguoi = 1 THEN
      -- Chỉ có 1 người → luôn là Trưởng ca → 100%
      SET v_hs = 1.0000;
    ELSEIF p_so_nguoi = 2 THEN
      -- Trưởng ca (1.5) = 0.5 | VH chính (1.0) = 0.5
      IF p_he_so_chuc_danh = 1.50 THEN SET v_hs = 0.5000;
      ELSEIF p_he_so_chuc_danh = 1.00 THEN SET v_hs = 0.5000;
      ELSE SET v_hs = 0.0000; -- Phụ VH không có phần khi 2 người
      END IF;
    ELSE
      -- 3+ người: Trưởng ca=0.4 | VH chính=0.35 | Phụ VH=0.25
      IF p_he_so_chuc_danh = 1.50 THEN SET v_hs = 0.4000;
      ELSEIF p_he_so_chuc_danh = 1.00 THEN SET v_hs = 0.3500;
      ELSE SET v_hs = 0.2500;
      END IF;
    END IF;

  ELSEIF p_loai_su_kien = 'sample' THEN
    IF p_so_nguoi = 1 THEN
      SET v_hs = 1.0000;
    ELSEIF p_so_nguoi = 2 THEN
      -- Trưởng ca (1.5) = 0.6 | VH chính (1.0) = 0.4
      IF p_he_so_chuc_danh = 1.50 THEN SET v_hs = 0.6000;
      ELSEIF p_he_so_chuc_danh = 1.00 THEN SET v_hs = 0.4000;
      ELSE SET v_hs = 0.0000;
      END IF;
    ELSE
      -- 3+ người: chia đều
      SET v_hs = ROUND(1 / p_so_nguoi, 4);
    END IF;
  END IF;

  RETURN v_hs;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_tinh_he_so_ca` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`OffsetSauin`@`%` FUNCTION `fn_tinh_he_so_ca`(
  p_loai_ca_id INT UNSIGNED
) RETURNS decimal(10,6)
    READS SQL DATA
    DETERMINISTIC
BEGIN
  DECLARE v_tong_gio   DECIMAL(4,1);
  DECLARE v_he_so      DECIMAL(10,6) DEFAULT 0;

  -- Lấy tổng giờ ca
  SELECT tong_gio INTO v_tong_gio
  FROM loai_ca
  WHERE id = p_loai_ca_id;

  -- Ca đơn giản (tong_gio IS NULL): chỉ có 1 đoạn, hệ số = 1.0
  IF v_tong_gio IS NULL THEN
    RETURN 1.000000;
  END IF;

  -- Ca phức tạp: Σ (so_gio / tong_gio × he_so)
  SELECT SUM(pdc.so_gio / v_tong_gio * pdc.he_so)
  INTO v_he_so
  FROM phan_doan_ca pdc
  WHERE pdc.loai_ca_id = p_loai_ca_id;

  RETURN IFNULL(v_he_so, 0);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_tra_don_gia` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`OffsetSauin`@`%` FUNCTION `fn_tra_don_gia`(
  p_san_pham_id  INT UNSIGNED,
  p_nhom_may_id  INT UNSIGNED,
  p_cong_doan_id INT UNSIGNED,
  p_loai_gia     VARCHAR(20),
  p_ngay         DATE
) RETURNS decimal(15,4)
    READS SQL DATA
    DETERMINISTIC
BEGIN
  DECLARE v_don_gia     DECIMAL(15,4) DEFAULT NULL;
  DECLARE v_nhom_gia_id INT UNSIGNED  DEFAULT NULL;

  -- ══════════════════════════════════════════════════════
  --  Bước 1: Tìm nhom_gia_id từ phan_nhom_gia_sp
  --  Ưu tiên 1: khớp cong_doan cụ thể
  --  Ưu tiên 2: cong_doan = NULL (áp dụng chung)
  -- ══════════════════════════════════════════════════════

  -- Ưu tiên 1: san_pham + nhom_may + cong_doan cụ thể
  SELECT pn.nhom_gia_id
  INTO v_nhom_gia_id
  FROM phan_nhom_gia_sp pn
  WHERE pn.san_pham_id   = p_san_pham_id
    AND pn.nhom_may_id   = p_nhom_may_id
    AND pn.cong_doan_id  = p_cong_doan_id
    AND pn.loai_gia      = p_loai_gia
    AND pn.hieu_luc_tu  <= p_ngay
    AND (pn.hieu_luc_den IS NULL OR pn.hieu_luc_den >= p_ngay)
  ORDER BY pn.hieu_luc_tu DESC
  LIMIT 1;

  -- Ưu tiên 2: san_pham + nhom_may + cong_doan = NULL
  IF v_nhom_gia_id IS NULL THEN
    SELECT pn.nhom_gia_id
    INTO v_nhom_gia_id
    FROM phan_nhom_gia_sp pn
    WHERE pn.san_pham_id   = p_san_pham_id
      AND pn.nhom_may_id   = p_nhom_may_id
      AND pn.cong_doan_id  IS NULL
      AND pn.loai_gia      = p_loai_gia
      AND pn.hieu_luc_tu  <= p_ngay
      AND (pn.hieu_luc_den IS NULL OR pn.hieu_luc_den >= p_ngay)
    ORDER BY pn.hieu_luc_tu DESC
    LIMIT 1;
  END IF;

  IF v_nhom_gia_id IS NULL THEN
    RETURN NULL; -- Không tìm thấy nhóm giá
  END IF;

  -- ══════════════════════════════════════════════════════
  --  Bước 2: Tìm đơn giá từ nhom_gia
  --  Ưu tiên 1: nhom_gia có cong_doan cụ thể
  --  Ưu tiên 2: nhom_gia có cong_doan = NULL
  -- ══════════════════════════════════════════════════════

  -- Ưu tiên 1: nhom_gia có cong_doan cụ thể
  SELECT ng.don_gia
  INTO v_don_gia
  FROM nhom_gia ng
  WHERE ng.id           = v_nhom_gia_id
    AND ng.cong_doan_id = p_cong_doan_id
    AND ng.hieu_luc_tu <= p_ngay
    AND (ng.hieu_luc_den IS NULL OR ng.hieu_luc_den >= p_ngay)
  ORDER BY ng.hieu_luc_tu DESC
  LIMIT 1;

  -- Ưu tiên 2: nhom_gia có cong_doan = NULL (áp dụng chung)
  IF v_don_gia IS NULL THEN
    SELECT ng.don_gia
    INTO v_don_gia
    FROM nhom_gia ng
    WHERE ng.id           = v_nhom_gia_id
      AND ng.cong_doan_id IS NULL
      AND ng.hieu_luc_tu <= p_ngay
      AND (ng.hieu_luc_den IS NULL OR ng.hieu_luc_den >= p_ngay)
    ORDER BY ng.hieu_luc_tu DESC
    LIMIT 1;
  END IF;

  RETURN v_don_gia;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_dong_phien` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`OffsetSauin`@`%` PROCEDURE `sp_dong_phien`(
    IN p_ma_phien  INT,
    IN p_ten_may   VARCHAR(100)
)
BEGIN
    DECLARE v_tong_nhan   INT DEFAULT 0;
    DECLARE v_tong_trang  INT DEFAULT 0;
    DECLARE v_ten_mau     VARCHAR(100);
    DECLARE v_kho_giay    VARCHAR(10);
    DECLARE v_ma_mau_in   INT;

    SELECT SUM(so_luong_nhan), SUM(so_trang)
    INTO   v_tong_nhan, v_tong_trang
    FROM   chi_tiet_in_tem
    WHERE  ma_phien = p_ma_phien;

    SELECT mi.ten_mau, mi.kho_giay, mi.ma_mau_in
    INTO   v_ten_mau, v_kho_giay, v_ma_mau_in
    FROM   phien_in_tem p
    JOIN   mau_in mi ON p.ma_mau_in = mi.ma_mau_in
    WHERE  p.ma_phien = p_ma_phien;

    UPDATE phien_in_tem
    SET tong_so_nhan  = COALESCE(v_tong_nhan, 0),
        tong_so_trang = COALESCE(v_tong_trang, 0),
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
        ct.ma_phien, ct.stt, ct.ten_san_pham, ct.ma_code,
        CONCAT(ct.so_phieu,'/',ct.nam_phieu,'/',ct.chi_nhanh),
        ct.ten_loai_giay, ct.so_luong_san_pham, ct.so_luong_nhan,
        ct.so_luong_psp, ct.ghi_chu,
        ca.ten_ca, ct.ngay_san_xuat, ct.nguoi_kiem, ct.nguoi_dong_goi,
        v_ten_mau, v_kho_giay, v_ma_mau_in, p_ten_may, p.ngay_tao
    FROM chi_tiet_in_tem    ct
    JOIN phien_in_tem       p   ON ct.ma_phien = p.ma_phien
    LEFT JOIN ca_san_xuat   ca  ON ct.ma_ca    = ca.ma_ca
    WHERE ct.ma_phien = p_ma_phien
      AND NOT EXISTS (
          SELECT 1 FROM lich_su_in_tem ls WHERE ls.ma_phien = p_ma_phien
      );

    SELECT CONCAT('Phiên #', p_ma_phien, ' đã đóng. ',
           'Nhãn: ', COALESCE(v_tong_nhan,0), ' | ',
           'Trang: ', COALESCE(v_tong_trang,0)) AS ket_qua;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_duyet_bang_luong` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`OffsetSauin`@`%` PROCEDURE `sp_duyet_bang_luong`(
  IN  p_ky_luong_id INT UNSIGNED,
  OUT p_thong_bao   VARCHAR(500)
)
lbl_sp_duyet_bang_luong: BEGIN
  DECLARE v_trang_thai  VARCHAR(20);
  DECLARE v_so_nv       INT;
  DECLARE v_tong_luong  DECIMAL(18,2);
  DECLARE v_so_loi      INT DEFAULT 0;

  -- Kiểm tra kỳ lương
  SELECT trang_thai INTO v_trang_thai
  FROM ky_luong WHERE id = p_ky_luong_id;

  IF v_trang_thai IS NULL THEN
    SET p_thong_bao = CONCAT('LOI: Khong tim thay ky luong ID=', p_ky_luong_id);
    LEAVE lbl_sp_duyet_bang_luong;
  END IF;

  IF v_trang_thai != 'draft' THEN
    SET p_thong_bao = CONCAT('LOI: Ky luong dang o trang thai [', v_trang_thai,
                              ']. Chi duyet duoc khi o trang thai [draft].');
    LEAVE lbl_sp_duyet_bang_luong;
  END IF;

  -- Kiểm tra có bản ghi sản lượng nào chưa được tính lương không
  -- (bản ghi tồn tại trong kỳ nhưng không có dòng chi_tiet_luong)
  SELECT COUNT(*) INTO v_so_loi
  FROM ban_ghi_san_luong bgsl
  JOIN ky_luong kl ON bgsl.ngay_san_xuat BETWEEN kl.ngay_bat_dau AND kl.ngay_ket_thuc
  LEFT JOIN chi_tiet_luong ctl ON ctl.ban_ghi_id = bgsl.id
  WHERE kl.id = p_ky_luong_id
    AND ctl.id IS NULL;

  IF v_so_loi > 0 THEN
    SET p_thong_bao = CONCAT('LOI: Con ', v_so_loi,
      ' ban ghi san luong chua duoc tinh luong (thieu don gia).',
      ' Vui long kiem tra va cap nhat don gia truoc khi duyet.');
    LEAVE lbl_sp_duyet_bang_luong;
  END IF;

  -- Duyệt: cập nhật trạng thái
  UPDATE bang_luong SET trang_thai = 'confirmed', ngay_cap_nhat = NOW()
  WHERE ky_luong_id = p_ky_luong_id;

  UPDATE ky_luong SET trang_thai = 'confirmed', ngay_cap_nhat = NOW()
  WHERE id = p_ky_luong_id;

  -- Lấy thông tin tổng hợp để thông báo
  SELECT COUNT(*), IFNULL(SUM(tong_luong), 0)
  INTO v_so_nv, v_tong_luong
  FROM bang_luong WHERE ky_luong_id = p_ky_luong_id;

  SET p_thong_bao = CONCAT(
    'OK: Da duyet ky luong ID=', p_ky_luong_id, '. ',
    'So NV: ', v_so_nv, ' | ',
    'Tong quy luong: ', FORMAT(v_tong_luong, 0), ' VND.');
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_huy_tinh_luong` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`OffsetSauin`@`%` PROCEDURE `sp_huy_tinh_luong`(
  IN  p_ky_luong_id INT UNSIGNED,
  OUT p_thong_bao   VARCHAR(500)
)
lbl_sp_huy_tinh_luong: BEGIN
  DECLARE v_trang_thai VARCHAR(20);

  SELECT trang_thai INTO v_trang_thai
  FROM ky_luong WHERE id = p_ky_luong_id;

  IF v_trang_thai IS NULL THEN
    SET p_thong_bao = CONCAT('LOI: Khong tim thay ky luong ID=', p_ky_luong_id);
    LEAVE lbl_sp_huy_tinh_luong;
  END IF;

  IF v_trang_thai IN ('confirmed', 'paid') THEN
    SET p_thong_bao = CONCAT('LOI: Ky luong da [', v_trang_thai,
                              '], khong the huy. Lien he quan tri vien.');
    LEAVE lbl_sp_huy_tinh_luong;
  END IF;

  -- Xóa chi tiết → bang luong → reset ky luong
  DELETE ctl FROM chi_tiet_luong ctl
  JOIN bang_luong bl ON bl.id = ctl.bang_luong_id
  WHERE bl.ky_luong_id = p_ky_luong_id;

  DELETE FROM bang_luong WHERE ky_luong_id = p_ky_luong_id;

  UPDATE ky_luong SET trang_thai = 'draft', ngay_cap_nhat = NOW()
  WHERE id = p_ky_luong_id;

  SET p_thong_bao = CONCAT('OK: Da huy ket qua tinh luong ky ID=',
                            p_ky_luong_id, '. San sang tinh lai.');
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tao_ky_luong` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`OffsetSauin`@`%` PROCEDURE `sp_tao_ky_luong`(
  IN  p_nam           SMALLINT UNSIGNED,
  IN  p_thang         TINYINT UNSIGNED,
  IN  p_ngay_bat_dau  DATE,
  IN  p_ngay_ket_thuc DATE,
  OUT p_ky_luong_id   INT UNSIGNED,
  OUT p_thong_bao     VARCHAR(500)
)
lbl_sp_tao_ky_luong: BEGIN
  DECLARE v_exists INT DEFAULT 0;

  -- Kiểm tra kỳ lương đã tồn tại chưa
  SELECT COUNT(*) INTO v_exists
  FROM ky_luong
  WHERE nam = p_nam AND thang = p_thang;

  IF v_exists > 0 THEN
    SET p_ky_luong_id = 0;
    SET p_thong_bao = CONCAT('LOI: Ky luong thang ', p_thang, '/', p_nam, ' da ton tai.');
    LEAVE lbl_sp_tao_ky_luong;
  END IF;

  -- Kiểm tra ngày hợp lệ
  IF p_ngay_bat_dau > p_ngay_ket_thuc THEN
    SET p_ky_luong_id = 0;
    SET p_thong_bao = 'LOI: Ngay bat dau phai nho hon ngay ket thuc.';
    LEAVE lbl_sp_tao_ky_luong;
  END IF;

  -- Tạo kỳ lương
  INSERT INTO ky_luong (nam, thang, ngay_bat_dau, ngay_ket_thuc, trang_thai)
  VALUES (p_nam, p_thang, p_ngay_bat_dau, p_ngay_ket_thuc, 'draft');

  SET p_ky_luong_id = LAST_INSERT_ID();
  SET p_thong_bao = CONCAT('OK: Da tao ky luong thang ', p_thang, '/', p_nam,
                            ' (ID=', p_ky_luong_id, ').');
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tinh_luong_ky` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`OffsetSauin`@`%` PROCEDURE `sp_tinh_luong_ky`(
  IN  p_ky_luong_id INT UNSIGNED,
  OUT p_so_nv       INT,
  OUT p_tong_luong  DECIMAL(18,2),
  OUT p_thong_bao   VARCHAR(2000)
)
lbl_sp_tinh_luong_ky: BEGIN
  -- Biến kỳ lương
  DECLARE v_trang_thai    VARCHAR(20);
  DECLARE v_ngay_bd       DATE;
  DECLARE v_ngay_kt       DATE;

  -- Biến cursor duyệt bản ghi
  DECLARE v_done          INT DEFAULT 0;
  DECLARE v_bgsl_id       INT UNSIGNED;
  DECLARE v_nv_id         INT UNSIGNED;
  DECLARE v_may_id        INT UNSIGNED;
  DECLARE v_cd_id         INT UNSIGNED;
  DECLARE v_lc_id         INT UNSIGNED;
  DECLARE v_sp_id         INT UNSIGNED;
  DECLARE v_ngay_sx       DATE;
  DECLARE v_san_luong     DECIMAL(15,4);
  DECLARE v_len_bai       TINYINT(1);
  DECLARE v_so_nguoi      TINYINT UNSIGNED;
  DECLARE v_hs_cd         DECIMAL(4,2);
  DECLARE v_ten_cd_snap   VARCHAR(100);

  -- Biến tra cứu
  DECLARE v_nhom_may_id   INT UNSIGNED;
  DECLARE v_la_may_in     TINYINT;
  DECLARE v_la_thu_cong   TINYINT;
  DECLARE v_loai_cd       ENUM('normal','sample','special');
  DECLARE v_don_gia_db    DECIMAL(15,4);

  -- Biến tính toán
  DECLARE v_he_so_ca      DECIMAL(10,6);
  DECLARE v_don_gia       DECIMAL(15,4);
  DECLARE v_he_so_pb      DECIMAL(8,4);
  DECLARE v_thanh_tien    DECIMAL(15,2);
  DECLARE v_ghi_chu       TEXT;

  -- Biến bang_luong
  DECLARE v_bl_id         INT UNSIGNED;

  -- Biến cảnh báo
  DECLARE v_canh_bao      VARCHAR(1000) DEFAULT '';
  DECLARE v_so_dong_loi   INT DEFAULT 0;

  -- Biến cho khoản ① phương thức tính giá
  DECLARE v_phuong_thuc   VARCHAR(30);
  DECLARE v_don_gia_cd    DECIMAL(15,4);
  DECLARE v_trong_luong   DECIMAL(10,4);

  -- ─── Cursor: duyệt tất cả bản ghi sản lượng trong kỳ ───
  DECLARE cur_bgsl CURSOR FOR
    SELECT
      bgsl.id, bgsl.nhan_vien_id, bgsl.may_id, bgsl.cong_doan_id,
      bgsl.loai_ca_id, bgsl.san_pham_id, bgsl.ngay_san_xuat,
      bgsl.san_luong_dat, bgsl.len_bai_moi, bgsl.so_nguoi_van_hanh,
      bgsl.he_so_chuc_danh, bgsl.ten_chuc_danh
    FROM ban_ghi_san_luong bgsl
    WHERE bgsl.ngay_san_xuat BETWEEN v_ngay_bd AND v_ngay_kt
    ORDER BY bgsl.nhan_vien_id, bgsl.ngay_san_xuat, bgsl.id;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

  -- ════════════════════════════════════════════════
  --  BƯỚC 1: Kiểm tra kỳ lương
  -- ════════════════════════════════════════════════
  SELECT trang_thai, ngay_bat_dau, ngay_ket_thuc
  INTO v_trang_thai, v_ngay_bd, v_ngay_kt
  FROM ky_luong WHERE id = p_ky_luong_id;

  IF v_trang_thai IS NULL THEN
    SET p_so_nv = 0; SET p_tong_luong = 0;
    SET p_thong_bao = CONCAT('LOI: Khong tim thay ky luong ID=', p_ky_luong_id);
    LEAVE lbl_sp_tinh_luong_ky;
  END IF;

  IF v_trang_thai IN ('confirmed', 'paid') THEN
    SET p_so_nv = 0; SET p_tong_luong = 0;
    SET p_thong_bao = CONCAT('LOI: Ky luong da [', v_trang_thai, '], khong the tinh lai.',
                              ' Dung sp_huy_tinh_luong neu can.');
    LEAVE lbl_sp_tinh_luong_ky;
  END IF;

  -- ════════════════════════════════════════════════
  --  BƯỚC 2: Xóa kết quả cũ để tính lại
  -- ════════════════════════════════════════════════
  DELETE ctl FROM chi_tiet_luong ctl
  JOIN bang_luong bl ON bl.id = ctl.bang_luong_id
  WHERE bl.ky_luong_id = p_ky_luong_id;

  DELETE FROM bang_luong WHERE ky_luong_id = p_ky_luong_id;

  -- ════════════════════════════════════════════════
  --  BƯỚC 3: Duyệt từng bản ghi sản lượng
  -- ════════════════════════════════════════════════
  SET v_bl_id = 0;

  OPEN cur_bgsl;
  loop_bgsl: LOOP
    FETCH cur_bgsl INTO
      v_bgsl_id, v_nv_id, v_may_id, v_cd_id,
      v_lc_id, v_sp_id, v_ngay_sx,
      v_san_luong, v_len_bai, v_so_nguoi,
      v_hs_cd, v_ten_cd_snap;

    IF v_done THEN LEAVE loop_bgsl; END IF;

    -- ── Tra cứu thông tin máy ──
    SELECT m.nhom_may_id, nm.la_may_in, m.la_thu_cong
    INTO v_nhom_may_id, v_la_may_in, v_la_thu_cong
    FROM may m
    JOIN nhom_may nm ON nm.id = m.nhom_may_id
    WHERE m.id = v_may_id;

    -- ── Tra cứu loại công đoạn ──
    SELECT loai_cong_doan, don_gia_dac_biet
    INTO v_loai_cd, v_don_gia_db
    FROM cong_doan WHERE id = v_cd_id;

    -- ── Tính hệ số ca ──
    SET v_he_so_ca = fn_tinh_he_so_ca(v_lc_id);

    -- ── Lấy hoặc tạo bảng lương của nhân viên này ──
    SELECT id INTO v_bl_id FROM bang_luong
    WHERE ky_luong_id = p_ky_luong_id AND nhan_vien_id = v_nv_id
    LIMIT 1;

    IF v_bl_id IS NULL OR v_bl_id = 0 THEN
      INSERT INTO bang_luong
        (ky_luong_id, nhan_vien_id, tong_luong_san_luong,
         tong_pc_len_bai, tong_pc_mau, tong_pc_dac_biet, tong_luong, trang_thai)
      VALUES (p_ky_luong_id, v_nv_id, 0, 0, 0, 0, 0, 'draft');
      SET v_bl_id = LAST_INSERT_ID();
    END IF;

    -- ════════════════════════════════════════════
    --  ① LƯƠNG SẢN LƯỢNG (loai_cong_doan = normal)
    --  Xử lý 4 phương thức tính giá tùy cấu hình công đoạn
    -- ════════════════════════════════════════════
    IF v_loai_cd = 'normal' THEN
      SELECT phuong_thuc_gia, don_gia_cong_doan
      INTO v_phuong_thuc, v_don_gia_cd
      FROM cong_doan WHERE id = v_cd_id;

      -- ── Tính đơn giá theo phương thức ──
      CASE v_phuong_thuc

        -- Phương thức 1: tra đơn giá qua nhóm sản phẩm (mặc định)
        WHEN 'theo_nhom_sp' THEN
          SET v_don_gia = fn_tra_don_gia(v_sp_id, v_nhom_may_id, v_cd_id, 'production', v_ngay_sx);
          IF v_don_gia IS NULL THEN
            SET v_so_dong_loi = v_so_dong_loi + 1;
            SET v_canh_bao = CONCAT(v_canh_bao,
              '\n[CANH BAO] ban_ghi_id=', v_bgsl_id,
              ': Khong tim thay don gia [theo_nhom_sp] sp_id=', v_sp_id,
              ' nhom_may_id=', v_nhom_may_id, ' cong_doan_id=', v_cd_id);
          ELSE
            SET v_thanh_tien = ROUND(v_san_luong * v_don_gia * v_he_so_ca * v_hs_cd, 2);
            SET v_ghi_chu = CONCAT(
              'theo_nhom_sp: SL(', v_san_luong, ') x DG(', v_don_gia,
              ') x HeSoCa(', ROUND(v_he_so_ca,4), ') x HsCD(', v_hs_cd, ') = ', v_thanh_tien);

            INSERT INTO chi_tiet_luong
              (bang_luong_id, ban_ghi_id, loai_khoan,
               don_gia_goc, he_so_goc, san_luong_goc, thanh_tien, ghi_chu_tinh)
            VALUES (v_bl_id, v_bgsl_id, 'production',
               v_don_gia, ROUND(v_he_so_ca * v_hs_cd, 6), v_san_luong, v_thanh_tien, v_ghi_chu);

            UPDATE bang_luong
            SET tong_luong_san_luong = tong_luong_san_luong + v_thanh_tien,
                tong_luong           = tong_luong + v_thanh_tien
            WHERE id = v_bl_id;
          END IF;

        -- Phương thức 2: đơn giá cố định theo công đoạn, bỏ qua sản phẩm
        -- Công thức: SL × don_gia_cong_doan × hệ số ca × hệ số chức danh
        -- Dùng cho: vệ sinh bảo dưỡng, thủ công tay loại cố định...
        WHEN 'theo_cong_doan' THEN
          IF v_don_gia_cd IS NULL THEN
            SET v_so_dong_loi = v_so_dong_loi + 1;
            SET v_canh_bao = CONCAT(v_canh_bao,
              '\n[CANH BAO] ban_ghi_id=', v_bgsl_id,
              ': Cong doan [theo_cong_doan] chua co don_gia_cong_doan (cong_doan_id=', v_cd_id, ')');
          ELSE
            SET v_thanh_tien = ROUND(v_san_luong * v_don_gia_cd * v_he_so_ca * v_hs_cd, 2);
            SET v_ghi_chu = CONCAT(
              'theo_cong_doan: SL(', v_san_luong, ') x DG(', v_don_gia_cd,
              ') x HeSoCa(', ROUND(v_he_so_ca,4), ') x HsCD(', v_hs_cd, ') = ', v_thanh_tien);

            INSERT INTO chi_tiet_luong
              (bang_luong_id, ban_ghi_id, loai_khoan,
               don_gia_goc, he_so_goc, san_luong_goc, thanh_tien, ghi_chu_tinh)
            VALUES (v_bl_id, v_bgsl_id, 'production',
               v_don_gia_cd, ROUND(v_he_so_ca * v_hs_cd, 6), v_san_luong, v_thanh_tien, v_ghi_chu);

            UPDATE bang_luong
            SET tong_luong_san_luong = tong_luong_san_luong + v_thanh_tien,
                tong_luong           = tong_luong + v_thanh_tien
            WHERE id = v_bl_id;
          END IF;

        -- Phương thức 3: đơn giá cố định chia đều số người vận hành
        -- Công thức: don_gia_cong_doan / so_nguoi
        WHEN 'theo_so_nguoi' THEN
          IF v_don_gia_cd IS NULL THEN
            SET v_so_dong_loi = v_so_dong_loi + 1;
            SET v_canh_bao = CONCAT(v_canh_bao,
              '\n[CANH BAO] ban_ghi_id=', v_bgsl_id,
              ': Cong doan [theo_so_nguoi] chua co don_gia_cong_doan (cong_doan_id=', v_cd_id, ')');
          ELSE
            SET v_thanh_tien = ROUND(v_don_gia_cd / GREATEST(v_so_nguoi, 1), 2);
            SET v_ghi_chu = CONCAT(
              'theo_so_nguoi: DG(', v_don_gia_cd,
              ') / SoNguoi(', v_so_nguoi, ') = ', v_thanh_tien);

            INSERT INTO chi_tiet_luong
              (bang_luong_id, ban_ghi_id, loai_khoan,
               don_gia_goc, he_so_goc, san_luong_goc, thanh_tien, ghi_chu_tinh)
            VALUES (v_bl_id, v_bgsl_id, 'production',
               v_don_gia_cd, ROUND(1 / GREATEST(v_so_nguoi,1), 6), 0, v_thanh_tien, v_ghi_chu);

            UPDATE bang_luong
            SET tong_luong_san_luong = tong_luong_san_luong + v_thanh_tien,
                tong_luong           = tong_luong + v_thanh_tien
            WHERE id = v_bl_id;
          END IF;

        -- Phương thức 4: sản lượng nhân trọng lượng Kg
        -- Công thức: SL × trong_luong_kg × don_gia_cong_doan × hệ số ca × hệ số chức danh
        -- Dùng cho: công đoạn bốc hàng
        WHEN 'theo_trong_luong' THEN
          IF v_don_gia_cd IS NULL THEN
            SET v_so_dong_loi = v_so_dong_loi + 1;
            SET v_canh_bao = CONCAT(v_canh_bao,
              '\n[CANH BAO] ban_ghi_id=', v_bgsl_id,
              ': Cong doan [theo_trong_luong] chua co don_gia_cong_doan (cong_doan_id=', v_cd_id, ')');
          ELSE
            SELECT trong_luong_kg INTO v_trong_luong
            FROM san_pham WHERE id = v_sp_id;

            IF v_trong_luong IS NULL OR v_trong_luong = 0 THEN
              SET v_so_dong_loi = v_so_dong_loi + 1;
              SET v_canh_bao = CONCAT(v_canh_bao,
                '\n[CANH BAO] ban_ghi_id=', v_bgsl_id,
                ': San pham chua co trong_luong_kg (san_pham_id=', v_sp_id, ')');
            ELSE
              SET v_thanh_tien = ROUND(v_san_luong * v_trong_luong * v_don_gia_cd * v_he_so_ca * v_hs_cd, 2);
              SET v_ghi_chu = CONCAT(
                'theo_trong_luong: SL(', v_san_luong,
                ') x TrongLuong(', v_trong_luong,
                'kg) x DG(', v_don_gia_cd,
                ') x HeSoCa(', ROUND(v_he_so_ca,4),
                ') x HsCD(', v_hs_cd, ') = ', v_thanh_tien);

              INSERT INTO chi_tiet_luong
                (bang_luong_id, ban_ghi_id, loai_khoan,
                 don_gia_goc, he_so_goc, san_luong_goc, thanh_tien, ghi_chu_tinh)
              VALUES (v_bl_id, v_bgsl_id, 'production',
                 v_don_gia_cd, ROUND(v_he_so_ca * v_hs_cd, 6),
                 ROUND(v_san_luong * v_trong_luong, 4), v_thanh_tien, v_ghi_chu);

              UPDATE bang_luong
              SET tong_luong_san_luong = tong_luong_san_luong + v_thanh_tien,
                  tong_luong           = tong_luong + v_thanh_tien
              WHERE id = v_bl_id;
            END IF;
          END IF;

      END CASE;
    END IF; -- end ①

    -- ════════════════════════════════════════════
    --  ② PHỤ CẤP LÊN BÀI MỚI
    --     Điều kiện: len_bai_moi=1 AND normal AND không thủ công
    -- ════════════════════════════════════════════
    IF v_len_bai = 1 AND v_loai_cd = 'normal' AND v_la_thu_cong = 0 THEN
      SET v_don_gia = fn_tra_don_gia(v_sp_id, v_nhom_may_id, v_cd_id, 'new_job', v_ngay_sx);

      IF v_don_gia IS NULL THEN
        SET v_so_dong_loi = v_so_dong_loi + 1;
        SET v_canh_bao = CONCAT(v_canh_bao,
          '\n[CANH BAO] ban_ghi_id=', v_bgsl_id,
          ': Khong tim thay don gia new_job cho sp_id=', v_sp_id,
          ' nhom_may_id=', v_nhom_may_id, ' ngay=', v_ngay_sx);
      ELSE
        SET v_he_so_pb = fn_he_so_phan_bo(v_la_may_in, v_so_nguoi, v_hs_cd, 'new_job');
        SET v_thanh_tien = ROUND(v_don_gia * v_he_so_pb, 2);
        SET v_ghi_chu = CONCAT(
          'LenBai: DG(', v_don_gia,
          ') x HsPhanBo(', v_he_so_pb,
          ') [MayIn=', v_la_may_in, ' SoNguoi=', v_so_nguoi,
          ' HsCD=', v_hs_cd, '] = ', v_thanh_tien);

        INSERT INTO chi_tiet_luong
          (bang_luong_id, ban_ghi_id, loai_khoan,
           don_gia_goc, he_so_goc, san_luong_goc, thanh_tien, ghi_chu_tinh)
        VALUES
          (v_bl_id, v_bgsl_id, 'new_job',
           v_don_gia, v_he_so_pb, 0, v_thanh_tien, v_ghi_chu);

        UPDATE bang_luong
        SET tong_pc_len_bai = tong_pc_len_bai + v_thanh_tien,
            tong_luong      = tong_luong + v_thanh_tien
        WHERE id = v_bl_id;
      END IF;
    END IF; -- end ②

    -- ════════════════════════════════════════════
    --  ③ PHỤ CẤP SẢN XUẤT MẪU
    --     Điều kiện: loai_cong_doan = sample AND không thủ công
    -- ════════════════════════════════════════════
    IF v_loai_cd = 'sample' AND v_la_thu_cong = 0 THEN
      SET v_don_gia = fn_tra_don_gia(v_sp_id, v_nhom_may_id, v_cd_id, 'sample', v_ngay_sx);

      IF v_don_gia IS NULL THEN
        SET v_so_dong_loi = v_so_dong_loi + 1;
        SET v_canh_bao = CONCAT(v_canh_bao,
          '\n[CANH BAO] ban_ghi_id=', v_bgsl_id,
          ': Khong tim thay don gia sample cho sp_id=', v_sp_id,
          ' nhom_may_id=', v_nhom_may_id, ' ngay=', v_ngay_sx);
      ELSE
        SET v_he_so_pb = fn_he_so_phan_bo(v_la_may_in, v_so_nguoi, v_hs_cd, 'sample');
        SET v_thanh_tien = ROUND(v_don_gia * v_he_so_pb, 2);
        SET v_ghi_chu = CONCAT(
          'SxMau: DG(', v_don_gia,
          ') x HsPhanBo(', v_he_so_pb,
          ') [MayIn=', v_la_may_in, ' SoNguoi=', v_so_nguoi,
          ' HsCD=', v_hs_cd, '] = ', v_thanh_tien);

        INSERT INTO chi_tiet_luong
          (bang_luong_id, ban_ghi_id, loai_khoan,
           don_gia_goc, he_so_goc, san_luong_goc, thanh_tien, ghi_chu_tinh)
        VALUES
          (v_bl_id, v_bgsl_id, 'sample',
           v_don_gia, v_he_so_pb, 0, v_thanh_tien, v_ghi_chu);

        UPDATE bang_luong
        SET tong_pc_mau = tong_pc_mau + v_thanh_tien,
            tong_luong  = tong_luong + v_thanh_tien
        WHERE id = v_bl_id;
      END IF;
    END IF; -- end ③

    -- ════════════════════════════════════════════
    --  ④ PHỤ CẤP CÔNG ĐOẠN ĐẶC BIỆT
    --     Điều kiện: loai_cong_doan = special
    --     Lưu ý: len_bai_moi=1 nhưng KHÔNG tính khoản ②
    -- ════════════════════════════════════════════
    IF v_loai_cd = 'special' THEN
      IF v_don_gia_db IS NULL THEN
        SET v_so_dong_loi = v_so_dong_loi + 1;
        SET v_canh_bao = CONCAT(v_canh_bao,
          '\n[CANH BAO] ban_ghi_id=', v_bgsl_id,
          ': Cong doan special chua co don_gia_dac_biet (cong_doan_id=', v_cd_id, ')');
      ELSE
        SET v_he_so_pb   = ROUND(1 / GREATEST(v_so_nguoi, 1), 4);
        SET v_thanh_tien = ROUND(v_don_gia_db * v_he_so_pb, 2);
        SET v_ghi_chu = CONCAT(
          'DacBiet: DG(', v_don_gia_db,
          ') / SoNguoi(', v_so_nguoi, ') = ', v_thanh_tien);

        INSERT INTO chi_tiet_luong
          (bang_luong_id, ban_ghi_id, loai_khoan,
           don_gia_goc, he_so_goc, san_luong_goc, thanh_tien, ghi_chu_tinh)
        VALUES
          (v_bl_id, v_bgsl_id, 'special',
           v_don_gia_db, v_he_so_pb, 0, v_thanh_tien, v_ghi_chu);

        UPDATE bang_luong
        SET tong_pc_dac_biet = tong_pc_dac_biet + v_thanh_tien,
            tong_luong       = tong_luong + v_thanh_tien
        WHERE id = v_bl_id;
      END IF;
    END IF; -- end ④

    SET v_bl_id = 0; -- reset cho nhân viên tiếp theo

  END LOOP loop_bgsl;
  CLOSE cur_bgsl;

  -- ════════════════════════════════════════════════
  --  BƯỚC 4: Tổng hợp kết quả đầu ra
  -- ════════════════════════════════════════════════
  SELECT COUNT(*), IFNULL(SUM(tong_luong), 0)
  INTO p_so_nv, p_tong_luong
  FROM bang_luong
  WHERE ky_luong_id = p_ky_luong_id;

  IF v_so_dong_loi = 0 THEN
    SET p_thong_bao = CONCAT(
      'OK: Tinh luong thanh cong. ',
      'So NV: ', p_so_nv, ' | ',
      'Tong quy luong: ', FORMAT(p_tong_luong, 0), ' VND');
  ELSE
    SET p_thong_bao = CONCAT(
      'CANH BAO: Tinh luong hoan tat nhung co ', v_so_dong_loi, ' dong loi don gia. ',
      'So NV: ', p_so_nv, ' | ',
      'Tong quy luong: ', FORMAT(p_tong_luong, 0), ' VND. ',
      'Chi tiet:', v_canh_bao);
  END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `v_chi_tiet_day_du`
--

/*!50001 DROP VIEW IF EXISTS `v_chi_tiet_day_du`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`OffsetSauin`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_chi_tiet_day_du` AS select `ct`.`ma_chi_tiet` AS `ma_chi_tiet`,`ct`.`ma_phien` AS `ma_phien`,`p`.`ngay_tao` AS `ngay_tao_phien`,`p`.`trang_thai` AS `trang_thai_phien`,`p`.`ten_may_tinh` AS `ten_may_tinh`,`mi`.`ten_mau` AS `ten_mau`,`mi`.`kho_giay` AS `kho_giay`,`mi`.`so_nhan_moi_trang` AS `so_nhan_moi_trang`,`ct`.`stt` AS `stt`,`ct`.`ten_san_pham` AS `ten_san_pham`,`ct`.`ma_code` AS `ma_code`,concat(`ct`.`so_phieu`,'/',`ct`.`nam_phieu`,'/',`ct`.`chi_nhanh`) AS `phieu_san_pham`,`ct`.`so_phieu` AS `so_phieu`,`ct`.`nam_phieu` AS `nam_phieu`,`ct`.`chi_nhanh` AS `chi_nhanh`,`ct`.`ten_loai_giay` AS `ten_loai_giay`,`ct`.`so_luong_san_pham` AS `so_luong_san_pham`,`ct`.`so_luong_nhan` AS `so_luong_nhan`,`ct`.`so_trang` AS `so_trang`,`ca`.`ten_ca` AS `ten_ca`,`ct`.`ngay_san_xuat` AS `ngay_san_xuat`,`ct`.`nguoi_kiem` AS `nguoi_kiem`,`ct`.`nguoi_dong_goi` AS `nguoi_dong_goi`,`ct`.`loai_tao` AS `loai_tao`,`ct`.`ma_lich_su_goc` AS `ma_lich_su_goc` from (((`chi_tiet_in_tem` `ct` join `phien_in_tem` `p` on((`ct`.`ma_phien` = `p`.`ma_phien`))) join `mau_in` `mi` on((`p`.`ma_mau_in` = `mi`.`ma_mau_in`))) left join `ca_san_xuat` `ca` on((`ct`.`ma_ca` = `ca`.`ma_ca`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_dropdown_loai_giay`
--

/*!50001 DROP VIEW IF EXISTS `v_dropdown_loai_giay`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`OffsetSauin`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_dropdown_loai_giay` AS select distinct `lich_su_in_tem`.`ten_loai_giay` AS `ten_loai_giay` from `lich_su_in_tem` order by `lich_su_in_tem`.`ten_loai_giay` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_dropdown_san_pham`
--

/*!50001 DROP VIEW IF EXISTS `v_dropdown_san_pham`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`OffsetSauin`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_dropdown_san_pham` AS select distinct `lich_su_in_tem`.`ten_san_pham` AS `ten_san_pham`,`lich_su_in_tem`.`ma_code` AS `ma_code` from `lich_su_in_tem` order by `lich_su_in_tem`.`ten_san_pham` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_xuat_in_expanded`
--

/*!50001 DROP VIEW IF EXISTS `v_xuat_in_expanded`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`OffsetSauin`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_xuat_in_expanded` AS with recursive `gen` (`n`) as (select 1 AS `1` union all select (`gen`.`n` + 1) AS `n + 1` from `gen` where (`gen`.`n` < 1000)) select `ct`.`ma_phien` AS `ma_phien`,`ct`.`ma_chi_tiet` AS `ma_chi_tiet`,`ct`.`stt` AS `stt_cau_hinh`,`g`.`n` AS `thu_tu_nhan`,`ct`.`ten_san_pham` AS `ten_san_pham`,`ct`.`ma_code` AS `ma_code`,concat(`ct`.`so_phieu`,'/',`ct`.`nam_phieu`,'/',`ct`.`chi_nhanh`) AS `phieu_san_pham`,`ct`.`ten_loai_giay` AS `ten_loai_giay`,`ct`.`so_luong_san_pham` AS `so_luong_san_pham`,`ca`.`ten_ca` AS `ten_ca`,`ct`.`ngay_san_xuat` AS `ngay_san_xuat`,`ct`.`nguoi_kiem` AS `nguoi_kiem`,`ct`.`nguoi_dong_goi` AS `nguoi_dong_goi`,(((`g`.`n` - 1) % `ct`.`so_trang`) + 1) AS `so_trang_hien_tai` from ((`chi_tiet_in_tem` `ct` left join `ca_san_xuat` `ca` on((`ct`.`ma_ca` = `ca`.`ma_ca`))) join `gen` `g` on((`g`.`n` <= `ct`.`so_luong_nhan`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-07 17:35:11
