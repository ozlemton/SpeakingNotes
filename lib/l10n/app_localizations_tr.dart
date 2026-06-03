// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'SpeakingNotes';

  @override
  String get allNotes => 'Tüm Notlar';

  @override
  String get searchNotes => 'Notlarda ara...';

  @override
  String get category => 'Kategori';

  @override
  String get selectCategory => 'Kategori Seç';

  @override
  String get createNewCategory => 'Yeni Kategori Oluştur';

  @override
  String get select => 'Seç';

  @override
  String get recordingAudio => 'Ses Kaydediliyor';

  @override
  String get noNotesYet => 'Henüz not yok. Kaydetmek için mikrofona dokun.';

  @override
  String get noNotesFound => 'Aramanız için not bulunamadı.';

  @override
  String get noteDeleted => 'Not silindi';

  @override
  String get categoryDeleted => 'Kategori silindi';

  @override
  String get categoryUpdated => 'Kategori güncellendi';

  @override
  String get login => 'Giriş Yap';

  @override
  String get signUp => 'Kayıt Ol';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get username => 'Kullanıcı Adı';

  @override
  String get language => 'Dil';

  @override
  String get profile => 'Profil';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get english => 'İngilizce';

  @override
  String get turkish => 'Türkçe';

  @override
  String get welcomeBack => 'Tekrar hoş geldiniz';

  @override
  String get createAccount => 'Hesabınızı oluşturun';

  @override
  String get noAccount => 'Hesabınız yok mu? ';

  @override
  String get alreadyHaveAccount => 'Zaten hesabınız var mı? ';

  @override
  String get syncUnavailable => 'Senkronizasyon Kullanılamıyor';

  @override
  String get syncUnavailableMessage =>
      'Bulut senkronizasyonu kullanılamıyor. Notlarınız yalnızca yerel olarak kaydedilecek.';

  @override
  String get ok => 'Tamam';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get holdToEditOrDelete => 'Düzenlemek veya silmek için basılı tut';

  @override
  String get failedToLoadCategories => 'Kategoriler yüklenemedi';

  @override
  String get somethingWentWrong =>
      'Bir şeyler yanlış gitti. Lütfen tekrar deneyin.';

  @override
  String get failedToSaveNote => 'Not kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get newCategory => 'Yeni Kategori';

  @override
  String get categoryName => 'Kategori adı';

  @override
  String get editCategory => 'Kategoriyi Düzenle';

  @override
  String get deleteCategory => 'Kategoriyi Sil';

  @override
  String deleteCategoryConfirm(String name) {
    return '\"$name\" silinsin mi? Bu kategorideki notlar silinmeyecek.';
  }

  @override
  String get allCategories => 'Tüm Kategoriler';

  @override
  String get create => 'Oluştur';

  @override
  String get recording => 'Kayıt';

  @override
  String get audio => 'Sesi';

  @override
  String get deleteNote => 'Notu sil';

  @override
  String get deleteNoteConfirm => 'Bu not kalıcı olarak silinecek.';

  @override
  String wordCharCount(int words, int chars) {
    return '$words kelime · $chars karakter';
  }

  @override
  String get logoutConfirm => 'Çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get validationEnterUsername => 'Lütfen bir kullanıcı adı girin';

  @override
  String get validationUsernameLength =>
      'Kullanıcı adı en az 2 karakter olmalıdır';

  @override
  String get validationEnterEmail => 'Lütfen e-posta adresinizi girin';

  @override
  String get validationEmailInvalid => 'Geçerli bir e-posta girin';

  @override
  String get validationEnterPassword => 'Lütfen şifrenizi girin';

  @override
  String get validationPasswordLength => 'Şifre en az 6 karakter olmalıdır';

  @override
  String get microphonePermissionRequired =>
      'Not kaydetmek için mikrofon izni gereklidir. Lütfen ayarlardan etkinleştirin.';
}
