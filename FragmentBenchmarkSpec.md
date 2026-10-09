# Fragment Benchmark Spec — v0.6 item #0

Spesifikasi ini **di-freeze sebelum run pertama**. Tujuannya: mengukur *tokens-to-competent* secara objektif, agar ranking ROI di `FragmentNorthstar.md` §3 bukan opini.

---

## 1. Definisi operasional "competent" + protokol pengukuran

**Protokol tetap** per run (identik di semua kondisi):

1. **Fase onboarding** — agen diberi akses repo sesuai kondisi (A/B/C), tanpa pertanyaan. Onboarding berakhir saat agen memberi **sinyal siap** (format sinyal ditulis di system prompt), **atau** saat mencapai **50% budget token** — mana yang duluan. Tanpa aturan berhenti, agen (terutama di kondisi A) bisa eksplorasi sampai budget habis.
2. **Kuis** — 10 pertanyaan standar diberikan **sekaligus** (bukan per turn — pertanyaan per turn menyuntik informasi dan memakan token secara incremental). **Selama kuis agen boleh memakai tools** (open-book): lebih realistis, dan semua token tetap terhitung.
3. **Task** — 1 task standar dengan kriteria lulus otomatis.

Agen dinyatakan **competent** jika: skor kuis ≥ 7/10 **DAN** task lulus.

**Budget maksimum & kegagalan:** setiap run dibatasi **N input tokens (kumulatif)** — N ditentukan dari **satu dry run kondisi B di medulla sebelum freeze** (estimasi awal: 1–2 juta; lihat §3 dan §7). Jika competent belum tercapai saat budget habis → run dicatat **gagal** dan tidak punya angka tokens-to-competent.

**Yang dilaporkan per kondisi:**
- Metrik utama = **success rate** (run competent / total run).
- Metrik sekunder = **median + range** tokens-to-competent, *hanya dari run yang berhasil*.
- **Aturan perbandingan median:** median dua kondisi hanya dibandingkan jika **kedua** kondisi berhasil ≥3/5 run. Jika tidak (mis. C 5/5 vs A 1/5), perbandingan median tidak bermakna — cukup laporkan success rate.

Tanpa success rate, median bias ke run yang berhasil saja (run gagal hilang dari statistik).

## 2. Kondisi yang dibandingkan

| Kondisi | Setup |
|---|---|
| A — tanpa Fragment (baseline realistis) | **File docs tetap ada di repo** (decisions/lessons/plans tidak dihapus); agen eksplorasi bebas **tanpa** `STATE.md`, `/recall`, atau tooling Fragment. Ini kondisi repo kebanyakan — A menguji *cara load*, bukan *ada/tidaknya knowledge*. Untuk Draupnir: **file knowledge base hasil ekstraksi ikut ada** di kondisi A — yang dilepas hanya tooling Fragment (`STATE.md` hot-load, `/recall`, token budgets). Tanpa penegasan ini, A di Draupnir kembali menguji ada/tidaknya knowledge.
| B — load-semua | Seluruh decisions/lessons/plans dimuat mentah di awal sesi. **Kebijakan truncasi (ditulis sebelum run):** jika total melebihi 80% context window model, potong dari dokumen terlama; catat % yang terpotong per run dan laporkan mediannya. |
| C — Fragment | Dipakai **sesuai dokumentasi versi yang diuji**. Fase baseline = prosedur v0.5.0 yang terdokumentasi (`STATE.md` + decisions/lessons/plans sesuai agent protocol v0.5.0 — tanpa `/recall` dan tanpa token budgets, karena belum ada). Fase validasi (pasca-v0.6) = `STATE.md` + `/recall` + token-budgeted loading sesuai dokumentasi v0.6. Prosedur exact per versi ditetapkan saat harness dikunci (§7.8). |

Kondisi B penting: ia membuktikan Fragment menang bukan karena "ada dokumentasi", tapi karena *cara me-load-nya* (selective + budgeted).

## 3. Harness, model, grading

