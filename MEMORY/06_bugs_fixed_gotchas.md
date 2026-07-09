# LabelPrint — Bugs đã Fix & Gotchas Kỹ Thuật

## Bugs đã fix (không làm lại)

### 1. box-sizing: border-box → content-box (.label-cell)
**Vấn đề**: `border-box` làm border chiếm không gian trong ô → chữ bị cắt  
**Fix**: `box-sizing: content-box` + `border: none` trong `@media print`

### 2. page-break-after gây trang trắng cuối
**Vấn đề**: `page-break-after: always` áp dụng cả trang cuối → sinh trang trắng  
**Fix**: `.label-page:not(:last-child) { page-break-after: always; }`

### 3. @page size: "Letter" → Chrome scale 93%
**Vấn đề**: Khi máy in đặt A4, Chrome tự scale xuống 93%  
**Fix**: `@page { size: 215.9mm 279.4mm; margin: 0; }` (mm cụ thể)

### 4. parseFloat(value) || default — sai khi value = 0
**Vấn đề**: `parseFloat("0") || 8` trả 8, không phải 0  
**Fix**: `const raw = parseFloat(v); const val = isNaN(raw) ? default : raw;`

### 5. ExpandLabels STT toàn cục
**Vấn đề**: STT từ 1 cho từng sản phẩm riêng, không liên tục  
**Fix**: STT toàn cục 1→N, sort theo `pageKey = (idx % soTrang) + 1`

### 6. currentMauIn hardcode Razor
**Vấn đề**: Sau đổi template, biến Razor vẫn giữ giá trị cũ → không đổi ngược lại được  
**Fix**: Dùng biến JS `let currentMauIn = @(Model.MauIn?.MaMauIn ?? 0);` — update sau mỗi đổi

### 7. DoiMauIn không cập nhật so_trang chi tiết
**Vấn đề**: Sau đổi template, `so_trang` vẫn tính theo `soNhanMoiTrang` cũ  
**Fix**: `CapNhatMauInAsync` UPDATE `so_trang` cho tất cả chi tiết theo template mới

### 8. MayTinhService — Environment.MachineName
**Vấn đề**: `Environment.MachineName` luôn trả tên server, không phải máy client  
**Fix**: Singleton `MayTinhService` đọc `may_tinh.json`, map `RemoteIpAddress → tenMay`
**Cập nhật 2026-07-08**: `RemoteIpAddress` có thể là `::1` khi truy cập app bằng localhost trên chính máy server. `MayTinhService.LayTenMay` đã normalize IP, map IPv4-mapped IPv6 về IPv4, và xử lý `::1`/`127.0.0.1` bằng cách tìm IP LAN local trong `may_tinh.json`; nếu không match thì fallback `Environment.MachineName`, không ghi `::1` vào lịch sử in mới.

### 9. position:sticky conflict với .table-responsive
**Vấn đề**: `thead th { position:sticky }` không hoạt động trong `.table-responsive`  
**Root cause**: `.table-responsive` tạo `overflow:auto` → sticky cần scroll container trực tiếp  
**Fix**: Thay bằng `<div style="max-height:75vh; overflow-y:auto; overflow-x:auto">`  
Thêm: `box-shadow: 0 1px 0 #dee2e6` để thay thế `border-bottom` bị mất

### 10. data-max-width-mm vs offsetWidth
**Vấn đề**: Đo `el.offsetWidth` để set maxWidth cho font-fit — sai vì span không có giới hạn width  
**Fix**: Tính maxWidth từ `data-max-width-mm` (Razor: `layout.RongNhan - field.X`)  
Convert sang px: `fixedWidth = maxWidthMm * (96/25.4)`

### 11. TOLERANCE_PX = 5 — tránh false-positive wrap
**Vấn đề**: Sub-pixel rounding làm `scrollWidth > fixedWidth` khi thực ra text vừa  
**Fix**: `while (scrollWidth > fixedWidth + 5)` — dung sai 5px ≈ 1.3mm

