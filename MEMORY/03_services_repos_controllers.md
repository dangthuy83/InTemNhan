# LabelPrint — Services, Repositories, Controllers

## Repositories (Data/Repositories/)

### IPhienInRepository / PhienInRepository
| Method | Mô tả |
|--------|-------|
| `TaoPhienMoiAsync(maMauIn, tenMay)` | INSERT phien_in_tem, trả về entity |
| `LayPhienAsync(maPhien)` | SELECT by PK |
| `DongPhienAsync(maPhien, tenMay)` | Transaction + FOR UPDATE + CALL sp_dong_phien |
| `HuyPhienAsync(maPhien)` | UPDATE trang_thai='huy' |
| `CapNhatMauInAsync(maPhien, maMauIn)` | Đổi template + cập nhật so_trang tất cả chi tiết |

### IChiTietRepository / ChiTietRepository
| Method | Mô tả |
|--------|-------|
| `LayDsAsync(maPhien)` | SELECT JOIN ca_san_xuat, ORDER BY stt |
| `ThemAsync(ct)` | INSERT + LAST_INSERT_ID |
| `XoaAsync(maChiTiet, maPhien)` | DELETE + renumber STT (dùng @r user variable) |
| `LaySttTiepTheoAsync(maPhien)` | MAX(stt)+1 |
| `TinhSoTrangAsync(maPhien, soLuongNhan)` | CEIL(soLuongNhan / soNhanMoiTrang) |

### ILichSuRepository / LichSuRepository
| Method | Mô tả |
|--------|-------|
| `TimKiemAsync(keyword)` | LIKE search, LIMIT 200 |
| `LocAsync(tuNgay, denNgay, keyword, tenMay)` | Dynamic SQL, LIMIT 500 |
| `LayTheoIdAsync(maLichSu)` | SELECT by PK |
| `TangLanInLaiAsync(maLichSu)` | UPDATE so_lan_in_lai+1 |
| `ThongKeAsync()` | GROUP BY ten_san_pham, ma_code, LIMIT 100 |
| `XoaAsync(maLichSu)` | DELETE hard — thêm sau |

### IMauInRepository / MauInRepository
| Method | Mô tả |
|--------|-------|
| `LayMacDinhAsync()` | WHERE la_mac_dinh=1 |
| `LayTheoIdAsync(maMauIn)` | SELECT by PK |
| `LayTatCaAsync()` | ORDER BY la_mac_dinh DESC, ten_mau |
| `ThemAsync(m)` | INSERT |
| `CapNhatAsync(m)` | UPDATE |
| `SetMacDinhAsync(maMauIn)` | UPDATE SET la_mac_dinh=0 rồi SET =1 cho ID chọn |
| `XoaAsync(maMauIn)` | DELETE WHERE la_mac_dinh=0 (không xóa mặc định) |

---

## Services (Services/Services.cs)

### PhienInService
Inject: `IPhienInRepository, IChiTietRepository, ILichSuRepository, IMauInRepository, ICaSanXuatRepository, IDropdownRepository, ICauHinhRepository, IPrintService, MayTinhService`

| Method | Mô tả |
|--------|-------|
| `KhoiTaoPhienAsync(clientIp?)` | Tạo phiên mới với template mặc định |
| `LayPhienAsync(maPhien)` | Build NhapLieuVM từ phiên có sẵn |
| `ChuanBiCopyAsync(maLichSu)` | Tạo phiên mới, prefill từ lịch sử — dùng template gốc nếu còn, fallback mặc định |
| `ThemChiTietAsync(req)` | Validate + tính STT + SoTrang + INSERT |
| `XoaChiTietAsync(maChiTiet, maPhien)` | Delegate to repo |
| `XacNhanInAsync(maPhien, clientIp?)` | Guard không có dòng + CALL sp_dong_phien |
| `DoiMauInAsync(maPhien, maMauIn)` | Đổi template + trả về JSON {soTrang dict, soNhanMoiTrang} |
| `LayDuLieuInAsync(maPhien)` | Build PrintPreviewVM cho in mới |
| `LayDuLieuInLaiAsync(maLichSu)` | Build PrintPreviewVM cho in lại — dùng template gốc, không tăng counter |
| `XacNhanInLaiAsync(maLichSu)` | Xác nhận đã in lại thật sự, tăng `so_lan_in_lai` |

