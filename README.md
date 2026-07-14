# LabelPrint

> Ứng dụng in tem nhãn sản xuất trên phôi in sẵn, phục vụ Tổ quản lý thủ công trong mạng LAN nội bộ.

## Trạng thái

- Lifecycle: Đang phát triển và tiếp tục hoàn thiện.
- Current state: Ứng dụng cơ bản đáp ứng nhu cầu ban đầu và đã được triển khai thực tế.
- Exact deployed application commit: `f6432734ccc979dd6d8646debd6d0d54d1e2b24f`.
- Current documentation-migration baseline: `92fac6a21ae4f3f18739b06babb24925251bea2f`.
- Project owner: Đỗ Đăng Thủy.
- Review gần nhất: `2026-07-13`.

Commit migration baseline chỉ thêm `.gitmodules` và gitlink của Framework; không có application-file diff so với deployed application commit. Framework không phải runtime dependency của ứng dụng.

## Quick Start

Technical Baseline Verification được thực hiện ngày `2026-07-14` tại exact HEAD `88542d440c5b9dfabbf875866025ba0d9f277c69`:

| Command | Trạng thái | Ghi chú |
|---|---|---|
| `dotnet restore` | Verified | Exit code `0`, `0` warnings, `0` errors; packages đã up-to-date. Chưa chứng minh network download/cache-cold restore. |
| `dotnet build` | Verified | Exit code `0`, `0` warnings, `0` errors; tạo `build/bin/Debug/net8.0/LabelPrint.dll`. Đây không phải runtime hoặc release verification. |
| `dotnet run` | Unverified | Phải xác định đúng environment trước khi chạy; kết nối database thật cần approval riêng. |
| `dotnet test` | Not configured | Chưa phát hiện test project. |

Không chạy application, kết nối database thật hoặc thực thi schema production nếu chưa đáp ứng permission trong [AGENTS.md](AGENTS.md).

## Môi trường vận hành

- Mạng LAN nội bộ tại nơi sản xuất.
- Người dùng thao tác bằng trình duyệt.
- Ứng dụng và MySQL chạy trên một máy nội bộ.
- Các máy người dùng truy cập ứng dụng qua LAN.
- Credential, raw connection string, internal IP và hostname không được ghi vào tài liệu.

## Project entry points

- Application startup: `Program.cs`.
- Project definition: `LabelPrint.csproj`.
- Database schema artifact: `database/Schemas.sql`.
- AI working rules: [AGENTS.md](AGENTS.md).
- Legacy knowledge: `MEMORY/` là supporting/historical source, không còn là Project SSOT.

## Framework dependency

- Path: `.ai-development-framework/`.
- Repository: <https://github.com/dangthuy83/AI-Development-Framework.git>.
- Pinned commit: `804aea8d024b760ef853f1d5a182e5cc176d0990`.
- Không mô tả pin này là `latest` và không fetch/update nếu chưa được phép.

## Document Map

| Câu hỏi | Nguồn chuẩn |
|---|---|
| Sản phẩm phải làm gì và hành vi mong muốn là gì? | [PRODUCT.md](PRODUCT.md) |
| Hệ thống hiện hành được thiết kế thế nào? | [DESIGN.md](DESIGN.md) |
| Milestone và dependency là gì? | [ROADMAP.md](ROADMAP.md) |
| Vì sao lựa chọn được chấp thuận? | [DECISIONS.md](DECISIONS.md) |
| Current focus, blocker và next action là gì? | [WORKING_CONTEXT.md](WORKING_CONTEXT.md) |
| Việc cụ thể nào cần làm? | [TASKS.md](TASKS.md) |
| Đã hoàn thành hoặc triển khai gì? | [CHANGELOG.md](CHANGELOG.md) |
| AI Agent phải làm việc thế nào? | [AGENTS.md](AGENTS.md) |

## Frontend entry

- Frontend scope và design: [DESIGN.md#frontend-design](DESIGN.md#frontend-design).
- Frontend working rules: [AGENTS.md#frontend-working-rules](AGENTS.md#frontend-working-rules).

## Bảo trì tài liệu

README là entry point và document map, không thay thế Product, Design, Decisions, Tasks hoặc Working Context. Chỉ cập nhật trạng thái, Quick Start hoặc link sau khi có evidence phù hợp.