### 12. Enumerable.Repeat count = 0
**Vấn đề**: `Enumerable.Repeat(item, 0)` trả empty sequence  
**Fix**: `Math.Max(1, SoLuongNhan)` hoặc `Enumerable.Range(1, Math.Max(1, count))`

### 13. MauIn mới + LaMacDinh = true
**Vấn đề**: INSERT với `la_mac_dinh=1` → 2 rows đều = 1 nếu SET trước  
**Fix**: INSERT với `false`, sau khi có ID mới gọi `SetMacDinhAsync(id)`

---

## Gotchas MySQL / Dapper

### User Variables (SET @r=0)
Cần `Allow User Variables=True` trong connection string.  
Dùng trong `ChiTietRepository.XoaAsync` để renumber STT.

### DateOnly
MySQL trả `DateTime`, Dapper không tự map `DateOnly` → cần `DateOnlyTypeHandler`.

### MatchNamesWithUnderscores
`Dapper.DefaultTypeMap.MatchNamesWithUnderscores = true` — map `ma_phien → MaPhien` tự động.

### Transaction + FOR UPDATE
`DongPhienAsync` dùng `BeginTransaction` + `FOR UPDATE` để chống 2 client cùng confirm 1 phiên trên LAN.

---

## Gotchas ASP.NET / Razor

### RZ1031 — ternary trong attribute
```razor
@* SAI *@  disabled="@(x ? "disabled" : "")"
@* ĐÚNG *@  @if(x){<text>disabled</text>}
```

### RemoteIpAddress trong LAN
`HttpContext.Connection.RemoteIpAddress?.ToString()` → truyền vào service để map tên máy.  
Truyền qua chuỗi controller → service → `MayTinhService.LayTenMay(ip)`.

### SharedConfigPath (Program.cs)
Hỗ trợ load config từ file ngoài (ShellApp shared config) qua `appsettings.json["SharedConfigPath"]`.  
Nếu file không tồn tại thì fallback về connection string local.

---

## Đo lường thực tế
- Thông số layout (LeTren, BuocHang, GapDocVung) phải đo từ **phôi giấy in thực tế**
- Không tin vào canvas preview đơn thuần — luôn in thử để xác nhận căn chỉnh
- Field Y phải nằm trong `[0, CaoNhan]` — nằm ngoài bị `overflow:hidden` cắt, không có lỗi
## Vấn đề cần xử lý sau review gần nhất

## Cập nhật 2026-07-07 — đã siết transaction phiên in

- Database `payroll_db` đang lưu dữ liệu thật. Khi làm tiếp phải ưu tiên thay đổi code an toàn, không chạy migration/thao tác dữ liệu trực tiếp nếu chưa có xác nhận rõ.
- `chi_tiet_in_tem` trong schema thật đã có `UNIQUE KEY uq_phien_stt (ma_phien, stt)`, dùng làm lớp bảo vệ cuối chống trùng STT.
- `ChiTietRepository.ThemAsync` đã chạy atomic transaction: khóa `phien_in_tem FOR UPDATE`, kiểm tra phiên `nhap`, kiểm tra `so_nhan_moi_trang > 0`, tính `stt` và `so_trang`, rồi insert trong cùng transaction.
- `ChiTietRepository.XoaAsync` đã chạy atomic transaction: khóa phiên, kiểm tra trạng thái, khóa chi tiết trong phiên, xóa dòng, rồi renumber STT. Renumber dùng 2 bước `stt=-stt` sau đó đánh lại 1..N để tránh va chạm unique key trên dữ liệu thật.
- `PhienInRepository.CapNhatMauInAsync` đã chạy atomic transaction: khóa phiên, kiểm tra template hợp lệ, cập nhật `ma_mau_in` và tính lại `so_trang` cho toàn bộ chi tiết trong cùng transaction.
- `PhienInRepository.DongPhienAsync` đã kiểm tra phiên tồn tại, trạng thái `nhap`, và còn dòng chi tiết ngay trong transaction trước khi gọi `sp_dong_phien`.
- `PhienInService.ThemChiTietAsync` không còn tự query rời để lấy STT/tính số trang; repository là nơi quyết định các giá trị này trong transaction.

