/**
 * ================================================================
 *  SKRIP GOOGLE APPS SCRIPT
 *  Kuesioner: Pemanfaatan Game Online Berbasis Browser 
 *             sebagai Media Edukasi (ZEP Quiz)
 * ================================================================
 * 
 *  CARA MENGGUNAKAN:
 *  1. Buka https://script.google.com
 *  2. Klik "Proyek baru" / "New Project"
 *  3. Hapus semua kode bawaan, lalu PASTE seluruh skrip ini
 *  4. Klik tombol ▶ Run (pilih fungsi: buatFormKuesioner)
 *  5. Saat diminta izin (Authorization), klik "Review Permissions" 
 *     → pilih akun Google → "Allow"
 *  6. Cek log (View → Logs) untuk mendapatkan link Google Form
 *  7. Form sudah siap disebarkan ke siswa!
 * 
 * ================================================================
 */

function buatFormKuesioner() {
  
  // ========================
  // 1. BUAT FORM BARU
  // ========================
  var form = FormApp.create('Kuesioner - Pemanfaatan Game Online Berbasis Browser sebagai Media Edukasi');
  
  form.setDescription(
    'Kuesioner ini bertujuan untuk mengetahui tanggapan siswa terhadap penggunaan ZEP Quiz ' +
    'sebagai media pembelajaran berbasis game online browser.\n\n' +
    'Petunjuk:\n' +
    '• Bacalah setiap pernyataan dengan seksama.\n' +
    '• Pilih SATU jawaban yang paling sesuai dengan pendapatmu.\n' +
    '• Tidak ada jawaban benar atau salah — jawablah dengan jujur.\n\n' +
    'Skala Penilaian:\n' +
    '1 = Sangat Tidak Setuju (STS)\n' +
    '2 = Tidak Setuju (TS)\n' +
    '3 = Setuju (S)\n' +
    '4 = Sangat Setuju (SS)'
  );
  
  form.setConfirmationMessage('Terima kasih atas partisipasimu! Jawabanmu sangat berarti untuk penelitian ini. 🙏');
  form.setIsQuiz(false);
  form.setCollectEmail(false);
  form.setLimitOneResponsePerUser(false);
  form.setAllowResponseEdits(false);
  
  // ========================
  // 2. BAGIAN IDENTITAS
  // ========================
  form.addPageBreakItem()
      .setTitle('Identitas Responden');
  
  form.addTextItem()
      .setTitle('Nama Lengkap')
      .setRequired(true);
  
  form.addTextItem()
      .setTitle('Kelas')
      .setHelpText('Contoh: 8A, 8B, 8C')
      .setRequired(true);
  
  // ========================
  // 3. SKALA LIKERT 4 TITIK
  // ========================
  var skala = [
    'Sangat Tidak Setuju (1)',
    'Tidak Setuju (2)',
    'Setuju (3)',
    'Sangat Setuju (4)'
  ];
  
  // ========================
  // 4. PERNYATAAN KUESIONER
  // ========================
  
  // --- INDIKATOR A: Interaktivitas dan Keterlibatan ---
  form.addPageBreakItem()
      .setTitle('A. Interaktivitas dan Keterlibatan Pembelajaran')
      .setHelpText('Indikator ini mengukur sejauh mana ZEP Quiz mendorong keterlibatan aktif dalam pembelajaran.');
  
  tambahPernyataanLikert(form, 
    '1. Bermain quiz di ZEP membuat saya lebih aktif dalam menjawab pertanyaan dibanding mengerjakan soal di kertas.',
    skala
  );
  
  tambahPernyataanLikert(form, 
    '2. Fitur interaktif dalam ZEP Quiz (skor, peringkat, waktu) membuat proses belajar terasa lebih seru.',
    skala
  );
  
  // --- INDIKATOR B: Pengembangan Kognitif ---
  form.addPageBreakItem()
      .setTitle('B. Pengembangan Kognitif dan Pemahaman Konsep')
      .setHelpText('Indikator ini mengukur sejauh mana ZEP Quiz membantu pemahaman materi.');
  
  tambahPernyataanLikert(form, 
    '3. Mengerjakan soal quiz di ZEP membantu saya lebih memahami materi perundungan digital yang sudah dipelajari.',
    skala
  );
  
  tambahPernyataanLikert(form, 
    '4. Saya merasa lebih mudah mengingat materi setelah mengerjakan quiz secara langsung di ZEP.',
    skala
  );
  
  // --- INDIKATOR C: Motivasi dan Aspek Afektif ---
  form.addPageBreakItem()
      .setTitle('C. Peningkatan Motivasi dan Aspek Afektif')
      .setHelpText('Indikator ini mengukur pengaruh ZEP Quiz terhadap semangat dan sikap belajar.');
  
  tambahPernyataanLikert(form, 
    '5. Saya merasa lebih bersemangat belajar ketika menggunakan ZEP Quiz dibanding metode pembelajaran biasa.',
    skala
  );
  
  tambahPernyataanLikert(form, 
    '6. Saya ingin menggunakan ZEP Quiz lagi untuk mempelajari materi pelajaran yang lain.',
    skala
  );
  
  // --- INDIKATOR D: Keterampilan Abad 21 ---
  form.addPageBreakItem()
      .setTitle('D. Keterampilan Abad 21 dan Pembelajaran Aktif')
      .setHelpText('Indikator ini mengukur pengembangan berpikir kritis dan kolaborasi.');
  
  tambahPernyataanLikert(form, 
    '7. ZEP Quiz mendorong saya untuk berpikir lebih cepat dan cermat saat menjawab pertanyaan.',
    skala
  );
  
  tambahPernyataanLikert(form, 
    '8. Bermain quiz bersama teman di ZEP membuat saya belajar untuk berkompetisi secara sehat.',
    skala
  );
  
  // --- INDIKATOR E: Efektivitas dan Kemudahan ---
  form.addPageBreakItem()
      .setTitle('E. Efektivitas dan Kemudahan Penggunaan')
      .setHelpText('Indikator ini mengukur kemudahan dan efektivitas ZEP Quiz sebagai media belajar.');
  
  tambahPernyataanLikert(form, 
    '9. Mengerjakan soal quiz di ZEP terasa mudah dan tidak membingungkan.',
    skala
  );
  
  tambahPernyataanLikert(form, 
    '10. Menurut saya, belajar menggunakan game berbasis browser seperti ZEP lebih efektif dibanding hanya mendengarkan penjelasan guru.',
    skala
  );
  
  // ========================
  // 5. SARAN (OPSIONAL)
  // ========================
  form.addPageBreakItem()
      .setTitle('Saran dan Masukan');
  
  form.addParagraphTextItem()
      .setTitle('Apakah ada saran atau masukan untuk pembelajaran menggunakan ZEP Quiz?')
      .setHelpText('(Opsional — boleh dikosongkan)')
      .setRequired(false);
  
  // ========================
  // 6. LOG URL FORM
  // ========================
  var formUrl = form.getPublishedUrl();
  var editUrl = form.getEditUrl();
  
  Logger.log('==========================================');
  Logger.log('✅ FORM BERHASIL DIBUAT!');
  Logger.log('==========================================');
  Logger.log('');
  Logger.log('🔗 Link untuk SISWA (isi kuesioner):');
  Logger.log(formUrl);
  Logger.log('');
  Logger.log('✏️ Link untuk EDIT form:');
  Logger.log(editUrl);
  Logger.log('');
  Logger.log('==========================================');
  Logger.log('Form juga tersedia di Google Drive Anda.');
  Logger.log('==========================================');
}


/**
 * Fungsi helper: Menambahkan 1 pernyataan Likert sebagai Multiple Choice
 */
function tambahPernyataanLikert(form, pernyataan, skala) {
  var item = form.addMultipleChoiceItem();
  item.setTitle(pernyataan);
  item.setRequired(true);
  
  var choices = [];
  for (var i = 0; i < skala.length; i++) {
    choices.push(item.createChoice(skala[i]));
  }
  item.setChoices(choices);
  
  return item;
}
