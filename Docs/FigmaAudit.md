# Audit Figma KubarOK iOS

Sumber desain: `01 - Mockup Online Kubar ios` (`CGkfnAOPxUia9LEjsG1DKp`), dibaca melalui Figma MCP pada 23 September 2026.

## Struktur file

- Page: `Page 1` (`0:1`)
- Ukuran layar utama: 393 × 852 pt. Dialog hapus menggunakan 399 × 852 pt.
- Alur utama yang terbaca: Splash → welcome/berita → Login ↔ Registrasi → Home. Dari Home pengguna dapat membuka notifikasi, dinas/layanan, pengajuan, progres, dan akun.

## Pemetaan frame ke SwiftUI

| Kelompok | Frame Figma | Node ID | Ukuran | File SwiftUI | Status | API/Service | Tindakan |
|---|---|---:|---:|---|---|---|---|
| Splash | Splash Screen | `1:2201` | 393×852 | `App/AppRootView.swift` | Diimplementasikan | `AppSessionController.restore` | Aset logo dan dekorasi responsif |
| Beranda publik | Beranda | `227:1006` | 393×852 | `App/AppRootView.swift` (`PublicHomeView`) | Diimplementasikan | — | Tiga kartu berita, aksi Login dan Daftar; tersedia tanpa autentikasi |
| Login | LOGIN | `11:322` | 393×852 | `Features/Authentication/Login/LoginView.swift` | Diimplementasikan | `SessionManager`, `AuthService` | Layout Figma, loading/error/disabled, show password |
| Notifikasi | Info | `58:867` | 393×852 | `Features/Home/HomeView.swift` (`NotificationListView`) | Tersedia, desain berbeda | `NotificationService` | Tahap notifikasi |
| Riwayat | Daftar Pengajuan | `73:1450` | 393×852 | `Features/Submission/SubmissionTrackingView.swift` | Tersedia, desain berbeda | `SubmissionTrackingAPI` | Tahap riwayat |
| Dinas | Daftar Dinas | `68:4695` | 393×852 | `Features/Services/BureauList/BureauListView.swift` | Tersedia, desain berbeda | `ServiceCatalogAPI` / `BureauService` | Tahap layanan |
| Layanan | Daftar Layanan | `74:433` | 393×852 | `Features/Services/ServiceList/ServiceListView.swift` | Tersedia, desain berbeda | `ServiceCatalogAPI` / `GovernmentServiceAPI` | Tahap layanan |
| Detail layanan | Layanan KIA Hilang | `176:483` | 393×852 | `Features/Services/ServiceDetail/ServiceDetailView.swift` | Tersedia, desain berbeda | `ServiceCatalogAPI` | Tahap detail layanan |
| Profil | Akun | `78:7232` | 393×852 | `Features/Home/HomeView.swift` (`accountView`) | Diimplementasikan sebagian | `UserService`, `ProfileService`, session | Tab Akun sudah terhubung |
| Registrasi | Registrasi Disini | `21:697` | 393×852 | `Features/Authentication/Registration/RegistrationView.swift` | Diimplementasikan | `SessionManager`, `RegistrationService` | Layout Figma, validasi lama dipertahankan |
| Home | Home | `17:401` | 393×852 | `Features/Home/HomeView.swift` | Diimplementasikan | session; route ke service, tracking, notification | Dashboard dan bottom navigation native |
| Lainnya | Frame | `88:4578` | 393×537 | Belum dipetakan | Belum tersedia | Belum teridentifikasi | Perlu konteks node lanjutan |
| Profil | Ubah Akun | `86:1421` | 393×857 | `Features/Home/HomeView.swift` (`AccountEditView`) | Tersedia, desain berbeda | `UserService.updateUser` | Tahap profil |
| Profil | Ubah Data Diri | `92:728` | 393×857 | `Features/Onboarding/ProfileOnboardingView.swift` | Tersedia, desain berbeda | `ProfileService`, `SessionManager` | Tahap profil |
| Legal | Syarat & Ketentuan | `91:960` | 393×852 | Belum tersedia | Belum tersedia | Endpoint belum ditemukan | Implementasi setelah sumber konten dipastikan |
| Legal | Kebijakan Privacy | `105:801` | 393×852 | Belum tersedia | Belum tersedia | Endpoint belum ditemukan | Implementasi setelah sumber konten dipastikan |
| Bantuan | Pusat Bantuan | `105:864` | 393×852 | Belum tersedia | Belum tersedia | Endpoint belum ditemukan | Tahap screen lainnya |
| Dinas | Home Layanan DINAS DUKCAPIL | `173:465` | 393×852 | `BureauListView.swift` / `ServiceListView.swift` | Fungsi terhubung, desain berbeda | `ServiceCatalogAPI` | Jangan hardcode dinas; gunakan model API |
| Layanan | Daftar Layanan Disdukcapil | `181:552` | 393×852 | `Features/Services/ServiceList/ServiceListView.swift` | Fungsi terhubung, desain berbeda | `ServiceCatalogAPI` | Tahap layanan |
| Form pengajuan | Pengajuan Layanan KIA Hilang | `175:660` | 393×852 | `Features/Submission/SubmissionFlowView.swift` | Fungsi terhubung, desain berbeda | `SubmissionFlowAPI`, `SubmissionWorkflow` | Data/konfirmasi awal |
| Form pengajuan | Pengajuan Layanan Rujukan | `205:1300` | 393×852 | `Features/Submission/SubmissionFlowView.swift` | Fungsi terhubung, desain berbeda | `SubmissionFlowAPI`, `SubmissionWorkflow` | Data/konfirmasi awal |
| Form pengajuan | Pengajuan Layanan KIA Hilang | `185:578` | 393×852 | `Features/Submission/SubmissionFlowView.swift` | Fungsi terhubung, desain berbeda | `SubmissionFlowAPI`, `SubmissionWorkflow` | Varian langkah |
| Upload | Pengajuan Layanan KIA Hilang | `208:915` | 393×852 | `Features/Submission/SubmissionFlowView.swift` | Fungsi terhubung, desain berbeda | `SubmissionFlowAPI`, multipart | Tahap upload |
| Form pengajuan | Pengajuan Layanan Jika Salah Data | `205:2103` | 393×852 | `Features/Submission/SubmissionFlowView.swift` | Fungsi terhubung, desain berbeda | `SubmissionFlowAPI`, `SubmissionWorkflow` | Error/validasi |
| Form pengajuan | Pengajuan Layanan Rujukan | `205:1440` | 393×852 | `Features/Submission/SubmissionFlowView.swift` | Fungsi terhubung, desain berbeda | `SubmissionFlowAPI`, `SubmissionWorkflow` | Varian langkah |
| Form pengajuan | Pengajuan Layanan | `205:1097` | 393×852 | `Features/Submission/SubmissionFlowView.swift` | Fungsi terhubung, desain berbeda | `SubmissionFlowAPI`, `SubmissionWorkflow` | Success/submit |
| Progres | Progress Draft Pengajuan Layanan KIA HILANG | `229:3942` | 393×852 | `Features/Submission/SubmissionTrackingView.swift` | Fungsi terhubung, desain berbeda | `SubmissionTrackingAPI` | Status draft |
| Progres | Progress Draft Pengajuan Layanan KIA HILANG | `321:1882` | 393×852 | `Features/Submission/SubmissionTrackingView.swift` | Fungsi terhubung, desain berbeda | `SubmissionTrackingAPI` | Varian draft |
| Dialog | Hapus Pengajuan Layanan KIA HILANG | `231:4367` | 399×852 | `Features/Submission/SubmissionTrackingView.swift` | Fungsi terhubung, desain berbeda | `SubmissionTrackingAPI.deleteSubmission` | Confirmation dialog |
| Dialog | Hapus Pengajuan Layanan KIA HILANG | `321:2154` | 399×852 | `Features/Submission/SubmissionTrackingView.swift` | Fungsi terhubung, desain berbeda | `SubmissionTrackingAPI.deleteSubmission` | Varian dialog |
| Progres | Progress (Dalam Progress) Pengajuan Layanan KIA HILANG | `230:1208` | 393×852 | `Features/Submission/SubmissionTrackingView.swift` | Fungsi terhubung, desain berbeda | `SubmissionTrackingAPI` | Status berjalan |
| Progres | Progress (Dalam Progress) Pengajuan Layanan KIA HILANG | `321:2294` | 393×852 | `Features/Submission/SubmissionTrackingView.swift` | Fungsi terhubung, desain berbeda | `SubmissionTrackingAPI` | Varian berjalan |
| Progres | Progress Selesai Pengajuan Layanan KIA HILANG | `232:1067` | 393×852 | `Features/Submission/SubmissionTrackingView.swift` | Fungsi terhubung, desain berbeda | `SubmissionTrackingAPI` | Status selesai |
| Progres | Progress Selesai Pengajuan Layanan KIA HILANG | `321:2433` | 393×852 | `Features/Submission/SubmissionTrackingView.swift` | Fungsi terhubung, desain berbeda | `SubmissionTrackingAPI` | Varian selesai |
| Form pengajuan | Pengajuan Layanan | `205:1901` | 393×852 | `Features/Submission/SubmissionFlowView.swift` | Fungsi terhubung, desain berbeda | `SubmissionFlowAPI`, `SubmissionWorkflow` | Varian submit |
| Form pengajuan | Pengajuan Layanan KIA Hilang | `189:1207` | 393×852 | `Features/Submission/SubmissionFlowView.swift` | Fungsi terhubung, desain berbeda | `SubmissionFlowAPI`, `SubmissionWorkflow` | Varian langkah |
| Form pengajuan | Pengajuan Layanan Rujukan | `205:1542` | 393×852 | `Features/Submission/SubmissionFlowView.swift` | Fungsi terhubung, desain berbeda | `SubmissionFlowAPI`, `SubmissionWorkflow` | Varian langkah |
| Dinas | Home Layanan DINAS SOSIAL | `204:1676` | 393×852 | `BureauListView.swift` / `ServiceListView.swift` | Fungsi terhubung, desain berbeda | `ServiceCatalogAPI` | Gunakan data API |
| Layanan | Daftar Layanan DINSOS | `204:1857` | 393×852 | `Features/Services/ServiceList/ServiceListView.swift` | Fungsi terhubung, desain berbeda | `ServiceCatalogAPI` | Tahap layanan |
| Detail layanan | Pemberian Layanan Rujukan | `204:2088` | 393×852 | `Features/Services/ServiceDetail/ServiceDetailView.swift` | Fungsi terhubung, desain berbeda | `ServiceCatalogAPI` | Tahap detail layanan |
| Upload | Pengajuan Layanan Rujukan | `204:2622` | 393×852 | `Features/Submission/SubmissionFlowView.swift` | Fungsi terhubung, desain berbeda | `SubmissionFlowAPI`, multipart | Tahap upload |
| Form pengajuan | Pengajuan Layanan Rujukan | `217:3765` | 393×852 | `Features/Submission/SubmissionFlowView.swift` | Fungsi terhubung, desain berbeda | `SubmissionFlowAPI` | Varian success/submit |
| Form pengajuan | Pengajuan Layanan Rujukan Jika Salah Data | `204:3501` | 393×852 | `Features/Submission/SubmissionFlowView.swift` | Fungsi terhubung, desain berbeda | `SubmissionFlowAPI` | Error/validasi |
| Form pengajuan | Pengajuan Layanan KIA Hilang | `213:1161` | 393×852 | `Features/Submission/SubmissionFlowView.swift` | Fungsi terhubung, desain berbeda | `SubmissionFlowAPI` | Varian keluar/batal |