## Cập nhật 2026-07-07 — đã tách preview và xác nhận in lại

- `LayDuLieuInLaiAsync` chỉ mở preview, không còn tăng `lich_su_in_tem.so_lan_in_lai`.
- Thêm flow xác nhận riêng: `POST /PhienIn/XacNhanInLai` → `PhienInService.XacNhanInLaiAsync` → `ILichSuRepository.TangLanInLaiAsync`.
- `PrintPreviewVM` có `LaInLai` và `MaLichSu` để view phân biệt in mới/in lại.
- `Views/PhienIn/Print.cshtml`: với in lại, preview chỉ còn nút `In ngay`, không có nút đóng/cancel trong toolbar. Nếu user chỉ xem rồi tự tắt tab thì không tăng counter. Khi bấm `In ngay`, JS gọi `POST /PhienIn/XacNhanInLai` để tăng counter rồi mới mở hộp thoại in; `onafterprint` tự đóng tab preview. In mới vẫn giữ nút đóng và in xong tự đóng.
- Giới hạn browser: nếu user bấm `In ngay` rồi Cancel trong hộp thoại in của trình duyệt, hệ thống vẫn đã ghi nhận 1 lần in lại vì browser không cung cấp tín hiệu chắc chắn để phân biệt in thật/cancel.

## Cập nhật 2026-07-07 — xử lý lỗi restore/build do quyền `obj/bin`

- `obj` và `bin` cũ bị quyền Windows khóa, user hiện tại không xóa/chown được dù đã tắt `dotnet build-server`.
- Đã thêm `Directory.Build.props` để chuyển build output sang `build/obj` và `build/bin`, đồng thời loại trừ `obj/**` và `bin/**` cũ khỏi compile.
- Sau thay đổi này, `dotnet restore` và `dotnet build` lệnh thường đã chạy thành công.
- Không xóa được `obj/bin` cũ do ACL/owner, nhưng chúng không còn ảnh hưởng build. Nếu muốn dọn sạch vật lý, cần chạy PowerShell/Explorer bằng account có ownership/admin phù hợp.

## Cập nhật 2026-07-08 — siết review dữ liệu và preview trước khi chốt in mới

- `Views/PhienIn/Index.cshtml`: click dòng trong danh sách tem sẽ đổ dữ liệu lên form để xem lại, highlight dòng, và disable nút `Thêm vào danh sách` để tránh tạo trùng.
- Nếu user muốn sửa dòng đã xem lại, phải xóa dòng đó trong danh sách; sau khi xóa, form giữ dữ liệu vừa xem và nút thêm được enable để chỉnh rồi thêm lại.
- `Xác nhận in` ở module phiên in chỉ chuyển sang preview `/PhienIn/Print?maPhien=...`, chưa gọi `XacNhanInAsync`, chưa đóng phiên.
- Trước khi chuyển preview, modal `Xác nhận in` rà các dòng trong bảng bằng `data-ma-ca` và `data-ngay-san-xuat`; nếu thiếu ca, thiếu ngày, hoặc ngày khác hôm nay thì liệt kê cảnh báo theo STT/tên SP. Đây là warning nghiệp vụ, không chặn cứng; user có thể quay lại kiểm tra hoặc vẫn sang preview.
- `Views/PhienIn/Print.cshtml`: với in mới, preview có nút `Quay lại` về `/PhienIn/Tiep?maPhien=...`; chỉ bấm `In ngay` mới gọi `POST /PhienIn/XacNhan` để chốt phiên rồi mở hộp thoại in.
- Cảnh báo ca sản xuất: nếu chưa chọn ca thì hiện badge/text `Chưa chọn`, đổi viền/nền select sang warning.
- Cảnh báo ngày sản xuất: dùng datepicker custom nội bộ thay cho native `input type="date"` để ô user nhìn thấy luôn là `dd/mm/yyyy` và vẫn chọn bằng lịch. Popup có nút `Hôm nay` và `Xóa`. Nếu ngày rỗng thì cảnh báo `Chưa chọn`; nếu khác hôm nay thì cảnh báo `Khác hôm nay`, đổi viền/nền input sang warning và hiển thị text nhắc kiểm tra. Khi gửi server, JS gửi ISO `yyyy-MM-dd` qua hidden field `ngaySanXuatIso`.
- Lưu ý không quay lại native `input type="date"` nếu yêu cầu nghiệp vụ là hiển thị đồng nhất `dd/mm/yyyy`, vì format trong ô phụ thuộc browser/Windows locale. Không đổi sang text nhập tay đơn thuần vì sẽ mất lịch chọn ngày; dùng datepicker custom.
- Filter ngày trong `Views/LichSu/Index.cshtml` cũng dùng datepicker custom; input hiển thị `dd/mm/yyyy`, popup có `Hôm nay` và `Xóa`, hidden field `tuNgay`/`denNgay` vẫn giữ ISO để filter/export không đổi contract.

