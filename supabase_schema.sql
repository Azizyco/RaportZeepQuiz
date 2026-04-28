-- ================================================================
--  SUPABASE SQL SCHEMA
--  ZEP Quiz Report - Perundungan Digital
--  Jalankan di Supabase SQL Editor (https://supabase.com/dashboard)
-- ================================================================

-- 1. Tabel utama: data quiz siswa
CREATE TABLE IF NOT EXISTS quiz_students (
  id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  zep_name      TEXT NOT NULL,                    -- nama di ZEP
  full_name     TEXT DEFAULT '',                  -- nama lengkap (input manual)
  absen         TEXT DEFAULT '',                  -- no absen (input manual)
  accuracy      INT NOT NULL CHECK (accuracy >= 0 AND accuracy <= 100),
  correct_count INT NOT NULL CHECK (correct_count >= 0 AND correct_count <= 10),
  total_time    TEXT NOT NULL,                    -- "1m 32d", "3m 9d" etc
  submit_time   TEXT,                             -- waktu pengiriman
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Tabel jawaban per soal (10 soal per siswa)
CREATE TABLE IF NOT EXISTS quiz_answers (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  student_id  BIGINT NOT NULL REFERENCES quiz_students(id) ON DELETE CASCADE,
  question_no INT NOT NULL CHECK (question_no >= 1 AND question_no <= 10),
  is_correct  BOOLEAN NOT NULL,
  time_sec    INT DEFAULT 0,                      -- waktu menjawab dalam detik
  UNIQUE (student_id, question_no)
);

-- 3. Tabel kuesioner likert (10 pernyataan per siswa)
CREATE TABLE IF NOT EXISTS questionnaire_responses (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  student_id  BIGINT NOT NULL REFERENCES quiz_students(id) ON DELETE CASCADE,
  q1          INT CHECK (q1 >= 1 AND q1 <= 4),    -- Interaktivitas
  q2          INT CHECK (q2 >= 1 AND q2 <= 4),    -- Fitur interaktif
  q3          INT CHECK (q3 >= 1 AND q3 <= 4),    -- Pemahaman materi
  q4          INT CHECK (q4 >= 1 AND q4 <= 4),    -- Mengingat materi
  q5          INT CHECK (q5 >= 1 AND q5 <= 4),    -- Semangat belajar
  q6          INT CHECK (q6 >= 1 AND q6 <= 4),    -- Ingin pakai lagi
  q7          INT CHECK (q7 >= 1 AND q7 <= 4),    -- Berpikir cepat
  q8          INT CHECK (q8 >= 1 AND q8 <= 4),    -- Kompetisi sehat
  q9          INT CHECK (q9 >= 1 AND q9 <= 4),    -- Kemudahan
  q10         INT CHECK (q10 >= 1 AND q10 <= 4),  -- Efektivitas
  avg_score   DECIMAL(3,2) GENERATED ALWAYS AS (
    (COALESCE(q1,0)+COALESCE(q2,0)+COALESCE(q3,0)+COALESCE(q4,0)+
     COALESCE(q5,0)+COALESCE(q6,0)+COALESCE(q7,0)+COALESCE(q8,0)+
     COALESCE(q9,0)+COALESCE(q10,0)) / 10.0
  ) STORED,
  saran       TEXT DEFAULT '',                    -- saran/masukan
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (student_id)
);

-- 4. Tabel kuesioner dari CSV (nama tabel mengikuti file)
CREATE TABLE IF NOT EXISTS kuesioner_pemanfaatan_game_online_berbasis_browser_sebagai_media_edukasi_jawaban (
  id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  timestamp     TEXT NOT NULL,
  nama_lengkap  TEXT NOT NULL,
  nomor_absen   TEXT NOT NULL,
  q1            INT CHECK (q1 >= 1 AND q1 <= 4),
  q2            INT CHECK (q2 >= 1 AND q2 <= 4),
  q3            INT CHECK (q3 >= 1 AND q3 <= 4),
  q4            INT CHECK (q4 >= 1 AND q4 <= 4),
  q5            INT CHECK (q5 >= 1 AND q5 <= 4),
  q6            INT CHECK (q6 >= 1 AND q6 <= 4),
  q7            INT CHECK (q7 >= 1 AND q7 <= 4),
  q8            INT CHECK (q8 >= 1 AND q8 <= 4),
  q9            INT CHECK (q9 >= 1 AND q9 <= 4),
  q10           INT CHECK (q10 >= 1 AND q10 <= 4),
  saran         TEXT DEFAULT '',
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (timestamp, nama_lengkap, nomor_absen)
);

-- ================================================================
-- INDEXES untuk performa query
-- ================================================================
CREATE INDEX idx_quiz_students_accuracy ON quiz_students(accuracy DESC);
CREATE INDEX idx_quiz_students_absen ON quiz_students(absen);
CREATE INDEX idx_quiz_answers_student ON quiz_answers(student_id);
CREATE INDEX idx_questionnaire_student ON questionnaire_responses(student_id);
CREATE INDEX idx_kuesioner_absen ON kuesioner_pemanfaatan_game_online_berbasis_browser_sebagai_media_edukasi_jawaban(nomor_absen);

-- ================================================================
-- VIEW: Gabungan data lengkap (quiz + kuesioner)
-- ================================================================
CREATE OR REPLACE VIEW v_student_full_report AS
SELECT
  s.id,
  s.zep_name,
  s.full_name,
  s.absen,
  s.accuracy,
  s.correct_count,
  s.total_time,
  s.submit_time,
  qr.q1, qr.q2, qr.q3, qr.q4, qr.q5,
  qr.q6, qr.q7, qr.q8, qr.q9, qr.q10,
  qr.avg_score AS questionnaire_avg,
  qr.saran,
  CASE
    WHEN s.accuracy >= 90 THEN 'Sangat Baik'
    WHEN s.accuracy >= 70 THEN 'Baik'
    WHEN s.accuracy >= 50 THEN 'Cukup'
    ELSE 'Perlu Perbaikan'
  END AS kategori
FROM quiz_students s
LEFT JOIN questionnaire_responses qr ON qr.student_id = s.id
ORDER BY s.accuracy DESC, s.total_time ASC;

-- ================================================================
-- VIEW: Statistik per soal quiz
-- ================================================================
CREATE OR REPLACE VIEW v_question_stats AS
SELECT
  question_no,
  COUNT(*) FILTER (WHERE is_correct) AS correct_count,
  COUNT(*) AS total_count,
  ROUND(100.0 * COUNT(*) FILTER (WHERE is_correct) / COUNT(*), 1) AS correct_pct,
  ROUND(AVG(time_sec), 1) AS avg_time_sec
FROM quiz_answers
GROUP BY question_no
ORDER BY question_no;

-- ================================================================
-- VIEW: Statistik kuesioner per indikator
-- ================================================================
CREATE OR REPLACE VIEW v_questionnaire_stats AS
SELECT
  'A. Interaktivitas' AS indikator,
  ROUND(AVG((q1 + q2) / 2.0), 2) AS avg_score,
  COUNT(*) AS respondents
FROM questionnaire_responses
UNION ALL
SELECT 'B. Kognitif', ROUND(AVG((q3 + q4) / 2.0), 2), COUNT(*) FROM questionnaire_responses
UNION ALL
SELECT 'C. Motivasi', ROUND(AVG((q5 + q6) / 2.0), 2), COUNT(*) FROM questionnaire_responses
UNION ALL
SELECT 'D. Keterampilan Abad 21', ROUND(AVG((q7 + q8) / 2.0), 2), COUNT(*) FROM questionnaire_responses
UNION ALL
SELECT 'E. Efektivitas', ROUND(AVG((q9 + q10) / 2.0), 2), COUNT(*) FROM questionnaire_responses;

-- ================================================================
-- ROW LEVEL SECURITY (opsional, aktifkan sesuai kebutuhan)
-- ================================================================
-- ALTER TABLE quiz_students ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE quiz_answers ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE questionnaire_responses ENABLE ROW LEVEL SECURITY;

-- ================================================================
-- INSERT DATA QUIZ (31 siswa)
-- ================================================================
INSERT INTO quiz_students (zep_name, accuracy, correct_count, total_time, submit_time) VALUES
  ('Bogi 07', 50, 5, '1m 32d', '12:59:39'),
  ('21.', 20, 2, '1m 41d', '12:59:49'),
  ('Diwangga 11', 70, 7, '3m 9d', '13:01:16'),
  ('rafa 13', 80, 8, '1m 58d', '13:00:20'),
  ('Rafi/22', 70, 7, '2m 19d', '13:00:26'),
  ('nad☆19', 90, 9, '1m 37d', '12:59:45'),
  ('afr ahay 05', 80, 8, '1m 42d', '12:59:49'),
  ('alfin 3', 90, 9, '1m 37d', '12:59:45'),
  ('Septi 27', 10, 1, '4m 41d', '13:02:54'),
  ('nabila/17', 100, 10, '4m 6d', '13:02:12'),
  ('alfian (02)', 70, 7, '3m 1d', '13:01:08'),
  ('06 ratutu', 90, 9, '3m 27d', '13:01:35'),
  ('dina 10', 90, 9, '3m 14d', '13:01:23'),
  ('Kinan 15', 100, 10, '5m 0d', '13:03:09'),
  ('RENAAAAAAAAA25', 80, 8, '2m 40d', '13:00:48'),
  ('cindyy 09', 100, 10, '3m 41d', '13:01:49'),
  ('laras/29', 100, 10, '3m 21d', '13:03:16'),
  ('kai (12)', 80, 8, '2m 45d', '13:00:52'),
  ('aliyaa 04', 90, 9, '3m 6d', '13:01:14'),
  ('18 Aqila', 100, 10, '3m 11d', '13:01:20'),
  ('jackal', 80, 8, '3m 46d', '13:05:52'),
  ('inez_14', 50, 5, '6m 44d', '13:04:51'),
  ('20 naomiii', 90, 9, '3m 52d', '13:02:02'),
  ('tiwi/31', 90, 9, '4m 47d', '13:02:56'),
  ('acha_08', 90, 9, '2m 33d', '13:00:41'),
  ('akbar tungkak1', 80, 8, '2m 45d', '13:00:54'),
  ('Raka 23', 80, 8, '3m 3d', '13:01:13'),
  ('shintaa 28', 70, 7, '4m 3d', '13:02:11'),
  ('Vinsa 30', 70, 7, '6m 22d', '13:04:31'),
  ('Amaa 17', 100, 10, '6m 31d', '13:04:59'),
  ('Jackie 25', 60, 6, '2m 13d', '13:01:01');

-- ================================================================
-- INSERT DATA KUESIONER (CSV)
-- ================================================================
INSERT INTO kuesioner_pemanfaatan_game_online_berbasis_browser_sebagai_media_edukasi_jawaban
  (timestamp, nama_lengkap, nomor_absen, q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, saran)
VALUES
  ('28/04/2026 13:08:48','sakhi aulia renata','26',3,3,2,2,3,3,3,3,3,3,''),
  ('28/04/2026 13:09:28','Khairunnisa Rahma Kinanthi','15',3,3,3,3,3,3,3,3,3,3,'-'),
  ('28/04/2026 13:09:39','RASYA ARYA PANGESTU','25',1,1,1,1,3,3,3,3,3,3,'Tidak ada'),
  ('28/04/2026 13:10:02','IKHWAN RAFA ABQORI','13',4,4,3,4,3,4,3,4,3,4,''),
  ('28/04/2026 13:10:04','Syakina Larasati Alya Pranindita','29',2,3,3,3,3,3,3,3,3,2,''),
  ('28/04/2026 13:10:04','Aliya Saqina W.','04',4,4,4,3,4,3,4,3,3,3,''),
  ('28/04/2026 13:10:03','Vinsa Andaresta','30',4,4,4,4,4,4,4,4,4,3,''),
  ('28/04/2026 13:10:08','Alfin putra paramaditya','3',3,4,4,3,3,3,4,4,4,4,''),
  ('28/04/2026 13:10:10','Bogi prabangkara sakti','7',4,4,3,4,3,4,3,4,4,4,''),
  ('28/04/2026 13:10:20','Cindy Aulia Cahyani','09',3,4,4,3,3,4,4,4,4,2,'-'),
  ('28/04/2026 13:10:30','Inez kinanthi','14',3,3,3,3,4,3,3,3,3,3,'kalau mau buat game jangan yang susah susah kayak tadi, tapi game nya bagus'),
  ('28/04/2026 13:10:32','Callia Achazia Husna','08',4,4,4,3,3,4,4,3,3,3,'jangan ada jembatannya kak, susah nyebrangnya lho🙂🙂'),
  ('28/04/2026 13:10:44','Nadine Kusuma Atmaja','19',4,3,4,4,3,3,4,3,4,3,''),
  ('28/04/2026 13:10:49','akbar hidayat ramadhan','1',3,4,4,4,4,4,4,4,4,4,'sudah keren'),
  ('28/04/2026 13:10:59','nabila cahaya dewi','17',3,3,3,3,3,3,3,3,3,3,''),
  ('28/04/2026 13:11:51','Shinta zahra al qur''ani','28',3,3,3,3,3,3,3,3,3,3,''),
  ('28/04/2026 13:11:58','zahra pertiwi','31',3,4,4,3,4,3,4,3,3,4,''),
  ('28/04/2026 13:12:00','Dina Harnitasari','10',3,3,3,3,3,3,4,4,3,3,''),
  ('28/04/2026 13:12:01','Alfian Abdur Rohman','02',4,4,4,4,3,3,3,4,4,4,''),
  ('28/04/2026 13:12:01','RENAAAAAAAAAAAAAAA AZZAHRAAAA','25',4,4,4,4,4,4,4,4,2,3,''),
  ('28/04/2026 13:12:09','Nadia Aqila Nufah','18',4,4,4,4,4,4,3,4,4,3,'sinyal nya aja sih'),
  ('28/04/2026 13:12:25','Rafi Baihaqi','22',4,3,3,3,3,3,3,3,3,3,'-'),
  ('28/04/2026 13:12:26','Ayunda Ratu','06',3,3,3,3,2,3,4,4,3,3,'-'),
  ('28/04/2026 13:13:26','RAKA BUMI NUGROHO','23',3,3,2,2,3,3,3,3,2,2,'grafik nya kebih di tingkatkan'),
  ('28/04/2026 13:13:38','Diwangga Bairuny','11',4,4,3,3,3,3,3,3,3,2,'bagus'),
  ('28/04/2026 13:13:41','Onassisdaiky kedem','21',3,3,3,3,2,3,3,3,3,3,''),
  ('28/04/2026 13:14:06','Marhamah Az Zahro','16',3,3,4,3,3,3,3,3,3,3,''),
  ('28/04/2026 13:14:19','Dzakiyya Nur Azizah','12',2,3,3,3,3,3,3,4,3,2,'ofc, imo seru sih ✌🏻 tapi balik lagi ke pribadi masing-masing.'),
  ('28/04/2026 13:14:24','NAOMI FRISKA MAHARANI','20',4,3,3,2,2,3,4,3,3,2,'saran engga semua orang punya paket data jadi pelajaran menggunakan ZEP Quiz kurang bagi saya'),
  ('28/04/2026 13:15:53','Septi','27',2,2,4,3,1,3,4,2,4,3,'Cyiberstallking mengantin pantiutas darly');