Instance lepas (`New Logo`, dua `Search bar`, `Column Header`, radio buttons, tombol, dan logo) bukan screen mandiri; semuanya diperlakukan sebagai kandidat komponen reusable.

## Komponen reusable dan token

Komponen berulang yang ditemukan: top app bar biru + logo putih, tombol contained hijau, input abu-abu radius 10, search bar, subheader ikon + judul, news/service/submission card, badge status, bottom navigation, dialog konfirmasi, empty/loading/error states, dan dekorasi lingkaran brand.

Token utama dari konteks MCP:

| Token | Nilai |
|---|---|
| Prussian Blue | `#003152` |
| Primary Green | `#1B9B4E` |
| Secondary Red | `#D5142B` |
| White | `#FFFFFF` |
| Field Gray | `#F3F3F3` / `#D9D9D9` pada frame lama |
| Typography | Roboto Light/Regular/Medium; 9, 12, 13, 14, dan 18 pt |
| Button | 14 pt Medium, line height 16, tracking 1.25, uppercase |
| Spacing dominan | 4, 8, 12, 16, 24, 32 pt |
| Radius | 4 pt tombol; 10 pt field; 12–18 pt card |
| Shadow card | hitam ±14%, blur 2, offset-y 2 |
| Ikon | umumnya 15–24 pt; target sentuh dinaikkan ke minimum 44 pt |

Roboto tidak ada di bundle proyek. Implementasi awal memakai font sistem semantic/Dynamic Type agar tidak menambahkan font tanpa lisensi/berkas dan tetap aksesibel pada iOS 16.

## Aset

Aset yang sudah diekspor untuk kelompok pertama: logo utama, logo putih, ilustrasi login, ilustrasi home, dan tiga kartu berita welcome. Kandidat tahap berikutnya: logo dinas, ilustrasi/detail layanan, ikon status khusus, dan gambar berita lain. Device chrome, form, tombol, card, app bar, bottom bar, serta dekorasi geometris tidak diekspor sebagai screenshot.

## Keterbatasan pembacaan

- Seluruh top-level frame dan ukurannya berhasil dibaca.
- Node `88:4578` hanya bernama `Frame`; fungsi pastinya belum cukup jelas dari metadata dan harus dibaca dengan konteks node khusus saat tahap terkait.
- Prototype connector tidak muncul pada hasil metadata MCP. Alur di atas disimpulkan dari urutan/isi frame dan navigasi aplikasi yang sudah berjalan.
- Legal/help mempunyai desain tetapi belum ditemukan endpoint/sumber konten di proyek, sehingga tidak diisi placeholder hardcoded.
