const installPrompt = document.querySelector("#install-prompt code").textContent;
const copyButtons = document.querySelectorAll("[data-copy-install]");
const copyStatuses = document.querySelectorAll(".copy-status");

const setCopyStatus = (message) => {
  copyStatuses.forEach((status) => { status.textContent = message; });
};

// Label asli tiap tombol disimpan sebelum diganti. Tanpa ini tombolnya tetap
// terbaca "Copied" selamanya setelah sekali klik, dan kehilangan petunjuk soal
// apa yang sebenarnya bisa dilakukan.
copyButtons.forEach((button) => {
  button.dataset.label = button.textContent;
});

let resetTimer;

const restoreLabels = () => {
  copyButtons.forEach((button) => {
    button.textContent = button.dataset.label;
  });
  setCopyStatus("");
};

copyButtons.forEach((button) => {
  button.addEventListener("click", async () => {
    clearTimeout(resetTimer);

    try {
      await navigator.clipboard.writeText(installPrompt);
      copyButtons.forEach((item) => { item.textContent = "Copied"; });
      setCopyStatus("Install prompt copied to clipboard.");
      resetTimer = setTimeout(restoreLabels, 2400);
    } catch {
      // Clipboard ditolak (izin, atau halaman bukan konteks aman). Arahkan ke
      // teksnya supaya masih bisa disalin manual — label tombol tidak diubah,
      // karena tidak ada yang tersalin.
      document.querySelector("#install-prompt").focus();
      setCopyStatus("Select the prompt above to copy it.");
    }
  });
});

const prefersReducedMotion = matchMedia("(prefers-reduced-motion: reduce)").matches;

// Lenis.
//
// Dimuat dari `vendor/`, bukan CDN: halaman ini mengklaim "no runtime
// dependencies", jadi paling tidak ia tidak boleh menambah permintaan ke pihak
// ketiga hanya demi gulir yang halus.
//
// Tiga hal yang membuatnya aman untuk gagal:
//   1. `prefers-reduced-motion` mematikannya sepenuhnya. Gulir yang diperhalus
//      adalah gerakan, dan sebagian orang sakit karenanya.
//   2. Kalau skripnya tidak termuat, `globalThis.Lenis` tidak ada dan halaman
//      tetap bergulir seperti biasa — `html:not(.lenis)` mengembalikan
//      `scroll-behavior: smooth` bawaan peramban.
//   3. Ia memakai posisi gulir asli, jadi `window.scrollY`,
//      IntersectionObserver, dan tautan jangkar tetap bekerja.
let lenis = null;

if (!prefersReducedMotion && typeof globalThis.Lenis === "function") {
  lenis = new globalThis.Lenis({
    duration: 1.05,
    // Peluruhan eksponensial: cepat di awal, berhenti tanpa pantulan. Halaman
    // ini bersifat editorial, bukan showreel — geraknya harus tidak terasa.
    easing: (t) => 1 - Math.pow(1 - t, 3),
    smoothWheel: true,
    // Sentuhan dibiarkan asli. Momentum bawaan iOS sudah benar, dan
    // menggantinya selalu terasa lebih buruk di perangkat sungguhan.
    syncTouch: false,
  });

  const raf = (time) => {
    lenis.raf(time);
    requestAnimationFrame(raf);
  };
  requestAnimationFrame(raf);

  // Tautan dalam-halaman harus melewati Lenis, kalau tidak peramban melompat
  // dan Lenis menariknya kembali.
  document.querySelectorAll('a[href^="#"]').forEach((link) => {
    link.addEventListener("click", (event) => {
      const id = link.getAttribute("href");
      if (id === "#" || event.metaKey || event.ctrlKey || event.shiftKey) return;
      const target = id === "#top" ? 0 : document.querySelector(id);
      if (target === null) return;
      event.preventDefault();
      lenis.scrollTo(target, { offset: -24 });
      history.pushState(null, "", id);
    });
  });
}

// Garis bawah header muncul hanya setelah halaman digulir, supaya bagian atas
// tetap bersih. Dibaca lewat atribut, bukan mengubah gaya inline.
const header = document.querySelector("[data-header]");
const syncHeader = () => {
  header.toggleAttribute("data-scrolled", window.scrollY > 8);
};
syncHeader();
addEventListener("scroll", syncHeader, { passive: true });
// Lenis memancarkan peristiwanya sendiri; tanpa ini garis header tertinggal
// satu bingkai di belakang gulir.
if (lenis) lenis.on("scroll", syncHeader);

// Reveal saat masuk viewport.
//
// Elemennya TIDAK disembunyikan lewat HTML — kelas `data-reveal` baru dipasang
// di sini, jadi kalau JS mati atau IntersectionObserver tidak ada, halaman
// tetap tampil utuh. Menyembunyikan lebih dulu lewat CSS akan membuat konten
// hilang permanen pada kegagalan sekecil apa pun.

if (!prefersReducedMotion && "IntersectionObserver" in window) {
  const targets = document.querySelectorAll(
    ".hero-lede, .transcript .turn, .section-head, .file-card, .what-copy, .terminal, .why-note, .proof-quote, .proof-foot, .install-prompt"
  );

  targets.forEach((el) => el.setAttribute("data-reveal", ""));

  // Kartu transkrip muncul berurutan supaya percakapannya terbaca sebagai
  // urutan waktu, bukan tiga kotak yang muncul bersamaan.
  document.querySelectorAll(".transcript .turn").forEach((el, i) => {
    el.style.setProperty("--delay", `${i * 110}ms`);
  });

  const reveal = (el) => el.setAttribute("data-shown", "");

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        reveal(entry.target);
        observer.unobserve(entry.target);
      });
    },
    { rootMargin: "0px 0px -12% 0px", threshold: 0.08 }
  );

  targets.forEach((el) => observer.observe(el));

  // Jaring pengaman. Elemen yang dianimasikan mulai dari `opacity: 0`, jadi
  // apa pun yang membuat observer tidak pernah menyala — viewport berukuran
  // nol, tab yang di-prerender, bug peramban — akan menyembunyikan konten
  // secara permanen. Setelah tiga detik semuanya ditampilkan apa adanya.
  setTimeout(() => targets.forEach(reveal), 3000);
}
