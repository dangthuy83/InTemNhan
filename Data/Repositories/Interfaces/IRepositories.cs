using LabelPrint.Models;
using LabelPrint.Models.ViewModels;

namespace LabelPrint.Data.Repositories.Interfaces;

public interface IPhienInRepository
{
    Task<PhienInTem>  TaoPhienMoiAsync(int maMauIn, string tenMay);
    Task<PhienInTem?> LayPhienAsync(int maPhien);
    Task              DongPhienAsync(int maPhien, string tenMay);
    Task              HuyPhienAsync(int maPhien);
    Task CapNhatMauInAsync(int maPhien, int maMauIn);
}
public interface IChiTietRepository
{
    Task<List<ChiTietInTem>> LayDsAsync(int maPhien);
    Task<int>  ThemAsync(ChiTietInTem ct);
    Task       XoaAsync(int maChiTiet, int maPhien);
    Task<int>  LaySttTiepTheoAsync(int maPhien);
    Task<int>  TinhSoTrangAsync(int maPhien, int soLuongNhan);
}
public interface ILichSuRepository
{
    Task<List<LichSuInTem>>      TimKiemAsync(string keyword);
    Task<List<LichSuInTem>>      LocAsync(string? tuNgay, string? denNgay, string? keyword, string? tenMay);
    Task<LichSuInTem?>           LayTheoIdAsync(int maLichSu);
    Task XoaAsync(int maLichSu);
    Task                         TangLanInLaiAsync(int maLichSu);
    Task<List<ThongKeSanPhamVM>> ThongKeAsync();
}
public interface IMauInRepository
{
    Task<MauIn?>      LayMacDinhAsync();
    Task<MauIn?>      LayTheoIdAsync(int maMauIn);
    Task<List<MauIn>> LayTatCaAsync();
    Task<int>         ThemAsync(MauIn m);
    Task              CapNhatAsync(MauIn m);
    Task              SetMacDinhAsync(int maMauIn);
    Task              XoaAsync(int maMauIn);
}
public interface ICaSanXuatRepository
{
    Task<List<CaSanXuat>> LayTatCaAsync(bool chiActive = true);
    Task<int>  ThemAsync(string tenCa);
    Task       CapNhatAsync(CaSanXuat ca);
    Task       AnHienAsync(int maCa, bool an);
}
public interface IDropdownRepository
{
    Task<List<DropdownSanPham>> LaySanPhamAsync();
    Task<List<string>>          LayLoaiGiayAsync();
}
public interface ICauHinhRepository
{
    Task<string?>              LayGiaTriAsync(string khoa);
    Task                       LuuAsync(string khoa, string giaTri);
    Task<List<CauHinhHeThong>> LayTatCaAsync();
}
