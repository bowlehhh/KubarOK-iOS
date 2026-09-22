import Foundation
import KubarOKCore

public enum UserFacingErrorMapper {

    public static func message(for error: Error) -> String {
        switch error {
        case SessionError.registrationValidation(let validationError):
            return registrationMessage(for: validationError)
        case SessionError.missingSession:
            return "Sesi Anda tidak tersedia. Silakan masuk kembali."
        case SessionError.profileNotLinked:
            return "Profil belum dapat dihubungkan. Silakan coba lagi."
        case SessionError.remoteLogoutFailed:
            return "Anda telah keluar dari perangkat ini, tetapi server belum dapat dihubungi."
        case APIError.httpError(let statusCode, let body):
            let backendMessage = APIError.httpError(statusCode: statusCode, body: body).backendMessage
            if backendMessage?.localizedCaseInsensitiveContains("Profile data must be completed") == true {
                return "Profil warga harus dilengkapi sebelum membuat pengajuan."
            }
            if backendMessage?.localizedCaseInsensitiveContains("Please validate your phone number") == true {
                return "Nomor HP harus diverifikasi sebelum membuat pengajuan."
            }
            if let backendMessage, !backendMessage.isEmpty {
                return backendMessage
            }
            if statusCode == 404 {
                return "Data pengajuan tidak ditemukan atau tidak dapat diakses."
            }
            if statusCode == 405 {
                return "Data pengajuan atau berkas tidak memenuhi validasi server."
            }
            return statusCode == 401 || statusCode == 403
                ? "Sesi Anda tidak valid. Silakan masuk kembali."
                : "Server tidak dapat memproses permintaan saat ini."
        case APIError.network:
            return "Koneksi bermasalah. Periksa internet Anda lalu coba lagi."
        case APIError.decoding, APIError.invalidData, APIError.invalidResponse:
            return "Respons server tidak dapat diproses. Silakan coba lagi."
        default:
            return "Terjadi kesalahan. Silakan coba lagi."
        }
    }

    private static func registrationMessage(
        for error: RegistrationValidationError
    ) -> String {
        switch error {
        case .missingName:
            return "Nama wajib diisi."
        case .missingEmail:
            return "Email wajib diisi."
        case .invalidEmail:
            return "Format email tidak valid."
        case .missingPhone:
            return "Nomor HP wajib diisi."
        case .invalidPhone:
            return "Nomor HP harus terdiri dari 8–13 karakter angka."
        case .missingPassword:
            return "Password wajib diisi."
        case .weakPassword:
            return PasswordPolicy.guidance
        case .passwordsDoNotMatch:
            return "Konfirmasi password tidak sama."
        }
    }
}
