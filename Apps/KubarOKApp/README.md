# KubarOK iOS app target

## Membuka di macOS

1. Salin atau clone seluruh repository, jangan hanya folder `Apps/KubarOKApp`.
2. Buka `Apps/KubarOKApp/KubarOK.xcodeproj` di Xcode 16 atau yang lebih baru.
3. Tunggu sampai local package `../../Packages/KubarOKCore` selesai di-resolve.
4. Pilih scheme `KubarOK`, pilih iPhone Simulator, lalu jalankan dengan `⌘R`.
5. Jalankan test package sebelum menguji akun produksi:

   ```bash
   swift test --package-path Packages/KubarOKCore
   swift test --package-path Apps/KubarOKApp
   ```

Target menggunakan iOS 16.0, Swift 6, SwiftUI lifecycle, dan base URL produksi
`https://kubarok.kutaibaratkab.go.id/v1`.

## Fitur warga yang tersedia

- registrasi, login, logout, pemulihan password, dan OTP;
- melengkapi serta mengubah profil warga dan data akun;
- verifikasi nomor HP;
- daftar dan pencarian dinas/layanan serta detail persyaratan;
- informasi terbaru;
- notifikasi, jumlah belum dibaca, tandai dibaca, dan hapus;
- membuat, melengkapi, mengirim, melanjutkan, melacak, dan menghapus draft;
- membuka dokumen hasil dan layanan eksternal.

## Sebelum distribusi

Bundle identifier saat ini `id.go.kutaibarat.kubarok`. Konfirmasi identifier
resmi dan pilih Apple Developer Team sebelum build perangkat, archive, atau
App Store. Automatic signing aktif, tetapi team, sertifikat, dan provisioning
profile tidak disimpan di repository.

`Assets.xcassets` masih memiliki AppIcon placeholder dan AccentColor sementara.
Ganti dengan aset produksi. Push notification juga memerlukan konfigurasi APNs/
Firebase dan entitlement resmi; daftar notifikasi dalam aplikasi tetap dapat
digunakan tanpa konfigurasi push tersebut.

Proyek tidak memiliki ATS exception dan tidak meminta izin privasi. API memakai
HTTPS. Endpoint produksi `information/last-announcement` diketahui dapat
mengembalikan HTTP 500; kegagalannya diabaikan sehingga layar tetap memakai
`latest-info` yang aktif dan pengumuman akan muncul saat endpoint tersebut sehat.