**Agent harness — dikunci sebelum run, identik di semua kondisi:**
- Tools: `read` (baca file), `ls` (list direktori), `grep` (cari teks), `edit`/`write` (ubah file — perlu untuk task), `run` (eksekusi test, shell terbatas). *[usulan — konfirmasi sebelum freeze]*
- **Environment `run`:** container yang **sama** untuk ketiga kondisi dan kedua repo. Sebelum freeze, pastikan test dari PR yang di-merge **hijau** di environment itu — kalau test gagal karena setup, semua kondisi gagal dan datanya tidak berarti.
- System prompt: satu prompt baku untuk semua kondisi — mencakup definisi tools, format sinyal "siap" onboarding, dan aturan berhenti. Ditulis & dicatat sebelum freeze.
- Loop: satu framework loop yang sama untuk semua run. *[ditetapkan sebelum freeze — opsi: loop ReAct sederhana]*

Kondisi A sangat sensitif terhadap tool access — tanpa harness yang dikunci, perbandingan tidak sah.

**Model & runs:**
- Model uji: **model murah generasi terbaru** (kelas GPT-5-mini — masa pensiun 2027). **Bukan GPT-4o-mini**: pensiun Azure-nya 2026-10-01 baru saja lewat dan statusnya tidak konsisten antar-platform — model benchmark harus bisa di-re-run untuk v0.7. Pin versi exact saat freeze; **verifikasi ulang ketersediaan sebelum setiap re-run**. *[keputusan: cek ulang saat freeze]*
- LLM-judge (untuk grading): model **berbeda** dari model uji, dengan rubrik ketat.
- **Temperature: dikunci ke nilai yang didukung model.** *[verifikasi di dokumentasi API saat pinning — model reasoning sering hanya menerima nilai default; catat nilai aktual yang dipakai, bukan asumsi]*
- **Reasoning effort: dikunci** (setara temperature — memengaruhi kualitas jawaban dan jumlah token). Nilai ditetapkan saat pinning.
- **Reasoning tokens dilaporkan terpisah.** Token berpikir ditagih sebagai output: metrik utama (input kumulatif) aman, tapi metrik sekunder (total) bisa didominasi reasoning tokens — pisahkan agar angkanya bisa dibaca.
- n=5 per kondisi per repo (total 30 run). Hasil dilabeli **"indikatif"** — delta kecil dengan range yang overlap belum boleh diklaim sebagai kemenangan.

**Token yang dihitung:** **input tokens kumulatif** — cara API menagih: seluruh context dikirim ulang setiap turn, jadi setiap turn menghitung ulang semuanya. Ini biaya context bloat yang sebenarnya (§0). **Prompt caching diabaikan** — hitung token mentah agar hasil tidak bergantung ke fitur diskon provider. Total tokens (input+output) sebagai metrik sekunder.

*Kenapa definisi ini menentukan hasil: dengan hitungan unik, kondisi B terlihat murah; dengan hitungan kumulatif, B menghabiskan budget kecil dalam beberapa turn. Budget yang terlalu kecil membuat B gagal secara konstruksi — B jadi sedotan kosong, bukan baseline. Karena itu budget naik ke orde juta, ditentukan dari dry run dengan model final.*

*Batas truncasi B = 80% dari context window model yang di-pin (rumus, bukan angka — dihitung ulang setelah model final ditetapkan).*

**Penilaian kuis:** butuh **answer key + rubrik tertulis** sebelum run pertama. Penilai **buta terhadap kondisi**: manusia yang tidak tahu run berasal dari kondisi mana, atau LLM-judge dari model berbeda dengan rubrik ketat.

## 4. Materi uji

- **10 pertanyaan standar:** 3 fakta arsitektur · 3 alasan keputusan (dari decisions) · 2 navigasi/status (di mana X, status terakhir Y) · **2 jebakan** (hal yang sudah berubah / decision yang stale — menguji apakah agen kecele me-load info basi).
- **Skor jebakan dilaporkan terpisah (x/2)**, tidak dilebur ke agregat 7/10. Ini metrik kejujuran untuk kelemahan C yang sudah diakui di memo (stale decisions di v0.6) — agen bisa lolos 7/10 sambil gagal di kedua jebakan, dan itu harus kelihatan.
- **Repo non-author:** soal diambil dari **sejarah repo itu sendiri (PR, issue, commit message)**, bukan dari dokumen Fragment yang ditulis author. Kalau author yang menulis docs-nya lalu menulis soalnya juga, bias-nya muter balik.
  - **Soal jebakan di repo OSS:** ambil dari keputusan yang tercatat di issue lalu **dibalik oleh PR berikutnya** — itu stale decision alami, bukan karangan.
  - **Task:** ambil dari **issue yang sudah ditutup**, dengan kriteria lulus dari **test PR yang di-merge** — task dan pass criteria-nya peninggalan sejarah repo, bukan karangan author.
