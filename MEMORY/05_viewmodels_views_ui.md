# LabelPrint — ViewModels, Views & UI Patterns

## ViewModels (Models/ViewModels/ViewModels.cs)

### NhapLieuVM — trang nhập liệu chính
```csharp
MaPhien, MauIn (MauIn?)
TenSanPham, MaCode, SoPhieu, NamPhieu, ChiNhanh
TenLoaiGiay, SoLuongSanPham, SoLuongNhan
MaCa (int?), NgaySanXuat (string?), NguoiKiem, NguoiDongGoi
DsSanPham, DsLoaiGiay, DsCa, DsMauIn  // dropdowns
ChiNhanhMacDinh, StickyNamPhieu, StickyChiNhanh  // sticky fields
DsChiTiet (List<ChiTietInTem>)
TongNhan, TongTrang  // computed
```

### ThemChiTietRequest — body POST /PhienIn/ThemDong
Gồm tất cả field nhập liệu + `LoaiTao` ("moi"|"copy") + `MaLichSuGoc`

### PrintPreviewVM
```csharp
MauIn, CauHinh (CauHinhMauIn), Labels (List<LabelItem>)
LaInLai, MaPhien, MaLichSu  // phân biệt in mới/in lại và xác nhận đúng endpoint từ preview
```

### LabelItem
```csharp
TenSanPham, MaCode, PhieuSanPham, TenLoaiGiay
SoLuong, TenCa, NgaySanXuat, NguoiKiem, NguoiDongGoi, Stt
```

### LichSuVM
```csharp
TuNgay, DenNgay, Keyword, TenMay  // filter params
DsLichSu (List<LichSuInTem>)
ThongKe (List<ThongKeSanPhamVM>)
```

### MauInEditorVM
```csharp
MauIn, CauHinh (CauHinhMauIn), DsMauIn (List<MauIn>), IsNew (bool)
```

---

## Views quan trọng

### PhienIn/Index.cshtml
- 2 cột: form nhập liệu (col-xl-5) | bảng danh sách (col-xl-7)
- Dropdown đổi template: `DoiMauInAsync` qua AJAX → cập nhật `soTrang` từng dòng + `soNhanMoiTrang` JS
- Auto-fill: nhập `soLuongPSP` → tính `soLuongNhan = CEIL(CEIL(PSP/SP) / soNhanMoiTrang) * soNhanMoiTrang`
- `copyData` qua `ViewBag.CopyData` (JSON) → prefill form khi Copy
- Click dòng trong danh sách tem → đổ dữ liệu lên form để xem lại, highlight dòng, disable `Thêm vào danh sách`; muốn sửa phải xóa dòng đang xem rồi chỉnh/thêm lại.
- `Xác nhận in` chỉ mở preview, không chốt phiên; `In ngay` trong preview mới gọi chốt phiên.
- Trước khi sang preview, modal `Xác nhận in` rà toàn bộ dòng trong danh sách; nếu có dòng chưa chọn ca, chưa chọn ngày sản xuất, hoặc ngày sản xuất khác hôm nay thì hiển thị cảnh báo theo STT/tên SP. Cảnh báo không chặn cứng: user có thể `Quay lại kiểm tra` hoặc `Vẫn sang preview`.
- Warning ca sản xuất: chưa chọn ca → badge/text `Chưa chọn`, select warning.
- Warning ngày sản xuất: dùng datepicker custom nội bộ, ô user nhìn thấy luôn là `dd/mm/yyyy`; popup có `Hôm nay` và `Xóa`; hidden field `ngaySanXuatIso` giữ ISO `yyyy-MM-dd` để POST lên server. Rỗng → `Chưa chọn`; khác hôm nay → `Khác hôm nay`, hiển thị badge/text cảnh báo cạnh label và input warning.

**JS helpers:**
```javascript
const G   = id => document.getElementById(id);
const V   = id => (G(id)?.value ?? '').trim();
const SV  = (id, v) => { ... };
const IV  = id => parseInt(G(id)?.value) || 0;
const IVN = id => { const x = V(id); return x ? +x : null; }; // trả null nếu rỗng
const POST = async (u, d) => fetch(u, { method:'POST', ... }).then(r=>r.json());
```

