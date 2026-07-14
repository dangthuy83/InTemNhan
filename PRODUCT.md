# PRODUCT.md

> Single Source of Truth cho Product Requirement, product scope và intended behavior của LabelPrint.

## Metadata

- Trạng thái tài liệu: Under Review.
- Product authority: Đỗ Đăng Thủy.
- Cập nhật gần nhất: `2026-07-13`.
- Review gần nhất: `2026-07-13`.

## Product vision

LabelPrint là ứng dụng in tem nhãn sản xuất trên phôi in sẵn trong môi trường nội bộ, thay thế phần mềm in tem nhãn cũ không còn phù hợp.

## Problem statement

Phần mềm in tem nhãn cũ không còn phù hợp với nhu cầu vận hành hiện tại. Project cung cấp ứng dụng thay thế để Tổ quản lý thủ công thao tác in tem nhãn bằng trình duyệt trong mạng LAN nội bộ.

## Target users and stakeholders

| Nhóm | Nhu cầu hoặc trách nhiệm | Authority liên quan |
|---|---|---|
| Tổ quản lý thủ công | Người dùng chính thao tác in tem nhãn sản xuất | Người dùng nghiệp vụ |
| Đỗ Đăng Thủy | Xác nhận Product, Design, Decision, Roadmap, Task và Release | Product authority và Project owner |

## Goals

Chưa quyết định. Không suy goals từ implementation, Git history hoặc legacy memory.

## Non-goals

Chưa quyết định. Không tự coi chức năng chưa có trong source code là ngoài phạm vi sản phẩm.

## Product scope

### In scope đã xác nhận

- In tem nhãn sản xuất trên phôi in sẵn.
- Tổ quản lý thủ công thao tác bằng trình duyệt.
- Vận hành trong mạng LAN nội bộ tại nơi sản xuất.

### Out of scope

Chưa quyết định.

## Functional requirements and capabilities

Chưa có bộ Product Requirements được authority phân loại đầy đủ. Các chức năng tồn tại trong source code là implemented capabilities; chúng không tự trở thành Accepted Product Requirements.

## Behavioral rules

### BR-001 — In lại sử dụng template hiện hành

Khi in lại từ lịch sử, hệ thống sử dụng template hiện tại gắn với `ma_mau_in` để phù hợp với phôi in hiện hành.

### BR-002 — Fallback template

Khi lịch sử không có `ma_mau_in` hoặc template gốc đã bị xóa, hệ thống sử dụng cơ chế fallback sang template mặc định.

### BR-003 — Ghi nhận số lần in lại

Hệ thống hiện ghi nhận số lần in lại. Lịch sử chi tiết của từng lần in lại chưa được triển khai; nếu cần trong tương lai phải có thiết kế và xác nhận DB/schema riêng.

Nguồn authority cho ba behavior trên: [D-001](DECISIONS.md#d-001--in-lại-sử-dụng-template-hiện-hành).

## Product-level acceptance expectations

Chưa quyết định.

## Assumptions and product constraints

| ID | Loại | Nội dung | Trạng thái | Nguồn |
|---|---|---|---|---|
| PC-001 | Product constraint | Hoạt động trong mạng LAN nội bộ tại nơi sản xuất | Confirmed | Product authority |
| PC-002 | Product constraint | Người dùng thao tác bằng trình duyệt | Confirmed | Product authority |
| PC-003 | Product constraint | Ứng dụng và MySQL chạy trên một máy nội bộ | Confirmed | Product authority |
| PC-004 | Product constraint | Output phải dùng được với phôi in sẵn | Confirmed | Product authority |

## User journey

Chưa được Product authority mô tả đầy đủ. Không suy user journey từ Razor Views hoặc controller endpoints.

## Open product gaps

| ID | Gap | Criticality | Resolution owner | Next action |
|---|---|---|---|---|
| PG-001 | Product goals chưa quyết định | Required trước planning dựa trên goals | Đỗ Đăng Thủy | Clarify |
| PG-002 | Non-goals chưa quyết định | Supporting; có thể blocking khi cần giới hạn scope | Đỗ Đăng Thủy | Clarify |
| PG-003 | Product-level acceptance expectations chưa quyết định | Required trước acceptance review toàn sản phẩm | Đỗ Đăng Thủy | Clarify |
| PG-004 | Behavior hiện hữu chưa được phân loại đầy đủ | Required theo từng delivery task | Đỗ Đăng Thủy | Review source và xác nhận từng behavior |

## Traceability

- Current Design: [DESIGN.md](DESIGN.md).
- Product Decisions: [DECISIONS.md](DECISIONS.md).
- Delivery Roadmap: [ROADMAP.md](ROADMAP.md).
- Actionable Tasks: [TASKS.md](TASKS.md).

## Ownership boundary

Source code, configuration và legacy `MEMORY/` chỉ hỗ trợ xác minh implemented hoặc historical state. Chúng không tự thay intended Product behavior trong file này.
