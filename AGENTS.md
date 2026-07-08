# LabelPrint — Hướng dẫn dành cho AI Agent

## 1. Mục đích & Bối cảnh hệ thống
- bạn là 1 Senior ASP.net core MVC, xây dựng ứng dụng in tem nhãn sản xuất, thay thế hệ thống VBA/Excel cũ. 
- Triển khai LAN nội bộ, yêu cầu tốc độ phản hồi nhanh và giao diện tối giản cho công nhân thao tác.

## 2. Tech Stack & Cấu hình bắt buộc
- **Framework:** .NET 8 MVC + Razor Views (Bật Razor Runtime Compilation trong Development).
- **ORM:** Dapper (Sử dụng `MatchNamesWithUnderscores = true` để map tự động `snake_case` từ DB sang `PascalCase` trong Code).
- **Database:** MySQL (`payroll_db`). 
- **Lưu ý Connection String:** Phải luôn đảm bảo có thuộc tính `Allow User Variables=True` vì file `ChiTietRepository.XoaAsync` có sử dụng câu lệnh gán biến `SET @r=0`.
- **Dapper Handlers:** Đã cấu hình `DateOnlyTypeHandler()`, khi viết query MySQL lưu ý kiểu dữ liệu ngày tháng.
- **Frontend:** Bootstrap 5 + Bootstrap Icons (`bi-*`).
- **Thư viện phụ trợ:** ClosedXML (Xuất Excel).

## 3. Cấu trúc thư mục đặc biệt (Đọc kỹ trước khi tạo file mới)
Dự án gom nhóm các Class vào các file chung để tinh gọn, tuyệt đối KHÔNG tự ý tách file nhỏ trừ khi được yêu cầu:
- `/Controllers/Controllers.cs` — Chứa toàn bộ 6 controllers của dự án.
- `/Models/DomainModels.cs` — Chứa tất cả Entity classes + DateOnlyTypeHandler.
- `/Models/JsonModels/CauHinhModels.cs` — Chứa cấu hình JSON (CauHinhTruong, LayoutMauIn...).
- `/Models/ViewModels/ViewModels.cs` — Chứa toàn bộ ViewModels + ApiResult<T>.
- `/Data/Repositories/Interfaces/IRepositories.cs` — Chứa tất cả 7 interfaces.
- `/Data/Repositories/Implementations/Repositories.cs` — Chứa tất cả 7 repository classes.
- `/Services/Services.cs` — Chứa toàn bộ 3 interfaces + 4 service classes.
- `/may_tinh.json` — File lưu trữ runtime map IP → tên máy.

## 4. Nguyên tắc thiết kế & Luồng xử lý (Architecture Pattern)
Luồng đi của dữ liệu bắt buộc tuân theo: **Controller → Service → Repository → DB**.

Khi được yêu cầu làm tính năng mới, AI phải tuân thủ nghiêm ngặt thứ tự triển khai sau:
1. Viết/Cập nhật SQL schema / stored procedure.
2. Thêm class vào `DomainModels.cs`.
3. Khai báo interface trong `IRepositories.cs`.
4. Viết mã xử lý (implementation) trong `Repositories.cs`.
5. Khai báo và viết logic trong `Services.cs`.
6. Cập nhật action trong `Controllers.cs`.
7. Thiết kế giao diện trong thư mục `Views/`.

## 5. Quy định tương tác và giao tiếp với lập trình viên (Working Preferences)
1. **Ngôn ngữ:** Luôn giao tiếp bằng **tiếng Việt**.
2. **Quy trình làm việc:** Luôn phân tích kiến trúc hiện tại, đề xuất phương án và **Xác nhận thiết kế với User trước khi viết code**.
3. **Cập nhật bộ nhớ:** Sau mỗi tính năng lớn được xác nhận hoặc hoàn thành, hãy tóm tắt ngắn gọn để cập nhật lại context (Memory).
4. Không tự ý thay đổi cấu trúc thư mục hoặc tạo file đơn lẻ nếu chưa phân tích ảnh hưởng hệ thống.
