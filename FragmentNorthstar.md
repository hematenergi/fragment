# Fragment North Star

Strategic memo — posisi Fragment, apa yang harus dicuri dari kompetitor, apa yang harus diabaikan. Disusun 2026-10-08 dari evidence repo live + landscape research.

---

## 0. Masalah paling substantial: context bloat

Fragment bukan soal dokumentasi. Fragment soal **ekonomi context**.

AI agent — dari yang paling murah sampai kelas menengah — punya context window terbatas, dan setiap token yang terbuang = uang + lambat + halusinasi. Sesi baru yang menelan 96 decisions + 89 plans mentah-mentah itu bukan "well-informed", itu bloated. Tujuan Fragment: **agen murah pun jadi pinter dan cepat nyambung ke apa yang paling penting.**

Prinsip desain yang diusulkan (posisi desain dari analisis masalah, bukan temuan research):
1. **Tiered loading** — hot (`STATE.md`, selalu dibaca) → warm (index/ringkasan) → cold (full records, hanya on-demand). Jangan pernah load semuanya.
2. **Distilled, not raw** — tier decisions/lessons adalah hasil sulingan, bukan log mentah. Sulingan = kompresi yang tetap bisa dibaca model murah.
3. **Deterministic retrieval** — menemukan yang relevan tidak boleh butuh LLM (mahal, lambat). Keyword ranking, hash checks, token budgets: semuanya deterministik.

**North-star metric (diusulkan, belum ada metode ukur):** *tokens-to-competent* — berapa token yang dibutuhkan agen murah yang fresh untuk mencapai "ngerti apa yang paling penting dan bisa ambil aksi berguna pertama". Semua fitur di bawah dinilai dari seberapa jauh ia menurunkan angka itu. Langkah berikutnya: definisikan cara mengukurnya (benchmark harness — agen murah fresh → tugas standar → hitung token sampai aksi berguna pertama).

---

## 1. Posisi saat ini

**The loop:** praktik continuity lahir di medulla → diekstrak jadi Fragment v0.5.0 → template formal diadopsi ulang ke medulla + flimapp.

**Evidence keras:**
- Satu guard identik 588 baris (`docs-check.sh` v0.5.0) di dua repo produksi yang beda stack, beda stakes.
- medulla: 96 decisions, 51 lessons, 89 plans (repo-native Markdown).
- Tiering terbukti: local guard medulla 23 baris (runtime checks), flimapp 80 baris (release integrity + API-inventory co-change).

**Differentiator (temuan research — klaim negatif, dibaca dengan hati-hati):** sejauh ini **belum ditemukan** kompetitor yang menggabungkan ritual continuity repo-native dengan **CI yang gagal kalau handoff/state tidak di-update**. Kombinasi ide ini murah untuk ditiru — yang tidak murah adalah bukti adopsinya (satu guard identik jalan di dua repo produksi).

**Hubungan §0–§1 (satu headline, bukan dua produk):** §0 adalah headline — outcome yang dijual. CI enforcement adalah mekanisme yang *melayani* north star: ia menjaga hot tier (`STATE.md`/handoff) tetap fresh dan ritual tetap jalan. Batas jujurnya: CI yang sekarang menegakkan *kedisiplinan update*, bukan *kebenaran konten* — freshness decisions adalah tugas hash-pinned staleness (v0.7). Jadi di v0.6, `/recall` masih bisa me-load decision yang basi.

---

## 2. Landscape (Oktober 2026)

**Same-goal (paling dekat):**
- **whydone** — decision log Markdown di-commit ke repo; `/log`, `/recall` deterministik (keyword ranking, no LLM, no network), Stop-hook nudges, CI cuma validate format.
- **agentpack** — ledger JSON/JSONL: decisions, dead ends, checkpoints, verification, token budgets; **hash-pinned staleness** (decision yang merujuk file yang berubah otomatis di-flag stale); runtime/pre-commit gate.
- **GSD (Get Shit Done)** — `STATE.md` repo-native + project/phase/plan artifacts + structured handoff.