## Cập nhật 2026-07-08 — thêm validation server-side phiên in

- `PhienInService.ThemChiTietAsync` đã validate server-side trước khi gọi repository: phiên hợp lệ, các trường bắt buộc, năm phiếu 2020-2099, số lượng > 0, `SoLuongPsp`/`MaCa` hợp lệ nếu có, `LoaiTao` chỉ `moi|copy`, copy phải có `MaLichSuGoc`, ngày sản xuất phải đúng format `yyyy-MM-dd` nếu gửi lên.
- `PhienInService.XacNhanInAsync` kiểm tra phiên tồn tại, trạng thái `nhap`, có dòng, và từng dòng không thiếu dữ liệu quan trọng trước khi gọi repository đóng phiên.
- Validation ngày sản xuất không chặn rỗng/khác hôm nay vì UI đã warning nghiệp vụ; server chỉ chặn format sai nếu client gửi giá trị không parse được.

## Cập nhật 2026-07-08 — siết server-side cho nút `In ngay` trong preview

- `POST /PhienIn/XacNhan` vẫn là điểm chốt phiên duy nhất cho in mới; nút `In ngay` trong `Views/PhienIn/Print.cshtml` gọi endpoint này trước khi mở hộp thoại in.
- `PhienInService.XacNhanInAsync` đã kiểm tra lại trước khi đóng phiên: mã phiên hợp lệ, phiên tồn tại, trạng thái còn `nhap`, template còn tồn tại, `so_nhan_moi_trang > 0`, JSON/template layout hợp lệ, `so_nhan_moi_trang` khớp `SoHang * SoCot`, có ít nhất 1 dòng chi tiết, dữ liệu bắt buộc từng dòng không rỗng, số lượng/trang hợp lệ, và `SoTrang` từng dòng khớp `Ceiling(SoLuongNhan / SoNhanMoiTrang)`.
- Server không chặn cứng các warning nghiệp vụ đã thống nhất: thiếu ca sản xuất, thiếu ngày sản xuất, hoặc ngày sản xuất khác hôm nay.
- `PrintService.ExpandLabels` có guard `soNhan <= 0` và trả danh sách rỗng an toàn nếu phiên không có label, tránh chia cho 0.
- Preview hiển thị lỗi chốt phiên bằng hộp cảnh báo ngay trên thanh điều khiển thay vì chỉ `alert`, để user biết cần quay lại sửa dữ liệu/template gì.
- `dotnet build` đã chạy thành công sau thay đổi. Trong môi trường shell hiện tại, lệnh build thường cần quyền ghi output `build/obj`; nếu chạy sandbox thường bị `Access to the path ... LabelPrint.dll is denied`, chạy escalated thì pass.

## Cập nhật 2026-07-08 — sửa nút `Tạo mới` trong `/MauIn/Editor`

