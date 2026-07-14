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

## Historical changes pending classification

Legacy `MEMORY/` và Git history chứa completed-change candidates nhưng chưa được promote thành Changelog entries riêng. Mỗi entry cần review provenance, completion evidence và user impact trước khi được ghi ở đây.