**Adjacent (punya senjata yang Fragment butuh):**
- **fredchu/claude-session-handoff** — multi-agent sharding (private + shared shards, merge saat session start, tidak ada agen menyentuh file agen lain); stdlib Python → macOS/Linux/Windows. *Catatan: store-nya machine-local (`~/.agents/handoff`), bukan repo-committed — kalau dicuri harus diadaptasi ke repo-native.*
- **Sting25/claude-code-handoff** — overwrite guard (exit 3, menolak menimpa handoff sesi yang lebih fresh); HMAC-signed handoffs.
- **dlog** — single-file stdlib CLI + **global cross-project log** (lessons personal lintas repo). *Catatan: fitur global log dari essay author, repo-nya belum deep-verified.*
- **keel-harness** — enforcement paling keras (blokir file write sampai handoff dibaca), tapi di hook level, bukan CI.
- **hipfire** — konvensi falsifikasi ("catat kenapa gagal").

**Ancestor (jangan ditiru):** Mem0, Zep, Letta — vector/graph memory infra. Anti-brand: Fragment menang justru karena zero-dependency dan human-readable.

---

## 3. Yang harus dicuri (ROI-ranked)

*Ranking ini sintesis penulis dari research + evidence repo — bukan kesimpulan report research.*

### #1 — `/recall` deterministik (dari whydone). ROI tertinggi.
Pain-nya sudah live: medulla punya 96 decisions, sesi baru tidak punya cara menemukan yang relevan. Keyword ranking deterministik = tanpa LLM, tanpa network, tanpa dependency — 100% on-brand Fragment. Effort kecil, impact ke semua install yang sudah skala. Ini senjata terbaik kompetitor terdekat; ambil, pasang di chassis yang lebih bagus.

### #2 — Hash-pinned staleness (dari agentpack). ROI tinggi.
Setiap decision mencatat hash file yang dirujuk; kalau file berubah, decision otomatis di-flag stale. Menyerang gap paling fundamental yang diakui Fragment sendiri: *"guard governs documents, not code."* Ini jembatan pertama dokumen → kode, dan on-brand dengan "verification recomputes, does not cite."

*Risiko desain: alert fatigue. Hash file utuh bikin edit trivial ikut nge-flag stale — dalam seminggu flag jadi noise dan diabaikan. Karena itu item ini pindah ke v0.7 dengan desain anti-fatigue: mekanisme acknowledge ("reviewed, still valid") atau pin granular (symbol/range), bukan hash file utuh.*

### #3 — Multi-agent sharding + stdlib Python (dari fredchu). ROI strategis.
Menutup dua admitted gap sekaligus: concurrency (>2 agents untested) dan cross-OS. Effort paling besar di antara ketiganya — kandidat headline v0.7.

### Quick wins (murah, langsung ambil):
- **Overwrite guard** (Sting25): tolak menimpa handoff sesi yang lebih fresh. Defensif, cocok untuk cerita concurrency. *(pindah ke v0.7 — satu tema dengan sharding)*

**Ditolak untuk sekarang:** global cross-project lessons log (dlog) — bertentangan dengan prinsip repo-native (§0: knowledge milik repo, bukan mesin), dan basisnya essay-only yang belum diverified.

---

## 4. Yang JANGAN dicuri

- **Hook-blocking (keel-harness):** mengencerkan differentiator terbesar Fragment — *CI as enforcer*. Beda filosofi, jangan dicampur.
- **Vector DB / memory infra (Mem0, Zep, Letta):** anti-brand total.

---

## 5. Roadmap

