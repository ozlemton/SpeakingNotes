# Privacy Policy / Gizlilik Politikası

---

## English

**Last Updated: June 2026**

### 1. Introduction

SpeakingNotes ("we", "our", or "the app") is a voice-powered note-taking application. This Privacy Policy explains what data we collect, how we use it, and your rights regarding your personal information.

By using SpeakingNotes, you agree to the practices described in this policy.

---

### 2. Data We Collect

We collect only the data necessary to provide the note-taking service:

| Data | Description |
|------|-------------|
| **Email address** | Collected at sign-up for account authentication |
| **Voice recordings** | Captured temporarily on-device during speech-to-text transcription; audio is processed by the device's speech recognition engine and is not stored or uploaded |
| **Notes** | The text content you create or dictate within the app |
| **Categories** | The folder/category names you create to organise your notes |

We do **not** collect names, phone numbers, location data, device identifiers, usage analytics, or any advertising-related data.

---

### 3. How We Use Your Data

Your data is used solely to provide the SpeakingNotes service:

- **Authentication** — your email is used to create and identify your account
- **Note storage and sync** — your notes and categories are saved locally and optionally synced to the cloud so you can access them across sessions
- **App functionality** — voice input is transcribed on-device and converted to text; the resulting text is saved as a note

We do **not** sell, rent, share, or use your data for advertising, profiling, or any purpose other than operating the app.

---

### 4. Data Storage

Your data is stored in two places:

**Local storage (on your device)**
- Notes and categories are stored in a SQLite database on your device using the Drift library.
- This data remains on your device and is subject to your device's own security.

