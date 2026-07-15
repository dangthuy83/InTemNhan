using Dapper;
using LabelPrint.Data.Repositories.Interfaces;
using LabelPrint.Models;
using LabelPrint.Models.ViewModels;

namespace LabelPrint.Data.Repositories.Implementations;

public class PhienInRepository(IDbConnectionFactory db) : IPhienInRepository
{
    public async Task<PhienInTem> TaoPhienMoiAsync(int maMauIn, string tenMay)
    {
        using var conn = db.CreateConnection();
        var id = await conn.ExecuteScalarAsync<int>(
            "INSERT INTO phien_in_tem (ma_mau_in,ten_may_tinh,trang_thai) VALUES (@maMauIn,@tenMay,'nhap'); SELECT LAST_INSERT_ID();",
            new { maMauIn, tenMay });
        return (await LayPhienAsync(id))!;
    }
    public async Task<PhienInTem?> LayPhienAsync(int maPhien)
    {
        using var conn = db.CreateConnection();
        return await conn.QuerySingleOrDefaultAsync<PhienInTem>(
            "SELECT * FROM phien_in_tem WHERE ma_phien=@maPhien", new { maPhien });
    }
    public async Task DongPhienAsync(int maPhien, string tenMay)
    {
        using var conn = db.CreateConnection();
        conn.Open();
        // Transaction + FOR UPDATE để chống race condition LAN
        using var tx = conn.BeginTransaction();
        try
        {
            var tt = await conn.QuerySingleOrDefaultAsync<string>(
                "SELECT trang_thai FROM phien_in_tem WHERE ma_phien=@maPhien FOR UPDATE",
                new { maPhien }, transaction: tx);
            if (tt == null) throw new InvalidOperationException("Không tìm thấy phiên.");
            if (tt == "da_in") throw new InvalidOperationException("Phiên đã được xác nhận in, vui lòng tải lại trang.");
            if (tt == "huy")   throw new InvalidOperationException("Phiên đã bị huỷ.");
            if (tt != "nhap")  throw new InvalidOperationException("Phiên không hợp lệ hoặc đã đóng.");

            var soDong = await conn.ExecuteScalarAsync<int>(
                "SELECT COUNT(*) FROM chi_tiet_in_tem WHERE ma_phien=@maPhien",
                new { maPhien }, transaction: tx);
            if (soDong == 0) throw new InvalidOperationException("Phiên chưa có dòng nào.");

            await conn.ExecuteAsync("CALL sp_dong_phien(@maPhien,@tenMay)",
                new { maPhien, tenMay }, transaction: tx);
            tx.Commit();
        }
        catch
        {
            tx.Rollback();
            throw;
        }
    }
    public async Task HuyPhienAsync(int maPhien)
    {
        using var conn = db.CreateConnection();
        await conn.ExecuteAsync("UPDATE phien_in_tem SET trang_thai='huy' WHERE ma_phien=@maPhien AND trang_thai='nhap'", new { maPhien });
    }
  
    public async Task CapNhatMauInAsync(int maPhien, int maMauIn)
    {
        using var conn = db.CreateConnection();
        conn.Open();
        using var tx = conn.BeginTransaction();
        try
        {
            var trangThai = await conn.QuerySingleOrDefaultAsync<string>(
                "SELECT trang_thai FROM phien_in_tem WHERE ma_phien=@maPhien FOR UPDATE",
                new { maPhien }, transaction: tx);

            if (trangThai == null) throw new InvalidOperationException("Không tìm thấy phiên.");
            if (trangThai != "nhap") throw new InvalidOperationException("Phiên không hợp lệ hoặc đã đóng.");

            var soNhanMoiTrang = await conn.QuerySingleOrDefaultAsync<int?>(
                "SELECT so_nhan_moi_trang FROM mau_in WHERE ma_mau_in=@maMauIn",
                new { maMauIn }, transaction: tx);

            if (!soNhanMoiTrang.HasValue) throw new InvalidOperationException("Không tìm thấy template.");
            if (soNhanMoiTrang.Value <= 0) throw new InvalidOperationException("Template có số nhãn mỗi trang không hợp lệ.");

            await conn.ExecuteAsync(
                "UPDATE phien_in_tem SET ma_mau_in=@maMauIn WHERE ma_phien=@maPhien",
                new { maPhien, maMauIn }, transaction: tx);

            await conn.ExecuteAsync(
                @"UPDATE chi_tiet_in_tem
                  SET so_trang = CEILING(so_luong_nhan / @soNhanMoiTrang)
                  WHERE ma_phien=@maPhien",
                new { maPhien, soNhanMoiTrang = soNhanMoiTrang.Value }, transaction: tx);

            tx.Commit();
        }
        catch
        {
            tx.Rollback();
            throw;
        }
    }
}

