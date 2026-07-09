# LabelPrint — Template & Print Engine

## Thông số phôi in thực tế
- Khổ giấy: **Letter 215.9 × 279.4mm** (hoặc A4 210×297mm)
- CSS `@page`: dùng `size:215.9mm 279.4mm` (mm cụ thể, **không dùng "Letter"** — Chrome tự scale 93% nếu máy in đặt A4)
- Lề trên thực đo: **~5mm**, lề dưới: **~5.5mm**
- `CaoNhan` (hiển thị): **~60.8mm**
- `BuocHang` (bước hàng thực tế): **~70mm**

---

## CauHinhModels.cs (Models/JsonModels/)

### CauHinhTruong — config 1 field
```csharp
X, Y (mm), Font, CoChu (pt)
InDam, InNghieng (bool)
CanChinh ("left"|"center"|"right")
MauChu (#hex), HienThi, HienThiNhan (bool)
Nhan (string prefix label)
```

### LayoutMauIn — config bố cục tờ giấy
```csharp
RongNhan, CaoNhan       // kích thước 1 ô tem (mm)
SoHang, SoCot           // số hàng × cột trên 1 tờ
RongTrangMm, CaoTrangMm // kích thước tờ giấy (mm)
LeTren, LeDuoi, LeTrai, LePhai  // lề (mm)
KhoangCachNgang         // gap ngang giữa các cột (mm)
KhoangCachDoc           // gap dọc mặc định (fallback)
GapDocVung (List<double>?) // gap dọc từng vùng (index=0: gap hàng1-2, v.v.)
BuocHang (double?)      // bước hàng thực tế đo từ phôi
```

**`TinhTopMm(row)`** — tính tọa độ top của hàng row (0-based):
```csharp
// Nếu BuocHang có giá trị:
y = LeTren + row * BuocHang + Σ GapDocVung[0..row-1]
// Fallback (template cũ không có BuocHang):
y = LeTren + Σ(CaoNhan + LayGapDoc(r)) for r in 0..row-1
```

### CauHinhMauIn — toàn bộ config 1 template
```csharp
Layout (LayoutMauIn)
TenSanPham, MaCode, PhieuSanPham, TenLoaiGiay
SoLuong, TenCa, NgaySanXuat
NguoiKiem, NguoiDongGoi, Stt
```
Serialize/deserialize qua `ToJson()` / `FromJson(string?)` — lưu vào cột `mau_in.cau_hinh_truong`

**`AllFields()`** trả list `(Key, Label, Config)` dùng trong editor.

---

## Print Engine (Services/Services.cs — PrintService)

### ExpandLabels — cho in mới (nhiều sản phẩm)
1. Expand tất cả chi tiết → LabelItem list, **STT toàn cục 1→N**
2. Sắp theo chồng slot: chia danh sách STT liên tục thành `soNhan` chồng theo từng vị trí trên tờ.
3. Render từng lớp/tờ từ các chồng slot; nếu dữ liệu không đủ slot ở tờ cuối thì chèn `LabelItem.LaTrong=true` để giữ vị trí trống, không dồn tem sang slot khác.

> Kết quả: sau khi cắt cả tập tem theo slot và xếp chồng, STT đi đúng 1→N kể cả khi tổng tem không chia hết cho số nhãn/trang.

### ExpandFromLichSu — cho in lại (1 sản phẩm từ lịch sử)
- `Enumerable.Range(1, Math.Max(1, soLuongNhan))` — guard tránh count=0
- STT 1→N rồi dùng cùng thuật toán chồng slot như in mới; lịch sử không bị sửa số lượng, phần thiếu ở tờ cuối là ô trống.

### Số lượng tem khi tạo mới
- Khi thêm dòng mới, `so_luong_nhan` được làm tròn lên bội số của `mau_in.so_nhan_moi_trang` ngay trong `ChiTietRepository.ThemAsync` transaction. Lịch sử sau khi chốt in sẽ lưu đúng số đã làm tròn.
- Client `/PhienIn/Index` cũng làm tròn khi user nhập trực tiếp `Số lượng tem cần in` hoặc khi tính từ PSP, nhưng server/repository vẫn là lớp bảo vệ cuối.

---

## Views/MauIn/Editor.cshtml — preview editor