- **1 task standar:** kecil, dengan kriteria lulus otomatis (test harus hijau / skrip cek lulus).

**Syarat pemilihan repo OSS (anti-kontaminasi training data):** repo populer kemungkinan sudah ada di training data model. Di kondisi A, agen bisa menjawab soal arsitektur dari "ingatan" pretraining, bukan dari eksplorasi repo — menguntungkan A secara palsu dan mengecilkan delta C vs A. Karena itu repo evaluasi harus memenuhi:
1. Test suite jalan di container tanpa setup eksotis (tanpa database eksternal, secret, atau GPU).
2. Sejarah issue/PR cukup kaya, termasuk ≥1 keputusan di issue yang kemudian dibalik oleh PR berikutnya (bahan soal jebakan).
3. Ukuran dan bahasa mirip medulla. *(koreksi pasca-pre-check: Draupnir ternyata monorepo ~54rb LOC/~470 file — lebih besar dari medulla, bukan lebih kecil; tetap diterima karena kriteria sejarah lebih kritis)*
4. Risiko kontaminasi rendah: tidak terlalu populer (hindari ribuan stars yang sering dibahas), **atau** soal diambil dari issue/PR **setelah knowledge cutoff** model yang di-pin — cara paling bersih, karena model tidak mungkin sudah tahu jawabannya.
5. Lisensi permisif (bebas memasang Fragment dan mempublikasikan hasil benchmark).

**Bootstrap knowledge base repo OSS (anti-bias pintu belakang):** kondisi B dan C butuh decisions/lessons/STATE untuk repo ini. Kalau knowledge base ditulis tangan *setelah* soal diketahui, bias yang ditutup §4 masuk lagi lewat pintu belakang. Prosedur tetap:
1. **Pin commit SHA** Draupnir saat clone — repo ini di-push hampir tiap hari. KB, soal, answer key, dan repo yang dilihat agen harus dari **satu snapshot yang sama**. Catat SHA di spec.
2. Isi knowledge base secara mekanis: ekstraksi LLM dari CHANGELOG, `docs/`, dan PR yang di-merge, dengan **prompt baku yang dicatat** — bukan ditulis tangan.
3. **Catat model + versi ekstraksi** bersama hasilnya. Hasil cukup dihasilkan sekali lalu di-freeze — nondeterminisme ekstraksi bukan masalah; yang penting prosesnya bisa diaudit.
4. **Larangan edit manual setelah ekstraksi.** Isi KB tidak boleh diubah, kecuali perbaikan format yang bikin file gagal di-parse. Kalau ekstraksi menyimpan keputusan lama dan versi yang membaliknya sekaligus — biarkan. Itu justru kondisi nyata yang diuji soal jebakan.
5. Freeze knowledge base.
6. Baru tulis soal dari sejarah repo.

Ini juga ujian realistis untuk cerita adopter: begitulah repo orang lain akan bootstrap Fragment.

**Catatan monorepo (berlaku untuk Draupnir):** beberapa paket (mis. `matrix-protection-suite`) dulunya repo terpisah. Saat menambang issue→PR yang dibalik untuk soal jebakan, pastikan diskusi keputusannya ada di dalam monorepo saat ini — kalau soal merujuk keputusan di repo lama yang sudah tidak ada, agen tidak bisa menemukan jawabannya di kondisi mana pun.

## 5. Anti-Goodhart & tuning vs evaluasi

