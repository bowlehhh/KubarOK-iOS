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
            if body?.contains("Profile data must be completed") == true {
                return "Profil warga harus dilengkapi sebelum membuat pengajuan."
            }
            if body?.contains("Please validate your phone number") == true {
                return "Nomor HP harus diverifikasi sebelum membuat pengajuan."
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
        case .missingPhone:
            return "Nomor HP wajib diisi."
        case .missingPassword:
            return "Password wajib diisi."
        case .passwordsDoNotMatch:
            return "Konfirmasi password tidak sama."
        }
    }
}