**Cloud storage (Firebase Firestore)**
- Notes and categories are synced to Google Firebase Firestore to enable backup and multi-session access.
- Firebase Firestore stores data in Google's secure cloud infrastructure.
- Data is protected by Firestore security rules that ensure each user can only access their own data.
- Firebase is operated by Google LLC. For more information, see [Google's Privacy Policy](https://policies.google.com/privacy).

---

### 5. Third-Party Services

SpeakingNotes uses the following third-party services:

| Service | Provider | Purpose |
|---------|----------|---------|
| Firebase Authentication | Google LLC | Secure sign-in with email |
| Firebase Firestore | Google LLC | Cloud storage and sync of notes and categories |
| Speech-to-Text (on-device) | Apple (iOS) / Google (Android) | Voice transcription; processed locally on device |

These services operate under their own privacy policies. We encourage you to review them:
- [Google Privacy Policy](https://policies.google.com/privacy)
- [Apple Privacy Policy](https://www.apple.com/legal/privacy/)

---

### 6. Data Security

We take reasonable steps to protect your data:

- Firestore security rules enforce that users can only read and write their own documents
- Firebase Authentication encrypts credentials in transit
- Local SQLite data is stored in your app's sandboxed private directory

No method of electronic storage or transmission is 100% secure. While we strive to protect your data, we cannot guarantee absolute security.

---

### 7. Your Rights

You have the following rights regarding your data:

- **Access** — you can view all your notes and categories within the app at any time
- **Delete notes/categories** — you can delete individual notes or categories directly within the app; deletion removes data from both local storage and Firebase
- **Delete your account** — you can request full account and data deletion by contacting us at the address below; we will delete your Firebase account and all associated cloud data within 30 days
- **Data portability** — your notes are stored as plain text and can be copied at any time

---

### 8. Children's Privacy

SpeakingNotes is not directed at children under the age of 13. We do not knowingly collect personal information from children under 13. If you believe a child has provided us with personal information, please contact us and we will delete it.

---

### 9. Changes to This Policy

We may update this Privacy Policy from time to time. The "Last Updated" date at the top of this document will reflect any changes. Continued use of the app after changes constitutes acceptance of the updated policy.

---

### 10. Contact

If you have any questions, requests, or concerns about this Privacy Policy or your data, please contact us:

**Email:** ozlemtonkal@gmail.com

---
---

## Türkçe

**Son Güncelleme: Haziran 2026**

### 1. Giriş

SpeakingNotes ("biz", "uygulama"), sesli not alma uygulamasıdır. Bu Gizlilik Politikası, hangi verileri topladığımızı, bu verileri nasıl kullandığımızı ve kişisel bilgilerinizle ilgili haklarınızı açıklamaktadır.

SpeakingNotes'u kullanarak bu politikada açıklanan uygulamaları kabul etmiş olursunuz.

---

### 2. Topladığımız Veriler

Yalnızca not alma hizmetini sunmak için gerekli verileri toplarız:

| Veri | Açıklama |
|------|----------|
| **E-posta adresi** | Hesap kimlik doğrulaması için kayıt sırasında alınır |
| **Ses kayıtları** | Konuşmadan metne dönüştürme sırasında cihazda geçici olarak yakalanır; ses, cihazın konuşma tanıma motoru tarafından işlenir ve depolanmaz veya yüklenmez |
| **Notlar** | Uygulamada oluşturduğunuz veya dikte ettiğiniz metin içerikleri |
| **Kategoriler** | Notlarınızı düzenlemek için oluşturduğunuz klasör/kategori adları |

Ad, telefon numarası, konum verisi, cihaz tanımlayıcıları, kullanım analitiği veya reklamla ilgili herhangi bir veri **toplamıyoruz**.

---

### 3. Verilerinizi Nasıl Kullanırız

Verileriniz yalnızca SpeakingNotes hizmetini sunmak amacıyla kullanılır:

- **Kimlik doğrulama** — e-postanız hesabınızı oluşturmak ve tanımlamak için kullanılır
- **Not depolama ve senkronizasyon** — notlarınız ve kategorileriniz yerel olarak kaydedilir ve isteğe bağlı olarak oturumlar arasında erişilebilir olmaları için buluta senkronize edilir
- **Uygulama işlevselliği** — sesli giriş cihazda metne dönüştürülür ve ortaya çıkan metin not olarak kaydedilir

Verilerinizi reklamcılık, profilleme veya uygulamayı işletmek dışında herhangi bir amaçla **satmıyor, kiralamıyor, paylaşmıyor veya kullanmıyoruz**.

---

### 4. Veri Depolama

Verileriniz iki yerde saklanır:

**Yerel depolama (cihazınızda)**
- Notlar ve kategoriler, Drift kütüphanesi kullanılarak cihazınızdaki bir SQLite veritabanında saklanır.
- Bu veriler cihazınızda kalır ve cihazınızın kendi güvenliğine tabidir.

**Bulut depolama (Firebase Firestore)**
- Notlar ve kategoriler, yedekleme ve çok oturumlu erişim için Google Firebase Firestore'a senkronize edilir.
- Firebase Firestore, verileri Google'ın güvenli bulut altyapısında saklar.
- Veriler, her kullanıcının yalnızca kendi verilerine erişebilmesini sağlayan Firestore güvenlik kurallarıyla korunur.
- Firebase, Google LLC tarafından işletilmektedir. Daha fazla bilgi için [Google Gizlilik Politikası](https://policies.google.com/privacy)'na bakınız.

---

### 5. Üçüncü Taraf Hizmetler

SpeakingNotes aşağıdaki üçüncü taraf hizmetleri kullanmaktadır:

| Hizmet | Sağlayıcı | Amaç |
|--------|-----------|------|
| Firebase Authentication | Google LLC | E-posta ile güvenli giriş |
| Firebase Firestore | Google LLC | Notların ve kategorilerin bulut depolama ve senkronizasyonu |
| Konuşmadan Metne (cihazda) | Apple (iOS) / Google (Android) | Sesli transkripsiyon; cihazda yerel olarak işlenir |

Bu hizmetler kendi gizlilik politikaları kapsamında faaliyet göstermektedir. İncelemenizi öneririz:
- [Google Gizlilik Politikası](https://policies.google.com/privacy)
- [Apple Gizlilik Politikası](https://www.apple.com/legal/privacy/)

---

### 6. Veri Güvenliği

Verilerinizi korumak için makul adımlar atıyoruz:

- Firestore güvenlik kuralları, kullanıcıların yalnızca kendi belgelerini okuyup yazabilmesini sağlar
- Firebase Authentication, kimlik bilgilerini iletim sırasında şifreler
- Yerel SQLite verileri, uygulamanızın izole edilmiş özel dizininde saklanır

Hiçbir elektronik depolama veya iletim yöntemi %100 güvenli değildir. Verilerinizi korumak için çaba göstermekle birlikte mutlak güvenliği garanti edemeyiz.

---

### 7. Haklarınız

Verilerinizle ilgili aşağıdaki haklara sahipsiniz:

- **Erişim** — notlarınızı ve kategorilerinizi uygulama içinde her zaman görüntüleyebilirsiniz
- **Not/kategori silme** — bireysel notları veya kategorileri doğrudan uygulama içinden silebilirsiniz; silme işlemi hem yerel depolamadan hem de Firebase'den veriyi kaldırır
- **Hesabınızı silme** — aşağıdaki adrese ulaşarak tam hesap ve veri silme talebinde bulunabilirsiniz; Firebase hesabınızı ve ilgili tüm bulut verilerinizi 30 gün içinde sileriz
- **Veri taşınabilirliği** — notlarınız düz metin olarak saklanır ve istediğiniz zaman kopyalanabilir

---

### 8. Çocukların Gizliliği

SpeakingNotes, 13 yaşın altındaki çocuklara yönelik değildir. 13 yaşın altındaki çocuklardan bilerek kişisel bilgi toplamıyoruz. Bir çocuğun bize kişisel bilgi sağladığına inanıyorsanız lütfen bizimle iletişime geçin; söz konusu bilgileri sileceğiz.

---

### 9. Bu Politikadaki Değişiklikler

Bu Gizlilik Politikasını zaman zaman güncelleyebiliriz. Bu belgenin üst kısmındaki "Son Güncelleme" tarihi herhangi bir değişikliği yansıtacaktır. Değişikliklerin ardından uygulamayı kullanmaya devam etmek, güncellenmiş politikayı kabul etmek anlamına gelir.

---

### 10. İletişim

Bu Gizlilik Politikası veya verilerinizle ilgili sorularınız, talepleriniz veya endişeleriniz için lütfen bizimle iletişime geçin:

**E-posta:** ozlemtonkal@gmail.com