- Trước đó nút `Tạo mới` trỏ về `/MauIn/Editor`, nhưng `MauInService.LayEditorAsync(null)` lại mở mẫu đầu tiên trong danh sách. Nếu user đổi tên rồi lưu thì có nguy cơ cập nhật đè mẫu đầu tiên thay vì tạo template mới.
- Nút `Tạo mới` giờ trỏ tới `/MauIn/Editor?taoMoi=true&saoChepTu=<MaMauIn đang chọn>`.
- `MauInService.LayEditorAsync(..., taoMoi:true, saoChepTu:id)` tạo view model mới với `MaMauIn=0`, `TenMau=""`, `LaMacDinh=false`, nhưng copy `KhoGiay`, `SoNhanMoiTrang`, và `CauHinhTruong` từ mẫu nguồn để user không phải nhập lại layout/trường.
- `/MauIn/Editor` không query vẫn giữ hành vi mở mẫu đầu tiên để không đổi thói quen vào module.
- View hiển thị cảnh báo nhỏ khi đang tạo template mới từ cấu hình mẫu đang chọn. `dotnet build` đã pass.

## Cập nhật 2026-07-08 — căn dấu `:` khi bật `Hiện tên trường`

- Không render text theo chuỗi `"Tên trường: Giá trị"` nữa vì dấu `:` không thẳng hàng khi tên trường dài/ngắn khác nhau.
- `Views/MauIn/Editor.cshtml` và `Views/PhienIn/Print.cshtml` render field bật `HienThiNhan` thành 3 span: `.field-prefix`, `.field-colon`, `.field-value`.
- JS `alignLabelPrefixes` gom các field có tọa độ X gần nhau trong tolerance 3mm, đo prefix dài nhất trong từng nhóm, rồi set CSS variable `--prefix-width-px` để các dấu `:` trong cùng nhóm thẳng hàng. Field ở cột/vùng khác được căn riêng để tránh phá layout.
- Logic áp dụng cả preview template và bản in thực tế, chạy lại khi redraw editor và trước khi print. `dotnet build` đã pass 0 warning/0 error.

## Cập nhật 2026-07-08 — chỉnh X hàng loạt nhóm trường chính trong template editor

- `Views/MauIn/Editor.cshtml` thêm cụm điều khiển `Căn X nhóm trường chính` trong phần layout: nhập `X mới`, bấm `Áp dụng X`, hoặc dùng nút mũi tên trái/phải để dịch nhóm theo `Bước dịch`.
- Nhóm chính cố định gồm 8 field: `ten_san_pham`, `ma_code`, `phieu_san_pham`, `ten_loai_giay`, `so_luong`, `ten_ca`, `nguoi_kiem`, `nguoi_dong_goi`.
- Không áp dụng cho `ngay_san_xuat` và `stt` vì 2 field này thường có trục X riêng.
- Thao tác chỉ thay đổi cấu hình trên editor/canvas; muốn lưu vĩnh viễn vẫn phải bấm `Lưu mẫu` như các chỉnh sửa khác. `dotnet build` đã pass 0 warning/0 error.

## Cập nhật 2026-07-09 — tách style tên trường và dữ liệu khi bật `Hiện tên trường`

- `Views/MauIn/Editor.cshtml` và `Views/PhienIn/Print.cshtml` giữ cấu trúc 3 phần `.field-prefix`, `.field-colon`, `.field-value`.
- `.field-prefix` và `.field-colon` luôn in đậm, giữ cỡ chữ gốc của field; style co chữ/wrap không áp lên prefix.
- Với `ten_san_pham` và `nguoi_dong_goi`, fit/truncate chỉ tác động `.field-value`. Khi value dài và wrap, dòng sau nằm trong cột value, tức canh trái sau dấu `:` thay vì quay về đầu dòng.
- Không đổi DB/schema hoặc JSON model. `dotnet build` đã pass 0 warning/0 error.
- Sửa bổ sung: `stt` trong `Views/PhienIn/Print.cshtml` cũng dùng cùng cơ chế prefix/value, nên bật `Hiện tên trường` cho STT sẽ in tên trường. `nguoi_dong_goi` trong editor preview chuyển từ ellipsis một dòng sang wrap value-only để khớp bản in hơn.
- Sửa bổ sung wrap `nguoi_dong_goi`: giới hạn wrap lấy theo X của `stt` đang hiển thị, chừa an toàn 1mm trước STT. Nếu không có STT, STT bị ẩn, hoặc X STT không hợp lệ/không nằm bên phải `nguoi_dong_goi` thì không ép wrap. Tham số JSON cũ `nguoi_dong_goi_truncate_right_mm` vẫn được giữ để tương thích nhưng editor không còn dùng làm biên wrap chính.