- Spec di-freeze sebelum run pertama; perubahan spec setelah melihat hasil = benchmark baru, angka lama dibuang.
- **medulla = repo tuning. Repo OSS non-author = repo evaluasi. Angka headline hanya dari repo evaluasi.**
- **No test-set peeking:** jangan tuning Fragment dari hasil benchmark lalu melaporkan angka dari run yang sama.
- Minimal 1 repo benchmark bukan milik author (lihat §4 untuk aturan penulisan soal).
- **Asimetri kualitas knowledge base diakui:** KB medulla dikurasi tangan selama 5 bulan; KB Draupnir hasil ekstraksi mekanis. Angka antar-repo tidak dibandingkan langsung (headline hanya dari Draupnir). Sisi baiknya: angka Draupnir lebih mewakili pengalaman adopter baru.

## 6. Kriteria selesai

Benchmark dianggap selesai jika: ketiga kondisi sudah di-run n=5 di ≥2 repo (medulla + 1 OSS non-author), answer key + rubrik selesai sebelum run pertama, dan spec tidak berubah mid-run. **Angka target tidak ditetapkan di muka** — yang diukur adalah delta (C vs A, C vs B) + success rate, bukan angka absolut.

**Dua fase benchmark:** fase baseline mengukur Fragment v0.5.0 (kondisi C = prosedur v0.5.0). Setelah 3 fitur v0.6 selesai di-develop, fase validasi mengulang protokol penuh dengan kondisi C = prosedur v0.6 — delta C(v0.6) vs C(v0.5.0) mengukur kontribusi fitur v0.6 secara spesifik. Kriteria §6 berlaku per fase; setiap dataset diberi label fase yang jelas.

**Catatan biaya:** total 30 run dengan model murah = murah. Biaya termahal adalah waktu menulis soal + answer key — kerjakan itu duluan.

## 7. Urutan kerja menuju freeze

1. **Pilih repo OSS** — diputuskan: **Draupnir** (`the-draupnir-project/Draupnir`). Dasar: 404 merged PR / 214 closed issues, test hijau di container bersih (pre-check), lisensi AFL-3.0/Apache-2.0, kontaminasi sedang → soal wajib post-cutoff.
2. **Tulis soal + answer key + rubrik untuk medulla** (dibutuhkan untuk dry run).
3. **Verifikasi + pin model** (tersedia, tidak dijadwalkan pensiun, versi exact) + **siapkan container** + pastikan test PR hijau di environment itu. *Harus sebelum dry run — kalibrasi budget tidak sah kalau jalan di model yang berbeda dari model final.*
4. **Dry run kondisi B di medulla** (dengan model final) → tentukan budget N (beri headroom wajar, mis. 1,5–2x pemakaian dry run). Ini kalibrasi, bukan data — angkanya tidak dilaporkan.
5. **Clone Draupnir di container final, catat commit SHA**, pastikan test suite hijau (pre-check sudah hijau di Linux bersih: Jest + Mocha — ulangi di environment final). SHA dicatat di spec — semua artefak (KB, soal, answer key, repo yang dilihat agen) merujuk snapshot ini.
6. **Bootstrap knowledge base Draupnir** — ekstraksi LLM mekanis dari CHANGELOG/docs/PR-merged dengan prompt baku (`bench/extract-prompt.md`, lihat §4), lalu freeze. *Sebelum tulis soal — menutup bias pintu belakang.*
   - Prompt di-commit + push **sebelum** ekstraksi dijalankan. Verifikasi push tercatat di remote: `git log origin/HEAD -1 --format="%H %ci"` — SHA harus sama dengan commit lokal.
   - Catat dua jangkar di sini, terpisah: **SHA commit prompt** (membuktikan *kapan* prompt dikunci) dan **SHA snapshot Draupnir** (membuktikan *snapshot mana* yang diekstrak).
   - SHA commit prompt: `4582cec728a46aa9122005314fd923e17b937052` (committed + pushed 2026-10-08, placeholders unfilled)
   - SHA snapshot Draupnir: `[FILL — dari langkah 5]`
7. **Tulis soal + answer key + rubrik untuk Draupnir** (dari sejarah repo: issue/PR post-cutoff; jebakan dari keputusan yang dibalik).
8. **Kunci harness** — tools final, system prompt, loop, temperature/reasoning effort.
9. Freeze spec. Baru run.