- Preview editor chỉ là khung xem/chỉnh, không dùng để quyết định kích thước in thật.
- `labelCanvas` dùng `currentScale` động để fit vào khung preview cố định; dữ liệu layout vẫn lưu theo mm thật (`rong_nhan`, `cao_nhan`, X/Y field).
- Khi scale preview, phải scale đồng bộ: kích thước canvas, vị trí field, font-size preview, max-width fit/wrap, clamp top và quy đổi kéo-thả px → mm. Không dùng lại hằng số px/mm cố định cho một phần riêng lẻ.
- Layout editor bước 1 dùng grid 3 cột: trái là danh sách/thông tin mẫu, giữa là preview, phải là danh sách field + property panel. Các `id` JS (`fieldList`, `propPanel`, `labelCanvas`, input property/layout...) phải giữ nguyên khi refactor tiếp.
- Cập nhật 2026-07-09: `Căn X nhóm trường chính` chuyển sang panel cấu hình bên phải, chỉ còn nhập `X mới` + `Áp dụng X`; bỏ UI/function `Bước dịch`. `Bù sai số từng hàng` chuyển vào trong card `Layout tờ giấy & bù sai số`. CSS grid cho `.editor-inspector` span `grid-row: 1 / 3`, còn `.editor-layout-row` chỉ span cột trái + preview (`grid-column: 1 / 3`) để card layout không bị kéo xuống theo chiều cao panel phải.
- Cập nhật bổ sung: để giảm khoảng trống dưới `Thông tin mẫu`, giữ preview là khung cố định nhưng giảm `#canvasWrap` xuống 260px và dùng `gap: 6px 12px` cho editor grid. Với tem 92 x 59.9mm vẫn đủ hiển thị ở scale thật; template cao hơn sẽ tự scale nhỏ trong khung preview.

---

## Views/PhienIn/Print.cshtml

### Cấu trúc HTML
```
.ctrl (thanh điều khiển, sticky, ẩn khi print)
.pages
  .label-page (1 tờ giấy)
    .label-cell (1 ô tem, position:absolute)
      span.fit-ten-sp
      span.fit-nguoi-dong-goi
      span (các field khác)
```

### CSS quan trọng
```css
.label-cell {
    position: absolute;
    border: none;           /* ← border:none khi in, border chiếm không gian */
    overflow: hidden;
    box-sizing: content-box; /* ← PHẢI là content-box, border-box làm chữ bị cắt */
}
.label-page:not(:last-child) { page-break-after: always; } /* ← tránh trang trắng cuối */
@page { size: 215.9mm 279.4mm; margin: 0; }
```

### JS Auto-fit font (fitWithBottomAnchor)
Hằng số:
```javascript
const WRAP_SHIFT_MM      = -1.5;  // dịch khối 2 dòng lên (mm)
const WRAP_AT_PT         = 9;     // ngưỡng pt cho phép wrap
const MIN_PT             = 6;     // pt nhỏ nhất
const PX_PER_MM          = 96 / 25.4;
const PT_TO_MM           = 0.3528;
const LINE_HEIGHT_FACTOR = 1.2;
const TOLERANCE_PX       = 5;     // dung sai tránh false-positive sub-pixel
```

Logic:
1. Co font từ basePt → WRAP_AT_PT nếu `scrollWidth > fixedWidth + TOLERANCE_PX`
2. Vẫn tràn ở WRAP_AT_PT → wrap 2 dòng, neo đáy bằng `top` offset
3. Không wrap → co tiếp xuống MIN_PT

**Quan trọng**: `fixedWidth` lấy từ `data-max-width-mm` (tính từ Razor), **không đo `el.offsetWidth`** (sẽ sai vì span không có giới hạn width).

### NguoiDongGoiTruncateRightMm
Field riêng trong `CauHinhMauIn` — giới hạn độ rộng `nguoi_dong_goi` để không đè STT.

---

## WYSIWYG Editor (Views/MauIn/Editor.cshtml)

- CSS Grid 2 cột: trái (danh sách mẫu + info) | phải (canvas + field list + property panel)
- Drag-drop field token trên canvas preview
- Real-time sync: kéo token → cập nhật X/Y input → re-render
- Lưu: serialize `CauHinhMauIn` → JSON → POST `/MauIn/Luu`
- **`currentMauIn`** là biến JS (không hardcode Razor) → có thể đổi template không cần reload