**`BuildBaseVM`** (private helper): load dropdown SP, giấy, ca, danh sách mẫu → trả NhapLieuVM

### PrintService
| Method | Mô tả |
|--------|-------|
| `ExpandLabels(ds, soNhan)` | Expand chi tiết → LabelItem list, STT toàn cục 1→N, sort theo pageKey = (idx % soTrang)+1 |
| `ExpandFromLichSu(ls, soNhan)` | Expand 1 lịch sử → N LabelItem, STT 1→N |

> **pageKey sort**: đảm bảo nhãn cùng vị trí trên tờ (slot 1 tất cả trang, slot 2 tất cả trang...) in liên tiếp đúng thứ tự tờ giấy.

### MauInService
- `LuuAsync`: INSERT mới → nếu LaMacDinh thì SET sau khi có ID (tránh 2 row = 1)
- `XoaAsync`, `SetMacDinhAsync`: delegate to repo

### MayTinhService (Singleton)
- Đọc `may_tinh.json` (danh sách `{ip, tenMay}`) từ `ContentRootPath`
- `LayTenMay(ip)`: map IP → tên máy, fallback về IP nếu không tìm thấy
- `Luu(ds)`: ghi lại file JSON
- **Lý do dùng**: `Environment.MachineName` luôn trả server name trong LAN; cần map IP client → tên máy thực

---

## Controllers (Controllers/Controllers.cs)

### PhienInController
```
GET  Index              → KhoiTaoPhienAsync(RemoteIpAddress)
GET  Tiep(maPhien)      → LayPhienAsync
POST ThemDong           → ThemChiTietAsync
POST XoaDong            → XoaChiTietAsync
POST XacNhan            → XacNhanInAsync(maPhien, RemoteIpAddress)
POST DoiMauIn           → DoiMauInAsync
GET  Print(maPhien)     → LayDuLieuInAsync
GET  InLai(maLichSu)    → LayDuLieuInLaiAsync
POST XacNhanInLai       → XacNhanInLaiAsync
```

### LichSuController
```
GET  Index(tuNgay,denNgay,keyword,tenMay) → LocAsync + ThongKeAsync
GET  TimKiem(keyword)   → TimKiemAsync
GET  Copy(maLichSu)     → ChuanBiCopyAsync → View Index với ViewBag.CopyData
POST Xoa(maLichSu)      → XoaAsync (hard delete) ← thêm sau
```

### MauInController
```
GET  Editor(maMauIn?)   → LayEditorAsync
POST Luu                → LuuAsync
POST SetMacDinh         → SetMacDinhAsync
POST Xoa                → XoaAsync
```

### CaSanXuatController, CauHinhController
- CRUD ca sản xuất (ẩn/hiện thay vì xóa)
- Cấu hình hệ thống + quản lý danh sách máy tính (may_tinh.json)

## Request/Response Records
```csharp
record XoaDongReq(int MaChiTiet, int MaPhien)
record XacNhanReq(int MaPhien)
record DoiMauInReq(int MaPhien, int MaMauIn)
record MaMauInReq(int MaMauIn)
record MaLichSuReq(int MaLichSu)       // ← thêm khi có Xoa lịch sử
record TenCaReq(string TenCa)
record AnHienReq(int MaCa, bool An)
record CauHinhItemReq(string Khoa, string GiaTri)
```

## ApiResult<T>
```csharp
{ bool Success, string Message, T? Data }
ApiResult<T>.Ok(data, msg)
ApiResult<T>.Fail(msg)
```