### 1. Race condition khi thêm/xóa chi tiết và đổi template — đã xử lý phần code
**Vị trí**: `Services/Services.cs`, `Data/Repositories/Implementations/Repositories.cs`
**Mô tả cũ**: `ThemChiTietAsync`, `XoaAsync`, `CapNhatMauInAsync` có các bước đọc/ghi rời nhau, chưa gom transaction end-to-end. Trên LAN nhiều client có thể sinh trùng `Stt`, lệch `SoTrang`, hoặc cập nhật template không đồng bộ với chi tiết.
**Trạng thái**: đã chốt transaction/lock phiên trong repository và tận dụng `uq_phien_stt` ở DB. Cần theo dõi thực tế nếu còn nguồn ghi khác ngoài app này không khóa `phien_in_tem`.

### 2. Đóng phiên và in lại chưa đủ chặt — đã xử lý phần in lại
**Vị trí**: `Services/Services.cs`, `Data/Repositories/Implementations/Repositories.cs`
**Mô tả cũ**: `XacNhanInAsync` chỉ kiểm tra danh sách có dòng rồi gọi đóng phiên; `LayDuLieuInLaiAsync` tăng `so_lan_in_lai` ngay khi mở preview.
**Trạng thái**: phần in lại đã tách preview/xác nhận. Phần in mới đã có guard repository khi đóng phiên, nhưng vẫn còn cần bàn nghiệp vụ đóng phiên trước hay sau khi in thật.

### 3. Print engine cần guard cho count=0 và wrap 2 dòng
**Vị trí**: `Services/Services.cs`, `Views/PhienIn/Print.cshtml`, `Models/JsonModels/CauHinhModels.cs`
**Mô tả**: `ExpandLabels` cần bảo vệ trường hợp `soNhan <= 0`; `fitWithBottomAnchor` và `TinhTopMm` vẫn có edge case nếu dữ liệu hoặc layout sai.
**Hướng xử lý**: validate đầu vào sớm, clamp layout hợp lệ khi lưu template, và có fallback rõ ràng khi text vẫn tràn sau wrap.

### 4. UI nhập liệu còn phụ thuộc nhiều vào validation phía client
**Vị trí**: `Views/PhienIn/Index.cshtml`, `Views/CauHinh/Index.cshtml`, `Views/MauIn/Editor.cshtml`, `Views/LichSu/Index.cshtml`
**Mô tả**: một số form cho phép nhập thiếu hoặc sai nhưng chỉ báo lỗi chung chung; một số thao tác xóa/lưu không phản hồi đủ rõ khi request thất bại hoặc dữ liệu bị bỏ qua.
**Hướng xử lý**: bổ sung validation server-side theo field, chặn lưu row rỗng, và hiển thị phản hồi nhất quán cho người dùng.

### 5. Bề mặt ghi/xóa chưa có lớp bảo vệ rõ ràng
**Vị trí**: `Program.cs`, `Controllers/Controllers.cs`
**Mô tả**: các endpoint ghi/xóa đang chạy theo mô hình browser trust, chưa thấy auth/anti-forgery; exception handling còn trả lỗi chung trong nhiều nhánh.
**Hướng xử lý**: xác định trust boundary, thêm bảo vệ phù hợp cho thao tác thay đổi dữ liệu, và chuẩn hóa response cho case not found/invalid state.
