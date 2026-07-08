using Dapper;
using System.Data;

namespace LabelPrint.Models;

// TypeHandler: Dapper không tự map DateOnly từ MySQL → cần handler này
public class DateOnlyTypeHandler : SqlMapper.TypeHandler<DateOnly>
{
    public override void SetValue(IDbDataParameter parameter, DateOnly value)
        => parameter.Value = value.ToDateTime(TimeOnly.MinValue);

    public override DateOnly Parse(object value)
    {
        var dt = Convert.ToDateTime(value);
        return DateOnly.FromDateTime(dt);
    }
}

public class CaSanXuat
{
    public int    MaCa      { get; set; }
    public string TenCa     { get; set; } = "";
    public int?   ThuTu     { get; set; }
    public int    TrangThai { get; set; } = 1;
}

public class MauIn
{
    public int      MaMauIn        { get; set; }
    public string   TenMau         { get; set; } = "";
    public string   KhoGiay        { get; set; } = "letter";
    public int      SoNhanMoiTrang { get; set; } = 8;
    public string?  CauHinhTruong  { get; set; }
    public bool     LaMacDinh      { get; set; }
    public string?  GhiChu         { get; set; }
    public DateTime NgayTao        { get; set; }
    public DateTime NgayCapNhat    { get; set; }
}

public class PhienInTem
{
    public int      MaPhien     { get; set; }
    public int      MaMauIn     { get; set; }
    public int      TongSoNhan  { get; set; }
    public int      TongSoTrang { get; set; }
    public string   TrangThai   { get; set; } = "nhap";
    public string?  GhiChu      { get; set; }
    public string?  TenMayTinh  { get; set; }
    public DateTime NgayTao     { get; set; }
}

public class ChiTietInTem
{
    public int       MaChiTiet      { get; set; }
    public int       MaPhien        { get; set; }
    public int       Stt            { get; set; }
    public string    TenSanPham     { get; set; } = "";
    public string    MaCode         { get; set; } = "";
    public string    SoPhieu        { get; set; } = "";
    public int       NamPhieu       { get; set; }
    public string    ChiNhanh       { get; set; } = "";
    public string    TenLoaiGiay    { get; set; } = "";
    public int       SoLuongSanPham { get; set; }
    public int       SoLuongNhan    { get; set; }

    // thêm 2 dòng ngay bên dưới:
    public int?      SoLuongPsp     { get; set; }
    public string?   GhiChu         { get; set; }
    public int       SoTrang        { get; set; }
    public int?      MaCa           { get; set; }
    public DateOnly? NgaySanXuat    { get; set; }
    public string?   NguoiKiem      { get; set; }
    public string?   NguoiDongGoi   { get; set; }
    public string    LoaiTao        { get; set; } = "moi";
    public int?      MaLichSuGoc    { get; set; }
    public DateTime  NgayTao        { get; set; }
    public string?   TenCa          { get; set; }
    public string    PhieuSanPham   => $"{SoPhieu}/{NamPhieu}/{ChiNhanh}";
}

public class LichSuInTem
{
    public int       MaLichSu       { get; set; }
    public int       MaPhien        { get; set; }
    public int       Stt            { get; set; }
    public string    TenSanPham     { get; set; } = "";
    public string    MaCode         { get; set; } = "";
    public string    PhieuSanPham   { get; set; } = "";
    public string    TenLoaiGiay    { get; set; } = "";
    public int       SoLuongSanPham { get; set; }
    public int       SoLuongNhan    { get; set; }
    // thêm 2 dòng ngay bên dưới:
    public int?      SoLuongPsp     { get; set; }
    public string?   GhiChu         { get; set; }
    public string?   TenCa          { get; set; }
    public DateOnly? NgaySanXuat    { get; set; }
    public string?   NguoiKiem      { get; set; }
    public string?   NguoiDongGoi   { get; set; }
    public int?      MaMauIn        { get; set; } 
    public string?   TenMauIn       { get; set; }
    public string?   KhoGiay        { get; set; }
    public string?   TenMayTinh     { get; set; }
    public int       SoLanInLai     { get; set; }
    public DateTime  ThoiGianTaoTem { get; set; }
}

public class DropdownSanPham
{
    public string TenSanPham { get; set; } = "";
    public string MaCode     { get; set; } = "";
}

public class CauHinhHeThong
{
    public int      MaCauHinh   { get; set; }
    public string   Khoa        { get; set; } = "";
    public string   GiaTri      { get; set; } = "";
    public string?  MoTa        { get; set; }
    public DateTime NgayCapNhat { get; set; }
}
