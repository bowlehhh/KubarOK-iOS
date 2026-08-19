#if canImport(SwiftUI)
import SwiftUI

struct HomeView: View {

    @ObservedObject var sessionController: AppSessionController

    var body: some View {
        List {
            Section {
                Text("KUBAR OK")
                    .font(.largeTitle.bold())
                Text("Selamat datang, \(sessionController.user?.name ?? sessionController.user?.email ?? "Pengguna")")
                    .font(.title3)
            }

            Section("Informasi akun") {
                LabeledContent("Nama", value: sessionController.user?.name ?? "-")
                LabeledContent("Email", value: sessionController.user?.email ?? "-")
                LabeledContent("Nomor HP", value: sessionController.user?.phone ?? "-")
                LabeledContent("Citizen", value: sessionController.user?.citizen?.fullName ?? "-")
            }

            Section("Layanan") {
                NavigationLink("Layanan Publik") {
                    BureauListView(sessionController: sessionController)
                }
                NavigationLink("Riwayat Pengajuan") {
                    SubmissionHistoryView(sessionController: sessionController)
                }
            }

            Section {
                Button("Keluar", role: .destructive) {
                    Task { await sessionController.logout() }
                }
            }
        }
        .navigationTitle("Beranda")
    }
}
#endif