**v0.6 (fokus: tokens-to-competent — dipotong 8→4 item, review 2026-10-08):**
0. **Benchmark harness tokens-to-competent** — tanpa ini, ranking ROI di §3 cuma opini. Spesifikasi lengkap: `FragmentBenchmarkSpec.md` (di-freeze sebelum run pertama). *(usulan penulis)*
1. `/recall` deterministik **+ frontmatter/tags minimal** — tanpa metadata terstruktur, recall mengecewakan di 96+ decisions karena agen murah nulis query jelek. *(research: whydone, verified live; frontmatter usulan penulis)*
   - **Migrasi:** 96 decisions + 51 lessons di medulla perlu tagging ulang. Pakai LLM untuk tagging awal — sah, karena prinsip deterministik berlaku untuk *retrieval* (runtime), bukan untuk *build-time enrichment*. Hasil tagging di-review manusia. Cost ini dicatat karena repo adopter lain akan menghadapi hal yang sama.
2. STATE archival/pruning — hot tier (`STATE.md`) tidak boleh bloated seiring waktu. *(usulan penulis; langsung melayani §0)*
3. Token-budgeted loading: load context dengan budget token eksplisit, bukan "baca semua". *(research: agentpack, verified live)*

**Ditunda (bukan dibuang):** `docs-check.sh --stats`, `install.sh --verify`, `install.sh --tier=light` — tidak langsung menurunkan tokens-to-competent; dikerjakan kalau adopter yang minta.

**v0.7+ (strategis):**
1. Multi-agent sharding (fredchu-style) *(research: fredchu, verified live; perlu adaptasi ke repo-native)* + overwrite guard (Sting25) — satu tema concurrency
2. Hash-pinned staleness — **dengan desain anti-alert-fatigue**: acknowledge ("reviewed, still valid") atau pin granular (symbol/range), bukan hash file utuh *(research: agentpack; desain usulan penulis)*
3. Discoverability beyond `/recall` (query budgets ala agentpack) *(research: agentpack, verified live)*
4. Source-of-truth rules: Markdown vs machine memory *(evidence: konflik lessons.json/decision-log.json di medulla)*
5. Code/test evidence yang ter-link ke fragments *(usulan penulis)*
6. Official cross-OS support atau CI-only mode *(research: fredchu untuk cross-OS; CI-only usulan penulis)* — evaluasi: port guard 588 baris ke stdlib Python sekalian, biar tidak maintain dua runtime
7. Optional strict frontmatter schema *(usulan penulis)*

---

## 6. Conviction

- **Lapangannya sepi — sinyal ambigu.** Kompetitor terbesar (agentpack) cuma 17 stars, whydone 1 star. Bisa berarti peluang, bisa berarti demand-nya kecil. Satu adopter eksternal yang menjawab ini. *(17/1 stars verified live)*
- **Adopter eksternal #1 adalah track paralel dengan time-box, bukan gerbang rilis.** *(opini strategis penulis)* Definisi v0.6 selesai: benchmark ada angkanya + 4 item shipped — tidak bergantung ke pihak luar. Adopter #1 = milestone terpisah: 30 hari outreach, dimulai paralel dengan pengerjaan v0.6.
- **Evidence intact, tidak ada yang difabrikasi.** Marketing boleh persuasif.

## 7. Honesty block

- n=2, kedua repo dijalankan author sendiri — bukan validasi pihak ketiga.
- CI runs disimpulkan dari evidence repo, bukan diobservasi langsung dari workflow runs.
- Dual-memory conflict (Markdown vs JSON) masih unproven sebagai design problem.
- Beberapa kandidat landscape sekunder berasal dari search snippets saja, belum live-verified.
- Ranking ROI, prinsip §0, dan metrik tokens-to-competent adalah sintesis/usulan penulis — bukan temuan research. Item roadmap bertanda *(usulan penulis)* belum punya basis research dan perlu divalidasi lewat adopter.
- v0.6 sengaja dipotong 8→4 item (review 2026-10-08): tanpa benchmark dan adopter, ranking ROI tidak lebih dari opini.
- CI Fragment saat ini menegakkan kedisiplinan update, bukan kebenaran konten. `/recall` v0.6 masih bisa me-load decision yang basi sampai hash-pinned staleness (v0.7) ada.