public class ChiTietRepository(IDbConnectionFactory db) : IChiTietRepository
{
    public async Task<List<ChiTietInTem>> LayDsAsync(int maPhien)
    {
        using var conn = db.CreateConnection();
        return (await conn.QueryAsync<ChiTietInTem>(
            "SELECT c.*,ca.ten_ca FROM chi_tiet_in_tem c LEFT JOIN ca_san_xuat ca ON c.ma_ca=ca.ma_ca WHERE c.ma_phien=@maPhien ORDER BY c.stt",
            new { maPhien })).ToList();
    }
    public async Task<int> LaySttTiepTheoAsync(int maPhien)
    {
        using var conn = db.CreateConnection();
        return await conn.ExecuteScalarAsync<int>(
            "SELECT COALESCE(MAX(stt),0)+1 FROM chi_tiet_in_tem WHERE ma_phien=@maPhien", new { maPhien });
    }
    public async Task<int> TinhSoTrangAsync(int maPhien, int soLuongNhan)
    {
        using var conn = db.CreateConnection();
        return await conn.ExecuteScalarAsync<int>(
            "SELECT CEIL(@soLuongNhan/mi.so_nhan_moi_trang) FROM phien_in_tem p JOIN mau_in mi ON p.ma_mau_in=mi.ma_mau_in WHERE p.ma_phien=@maPhien",
            new { soLuongNhan, maPhien });
    }
    public async Task<int> ThemAsync(ChiTietInTem ct)
    {
        using var conn = db.CreateConnection();
        conn.Open();
        using var tx = conn.BeginTransaction();
        try
        {
            var row = await conn.QuerySingleOrDefaultAsync<PhienMauLockRow>(
                @"SELECT p.trang_thai AS TrangThai, mi.so_nhan_moi_trang AS SoNhanMoiTrang
                  FROM phien_in_tem p
                  JOIN mau_in mi ON p.ma_mau_in=mi.ma_mau_in
                  WHERE p.ma_phien=@MaPhien
                  FOR UPDATE", ct, transaction: tx);

            if (row == null) throw new InvalidOperationException("Không tìm thấy phiên.");
            if (row.TrangThai != "nhap") throw new InvalidOperationException("Phiên không hợp lệ hoặc đã đóng.");
            if (row.SoNhanMoiTrang <= 0) throw new InvalidOperationException("Template có số nhãn mỗi trang không hợp lệ.");
            if (ct.SoLuongNhan <= 0) throw new InvalidOperationException("Số lượng nhãn phải lớn hơn 0.");

            ct.SoLuongNhan = (int)Math.Ceiling((double)ct.SoLuongNhan / row.SoNhanMoiTrang) * row.SoNhanMoiTrang;

            ct.Stt = await conn.ExecuteScalarAsync<int>(
                "SELECT COALESCE(MAX(stt),0)+1 FROM chi_tiet_in_tem WHERE ma_phien=@MaPhien",
                ct, transaction: tx);
            ct.SoTrang = (int)Math.Ceiling((double)ct.SoLuongNhan / row.SoNhanMoiTrang);

            var id = await conn.ExecuteScalarAsync<int>(
                @"INSERT INTO chi_tiet_in_tem
                (ma_phien,stt,ten_san_pham,ma_code,so_phieu,nam_phieu,chi_nhanh,
                ten_loai_giay,so_luong_san_pham,so_luong_nhan,so_luong_psp,ghi_chu,so_trang,
                ma_ca,ngay_san_xuat,nguoi_kiem,nguoi_dong_goi,loai_tao,ma_lich_su_goc)
                VALUES
                (@MaPhien,@Stt,@TenSanPham,@MaCode,@SoPhieu,@NamPhieu,@ChiNhanh,
                @TenLoaiGiay,@SoLuongSanPham,@SoLuongNhan,@SoLuongPsp,@GhiChu,@SoTrang,
                @MaCa,@NgaySanXuat,@NguoiKiem,@NguoiDongGoi,@LoaiTao,@MaLichSuGoc);
            SELECT LAST_INSERT_ID();", ct, transaction: tx);

            tx.Commit();
            return id;
        }
        catch
        {
            tx.Rollback();
            throw;
        }
    }
    public async Task XoaAsync(int maChiTiet, int maPhien)
    {
        using var conn = db.CreateConnection();
        conn.Open();
        using var tx = conn.BeginTransaction();
        try
        {
            var trangThai = await conn.QuerySingleOrDefaultAsync<string>(
                "SELECT trang_thai FROM phien_in_tem WHERE ma_phien=@maPhien FOR UPDATE",
                new { maPhien }, transaction: tx);

            if (trangThai == null) throw new InvalidOperationException("Không tìm thấy phiên.");
            if (trangThai != "nhap") throw new InvalidOperationException("Phiên không hợp lệ hoặc đã đóng.");

            await conn.QueryAsync<int>(
                "SELECT ma_chi_tiet FROM chi_tiet_in_tem WHERE ma_phien=@maPhien ORDER BY stt FOR UPDATE",
                new { maPhien }, transaction: tx);

            var affected = await conn.ExecuteAsync(
                "DELETE FROM chi_tiet_in_tem WHERE ma_chi_tiet=@maChiTiet AND ma_phien=@maPhien",
                new { maChiTiet, maPhien }, transaction: tx);
            if (affected == 0) throw new InvalidOperationException("Không tìm thấy dòng cần xóa.");

            await conn.ExecuteAsync(
                "UPDATE chi_tiet_in_tem SET stt=-stt WHERE ma_phien=@maPhien",
                new { maPhien }, transaction: tx);
            await conn.ExecuteAsync("SET @r=0", transaction: tx);
            await conn.ExecuteAsync(
                "UPDATE chi_tiet_in_tem SET stt=(@r:=@r+1) WHERE ma_phien=@maPhien ORDER BY stt DESC",
                new { maPhien }, transaction: tx);

            tx.Commit();
        }
        catch
        {
            tx.Rollback();
            throw;
        }
    }
}

file sealed class PhienMauLockRow
{
    public string TrangThai { get; set; } = "";
    public int SoNhanMoiTrang { get; set; }
}

public class LichSuRepository(IDbConnectionFactory db) : ILichSuRepository
{
    public async Task<List<LichSuInTem>> TimKiemAsync(string keyword)
    {
        using var conn = db.CreateConnection();
        var kw = $"%{keyword}%";
        return (await conn.QueryAsync<LichSuInTem>(
            @"SELECT * FROM lich_su_in_tem
              WHERE ten_san_pham LIKE @kw
                 OR ma_code LIKE @kw
                 OR phieu_san_pham LIKE @kw
                 OR ten_mau_in LIKE @kw
                 OR CAST(ma_mau_in AS CHAR) LIKE @kw
              ORDER BY thoi_gian_tao_tem DESC LIMIT 200",
            new { kw })).ToList();
    }
    public async Task XoaAsync(int maLichSu)
    {
        using var conn = db.CreateConnection();
        await conn.ExecuteAsync(
            "DELETE FROM lich_su_in_tem WHERE ma_lich_su=@maLichSu", new { maLichSu });
    }
    public async Task<List<LichSuInTem>> LocAsync(string? tuNgay, string? denNgay, string? keyword, string? tenMay)
    {
        using var conn = db.CreateConnection();
        var sql = "SELECT * FROM lich_su_in_tem WHERE 1=1";
        var p   = new DynamicParameters();
        if (!string.IsNullOrWhiteSpace(tuNgay))  { sql += " AND DATE(thoi_gian_tao_tem)>=@tuNgay";  p.Add("tuNgay",  tuNgay);  }
        if (!string.IsNullOrWhiteSpace(denNgay)) { sql += " AND DATE(thoi_gian_tao_tem)<=@denNgay"; p.Add("denNgay", denNgay); }
        if (!string.IsNullOrWhiteSpace(keyword)) { sql += " AND (ten_san_pham LIKE @kw OR ma_code LIKE @kw OR phieu_san_pham LIKE @kw OR ten_mau_in LIKE @kw OR CAST(ma_mau_in AS CHAR) LIKE @kw)"; p.Add("kw",$"%{keyword}%"); }
        if (!string.IsNullOrWhiteSpace(tenMay))  { sql += " AND ten_may_tinh LIKE @tenMay"; p.Add("tenMay",$"%{tenMay}%"); }
        sql += " ORDER BY thoi_gian_tao_tem DESC LIMIT 500";
        return (await conn.QueryAsync<LichSuInTem>(sql, p)).ToList();
    }
    public async Task<LichSuInTem?> LayTheoIdAsync(int maLichSu)
    {
        using var conn = db.CreateConnection();
        return await conn.QuerySingleOrDefaultAsync<LichSuInTem>(
            "SELECT * FROM lich_su_in_tem WHERE ma_lich_su=@maLichSu", new { maLichSu });
    }
    public async Task TangLanInLaiAsync(int maLichSu)
    {
        using var conn = db.CreateConnection();
        var affected = await conn.ExecuteAsync(
            "UPDATE lich_su_in_tem SET so_lan_in_lai=so_lan_in_lai+1 WHERE ma_lich_su=@maLichSu",
            new { maLichSu });
        if (affected == 0) throw new InvalidOperationException("Không tìm thấy lịch sử.");
    }
    public async Task<List<ThongKeSanPhamVM>> ThongKeAsync()
    {
        using var conn = db.CreateConnection();
        return (await conn.QueryAsync<ThongKeSanPhamVM>(
            "SELECT ten_san_pham AS TenSanPham,ma_code AS MaCode,COUNT(*) AS SoLanIn,SUM(so_luong_nhan) AS TongNhan,MAX(thoi_gian_tao_tem) AS LanInCuoi FROM lich_su_in_tem GROUP BY ten_san_pham,ma_code ORDER BY TongNhan DESC LIMIT 100")).ToList();
    }
}

public class MauInRepository(IDbConnectionFactory db) : IMauInRepository
{
    public async Task<MauIn?> LayMacDinhAsync()
    {
        using var conn = db.CreateConnection();
        return await conn.QuerySingleOrDefaultAsync<MauIn>("SELECT * FROM mau_in WHERE la_mac_dinh=1 LIMIT 1");
    }
    public async Task<MauIn?> LayTheoIdAsync(int maMauIn)
    {
        using var conn = db.CreateConnection();
        return await conn.QuerySingleOrDefaultAsync<MauIn>("SELECT * FROM mau_in WHERE ma_mau_in=@maMauIn", new { maMauIn });
    }
    public async Task<List<MauIn>> LayTatCaAsync()
    {
        using var conn = db.CreateConnection();
        return (await conn.QueryAsync<MauIn>("SELECT * FROM mau_in ORDER BY la_mac_dinh DESC,ten_mau")).ToList();
    }
    public async Task<int> ThemAsync(MauIn m)
    {
        using var conn = db.CreateConnection();
        return await conn.ExecuteScalarAsync<int>(
            "INSERT INTO mau_in (ten_mau,kho_giay,so_nhan_moi_trang,cau_hinh_truong,la_mac_dinh,ghi_chu) VALUES (@TenMau,@KhoGiay,@SoNhanMoiTrang,@CauHinhTruong,@LaMacDinh,@GhiChu); SELECT LAST_INSERT_ID();", m);
    }
    public async Task CapNhatAsync(MauIn m)
    {
        using var conn = db.CreateConnection();
        await conn.ExecuteAsync("UPDATE mau_in SET ten_mau=@TenMau,kho_giay=@KhoGiay,so_nhan_moi_trang=@SoNhanMoiTrang,cau_hinh_truong=@CauHinhTruong,ghi_chu=@GhiChu WHERE ma_mau_in=@MaMauIn", m);
    }
    public async Task SetMacDinhAsync(int maMauIn)
    {
        using var conn = db.CreateConnection();
        conn.Open();
        using var tx = conn.BeginTransaction();
        try
        {
            var exists = await conn.ExecuteScalarAsync<int>(
                "SELECT COUNT(*) FROM mau_in WHERE ma_mau_in=@maMauIn",
                new { maMauIn }, transaction: tx);
            if (exists == 0) throw new InvalidOperationException("Không tìm thấy template.");

            await conn.ExecuteAsync("UPDATE mau_in SET la_mac_dinh=0", transaction: tx);
            await conn.ExecuteAsync(
                "UPDATE mau_in SET la_mac_dinh=1 WHERE ma_mau_in=@maMauIn",
                new { maMauIn }, transaction: tx);
            tx.Commit();
        }
        catch
        {
            tx.Rollback();
            throw;
        }
    }
    public async Task XoaAsync(int maMauIn)
    {
        using var conn = db.CreateConnection();
        await conn.ExecuteAsync("DELETE FROM mau_in WHERE ma_mau_in=@maMauIn AND la_mac_dinh=0", new { maMauIn });
    }
}

public class CaSanXuatRepository(IDbConnectionFactory db) : ICaSanXuatRepository
{
    public async Task<List<CaSanXuat>> LayTatCaAsync(bool chiActive = true)
    {
        using var conn = db.CreateConnection();
        var sql = chiActive ? "SELECT * FROM ca_san_xuat WHERE trang_thai=1 ORDER BY thu_tu,ten_ca"
                            : "SELECT * FROM ca_san_xuat ORDER BY thu_tu,ten_ca";
        return (await conn.QueryAsync<CaSanXuat>(sql)).ToList();
    }
    public async Task<int> ThemAsync(string tenCa)
    {
        using var conn = db.CreateConnection();
        return await conn.ExecuteScalarAsync<int>(
            "INSERT INTO ca_san_xuat (ten_ca) VALUES (@tenCa); SELECT LAST_INSERT_ID();", new { tenCa });
    }
    public async Task CapNhatAsync(CaSanXuat ca)
    {
        using var conn = db.CreateConnection();
        await conn.ExecuteAsync("UPDATE ca_san_xuat SET ten_ca=@TenCa,thu_tu=@ThuTu WHERE ma_ca=@MaCa", ca);
    }
    public async Task AnHienAsync(int maCa, bool an)
    {
        using var conn = db.CreateConnection();
        await conn.ExecuteAsync("UPDATE ca_san_xuat SET trang_thai=@tt WHERE ma_ca=@maCa", new { tt=an?0:1, maCa });
    }
}

public class DropdownRepository(IDbConnectionFactory db) : IDropdownRepository
{
    public async Task<List<DropdownSanPham>> LaySanPhamAsync()
    {
        using var conn = db.CreateConnection();
        return (await conn.QueryAsync<DropdownSanPham>("SELECT * FROM v_dropdown_san_pham")).ToList();
    }
    public async Task<List<string>> LayLoaiGiayAsync()
    {
        using var conn = db.CreateConnection();
        return (await conn.QueryAsync<string>("SELECT ten_loai_giay FROM v_dropdown_loai_giay")).ToList();
    }
}

public class CauHinhRepository(IDbConnectionFactory db) : ICauHinhRepository
{
    public async Task<string?> LayGiaTriAsync(string khoa)
    {
        using var conn = db.CreateConnection();
        return await conn.QuerySingleOrDefaultAsync<string>(
            "SELECT gia_tri FROM cau_hinh_he_thong WHERE khoa=@khoa", new { khoa });
    }
    public async Task LuuAsync(string khoa, string giaTri)
    {
        using var conn = db.CreateConnection();
        await conn.ExecuteAsync(
            "INSERT INTO cau_hinh_he_thong (khoa,gia_tri) VALUES (@khoa,@giaTri) ON DUPLICATE KEY UPDATE gia_tri=@giaTri",
            new { khoa, giaTri });
    }
    public async Task<List<CauHinhHeThong>> LayTatCaAsync()
    {
        using var conn = db.CreateConnection();
        return (await conn.QueryAsync<CauHinhHeThong>("SELECT * FROM cau_hinh_he_thong ORDER BY khoa")).ToList();
    }
}
