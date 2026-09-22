#if canImport(SwiftUI)
import SwiftUI
import KubarOKCore

struct ProfileOnboardingView: View {

    @StateObject private var viewModel: ProfileOnboardingViewModel

    init(sessionController: AppSessionController, citizen: Citizen? = nil) {
        _viewModel = StateObject(
            wrappedValue: ProfileOnboardingViewModel(
                sessionController: sessionController,
                citizen: citizen
            )
        )
    }

    var body: some View {
        Form {
            Section {
                Text(viewModel.isEditing
                     ? "Perbarui profil warga Anda."
                     : "Lengkapi profil warga untuk melanjutkan.")
                    .foregroundStyle(.secondary)
            }

            Section("Identitas") {
                TextField("NIK atau identitas berlaku", text: $viewModel.applicableId)
                TextField("Nama lengkap", text: $viewModel.name)
                TextField("Nomor KK (opsional)", text: $viewModel.kkNumber)
            }

            Section("Kelahiran") {
                TextField("Tempat lahir", text: $viewModel.birthPlace)
                DatePicker("Tanggal lahir", selection: $viewModel.birthDate, displayedComponents: .date)
            }

            Section("Data warga") {
                Picker("Jenis kelamin", selection: $viewModel.sex) {
                    Text("Laki-laki").tag("M")
                    Text("Perempuan").tag("F")
                }
                Picker("Kewarganegaraan", selection: $viewModel.citizenship) {
                    Text("WNI").tag("WNI")
                    Text("WNA").tag("WNA")
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage).foregroundStyle(.red)
                }
            }

            Section {
                Button("Simpan profil") {
                    Task { await viewModel.submit() }
                }
                .disabled(viewModel.isLoading)

                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
        .navigationTitle(viewModel.isEditing ? "Edit Profil Warga" : "Profil Warga")
    }
}

@MainActor
final class ProfileOnboardingViewModel: ObservableObject {

    @Published var applicableId = ""
    @Published var name = ""
    @Published var kkNumber = ""
    @Published var birthPlace = ""
    @Published var birthDate = Date()
    @Published var sex = "M"
    @Published var citizenship = "WNI"
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let sessionController: AppSessionController
    let isEditing: Bool

    init(sessionController: AppSessionController, citizen: Citizen? = nil) {
        self.sessionController = sessionController
        isEditing = citizen != nil
        if let citizen {
            applicableId = citizen.applicableId
            name = citizen.fullName
            kkNumber = citizen.kkNumber ?? ""
            birthPlace = citizen.birthPlace
            sex = citizen.sex
            citizenship = citizen.citizenship
            if let birthDate = citizen.birthDate,
               let parsedDate = Self.backendDateFormatter.date(from: birthDate) {
                self.birthDate = parsedDate
            }
        }
    }

    func submit() async {
        guard !applicableId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !birthPlace.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Mohon lengkapi seluruh field wajib."
            return
        }

        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        let request = CitizenProfileRequest(
            applicableId: applicableId,
            name: name,
            kkNumber: kkNumber.isEmpty ? nil : kkNumber,
            birthPlace: birthPlace,
            birthDate: Self.backendDateFormatter.string(from: birthDate),
            sex: sex,
            citizenship: citizenship
        )

        do {
            try await sessionController.completeProfile(request: request)
        } catch {
            errorMessage = UserFacingErrorMapper.message(for: error)
        }
    }

    private static let backendDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
#endif
