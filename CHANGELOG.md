# CHANGELOG.md

> Single Source of Truth cho verified notable completed hoặc deployed outcomes.

## Metadata and convention

- Release authority: Đỗ Đăng Thủy.
- Review gần nhất: `2026-07-13`.
- Chỉ ghi deployment/completion được authority xác nhận hoặc có verification evidence.
- Git history, source code và legacy memory không tự chứng minh release.

## Deployed application

### Application commit `f6432734ccc979dd6d8646debd6d0d54d1e2b24f`

- Status: Deployed.
- Release authority: Đỗ Đăng Thủy.
- Environment: Máy nội bộ phục vụ người dùng qua LAN.
- Exact deployment date: Chưa xác minh.
- Release name/version: Chưa đặt.
- Evidence: Xác nhận trực tiếp của Release authority rằng application deployment dùng commit này.

## Documentation migration baseline

### Baseline commit `92fac6a21ae4f3f18739b06babb24925251bea2f`

- Purpose: Current documentation-migration baseline.
- Difference from deployed application commit: Commit này chỉ thêm `.gitmodules` và gitlink `.ai-development-framework`; không có application-file diff.
- Deployment status: Không dùng commit này làm exact deployed application commit.
- Framework runtime relationship: Framework được thêm sau deployment và không phải runtime dependency.

## Framework dependency provenance

- Path: `.ai-development-framework/`.
- Repository: <https://github.com/dangthuy83/AI-Development-Framework.git>.
- Pinned commit: `804aea8d024b760ef853f1d5a182e5cc176d0990`.

## Completed changes

### `2026-07-15` — Lịch sử in tem hiển thị mẫu in đã sử dụng

- Status: Completed.
- Release/deployment status: Chưa ghi nhận triển khai.
- User impact: Màn hình lịch sử in tem và tìm kiếm tem cũ hiển thị mẫu in sau cột thời gian in, ưu tiên snapshot tên mẫu trong lịch sử và fallback rõ ràng cho dữ liệu cũ thiếu mẫu.
- Scope: Không thêm cột mẫu in vào Excel export.
- Verification: `dotnet build` exit code `0`, `0` warnings, `0` errors.

### `2026-07-15` — Sửa `MauIn/Editor` đổi mẫu mặc định và hiển thị label rỗng

- Status: Completed.
- Release/deployment status: Chưa ghi nhận triển khai.
- User impact: Người dùng có thể lưu/đổi mẫu in mặc định với trạng thái editor nhất quán sau khi lưu; print preview/output vẫn hiển thị tên trường khi field value rỗng nếu cấu hình đã bật hiện tên trường.
- Scope: Không thay đổi schema, không truy cập database thật, không thay đổi physical-print calibration.
- Verification: `dotnet build` exit code `0`, `0` warnings, `0` errors.

## Historical changes pending classification

Legacy `MEMORY/` và Git history chứa completed-change candidates nhưng chưa được promote thành Changelog entries riêng. Mỗi entry cần review provenance, completion evidence và user impact trước khi được ghi ở đây.