### LichSu/Index.cshtml
- Tab 1: Danh sách (filter theo ngày/keyword/máy) + nút Copy, In lại, Xóa mỗi row
- Tab 2: Thống kê theo sản phẩm
- Sticky header: `position:sticky` trên `thead th` + **wrapper `max-height:75vh; overflow-y:auto`** (không dùng `.table-responsive` — bị conflict)
- Auto-fit cột: `white-space:nowrap` cho mã code, phiếu SP, loại giấy
- Nút Xóa: AJAX POST `/LichSu/Xoa`, xóa `<tr>` khỏi DOM sau khi thành công
- Xuất Excel: href `/LichSu/XuatExcel` cập nhật real-time theo filter
- Filter ngày trong lịch sử: dùng cùng datepicker custom; ô user nhìn thấy là `dd/mm/yyyy`, popup có `Hôm nay` và `Xóa`, hidden field `tuNgay`/`denNgay` vẫn gửi ISO `yyyy-MM-dd` cho controller và link xuất Excel.

### LichSu/TimKiem.cshtml
- Tìm kiếm gần đúng (LIKE) theo tên SP / mã code / phiếu
- Nút Copy từ kết quả tìm kiếm

### MauIn/Editor.cshtml
- CSS Grid 2 cột
- Canvas preview WYSIWYG + drag-drop field token
- Property panel (ẩn khi chưa chọn field, `opacity:0.45 pointer-events:none`)
- Lưu template: serialize form → JSON → POST

---

## UI Patterns & Gotchas

### Sticky Header trong bảng cuộn
```css
/* ĐÚNG: wrapper div thay vì .table-responsive */
<div style="max-height:75vh; overflow-y:auto; overflow-x:auto">
  <table class="table-sticky">

.table-sticky thead th {
    position: sticky; top: 0; z-index: 10;
    background-color: #f8f9fa !important;
    box-shadow: 0 1px 0 #dee2e6; /* thay border-bottom bị mất khi sticky */
}
```
> `.table-responsive` dùng `overflow:auto` cả 2 chiều → phá `position:sticky`

### Razor Tag Helper — tránh RZ1031
```razor
@* SAI — ternary trong attribute *@
<button disabled="@(count == 0 ? "disabled" : "")">

@* ĐÚNG — dùng @if *@
<button @if(count == 0) { <text>disabled</text> }>
```

### parseFloat bẫy giá trị 0
```javascript
// SAI
const val = parseFloat(input.value) || defaultVal; // val=0 → dùng default!

// ĐÚNG
const raw = parseFloat(input.value);
const val = isNaN(raw) ? defaultVal : raw;
```

### Template switching
- `currentMauIn` và `soNhanMoiTrang` là biến JS — không hardcode từ Razor
- Sau `DoiMauIn`: cập nhật `soNhanMoiTrang` từ response → re-trigger `tinhSoLuongNhan()`
- Cập nhật `soTrang` từng row từ `payload.soTrang` dict

### Enumerable.Repeat với count=0
```csharp
// SAI — trả empty khi SoLuongNhan=0
Enumerable.Repeat(label, SoLuongNhan)

// ĐÚNG
Enumerable.Repeat(label, Math.Max(1, SoLuongNhan))
// hoặc dùng Range như PrintService.ExpandFromLichSu:
Enumerable.Range(1, Math.Max(1, ls.SoLuongNhan))
```

### @page CSS — tránh Chrome scale
```css
/* SAI — Chrome scale 93% khi máy in đặt A4 */
@page { size: Letter; margin: 0; }

/* ĐÚNG */
@page { size: 215.9mm 279.4mm; margin: 0; }
```

### MauIn mới + LaMacDinh
```csharp
// INSERT trước (false), SET mặc định sau (khi đã có ID)
var laMacDinh = m.LaMacDinh;
m.LaMacDinh   = false;
var id = await repo.ThemAsync(m);
if (laMacDinh) await repo.SetMacDinhAsync(id);
```

### ChuanBiCopy — template gốc
```csharp
// Dùng template gốc (MaMauIn từ lịch sử), fallback mặc định nếu đã xóa
MauIn? mauInGoc = null;
if (ls.MaMauIn.HasValue)
    mauInGoc = await mauInRepo.LayTheoIdAsync(ls.MaMauIn.Value);
var vm = mauInGoc != null
    ? await KhoiTaoPhienVoiMauInAsync(mauInGoc)
    : await KhoiTaoPhienAsync();
```
