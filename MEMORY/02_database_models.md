# LabelPrint — Database & Domain Models

## Bảng DB chính (payroll_db)

| Bảng | Mục đích |
|------|---------|
| `phien_in_tem` | Quản lý phiên in (trạng thái: nhap / da_in / huy) |
| `chi_tiet_in_tem` | Chi tiết từng loại tem trong phiên |
| `mau_in` | Template in — JSON config lưu vào cột `cau_hinh_truong` |
| `lich_su_in_tem` | Lịch sử in (sau khi đóng phiên qua stored procedure) |
| `ca_san_xuat` | Ca sản xuất |
| `cau_hinh_he_thong` | Cấu hình key-value toàn hệ thống |
| `v_dropdown_san_pham` | View dropdown sản phẩm |
| `v_dropdown_loai_giay` | View dropdown loại giấy |

## Stored Procedure
- **`sp_dong_phien(@maPhien, @tenMay)`** — đóng phiên + chuyển dữ liệu sang `lich_su_in_tem`
- Gọi trong transaction có `FOR UPDATE` để chống race condition LAN

## Domain Models (Models/DomainModels.cs)

### PhienInTem
```csharp
MaPhien, MaMauIn, TongSoNhan, TongSoTrang
TrangThai ("nhap" | "da_in" | "huy")
GhiChu, TenMayTinh, NgayTao
```

### ChiTietInTem
```csharp
MaChiTiet, MaPhien, Stt
TenSanPham, MaCode, SoPhieu, NamPhieu, ChiNhanh
TenLoaiGiay, SoLuongSanPham, SoLuongNhan
SoLuongPsp (int?), GhiChu (string?)   // ← thêm sau
SoTrang, MaCa (int?), NgaySanXuat (DateOnly?)
NguoiKiem, NguoiDongGoi, LoaiTao ("moi"|"copy"), MaLichSuGoc (int?)
NgayTao, TenCa (join từ ca_san_xuat)
PhieuSanPham (computed: $"{SoPhieu}/{NamPhieu}/{ChiNhanh}")
```

### LichSuInTem
```csharp
MaLichSu, MaPhien, Stt
TenSanPham, MaCode, PhieuSanPham, TenLoaiGiay
SoLuongSanPham, SoLuongNhan
SoLuongPsp (int?), GhiChu (string?)   // ← thêm sau
TenCa, NgaySanXuat (DateOnly?), NguoiKiem, NguoiDongGoi
MaMauIn (int?), TenMauIn, KhoGiay     // ← để reprint dùng đúng template gốc
TenMayTinh, SoLanInLai, ThoiGianTaoTem
```

### MauIn
```csharp
MaMauIn, TenMau, KhoGiay ("letter"|"a4")
SoNhanMoiTrang, CauHinhTruong (JSON string)
LaMacDinh (bool), GhiChu, NgayTao, NgayCapNhat
```

### CaSanXuat
```csharp
MaCa, TenCa, ThuTu (int?), TrangThai (int, 1=active)
```

### CauHinhHeThong
```csharp
MaCauHinh, Khoa, GiaTri, MoTa, NgayCapNhat
```
Các khóa đang dùng: `ten_cong_ty`, `chi_nhanh_mac_dinh`

## DateOnly TypeHandler
Bắt buộc đăng ký vì Dapper không tự map `DateOnly` từ MySQL:
```csharp
// Models/DomainModels.cs
public class DateOnlyTypeHandler : SqlMapper.TypeHandler<DateOnly> { ... }

// Program.cs
Dapper.SqlMapper.AddTypeHandler(new DateOnlyTypeHandler());
```

## Lưu ý SQL
- `XoaAsync` chi tiết dùng user variable: `SET @r=0; UPDATE ... SET stt=(@r:=@r+1)` → cần `Allow User Variables=True` trong connection string
- `DongPhienAsync` dùng transaction + `FOR UPDATE` chống race condition
