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

// Garis bawah header muncul hanya setelah halaman digulir, supaya bagian atas
// tetap bersih. Dibaca lewat atribut, bukan mengubah gaya inline.
const header = document.querySelector("[data-header]");
const syncHeader = () => {
  header.toggleAttribute("data-scrolled", window.scrollY > 8);
};
syncHeader();
addEventListener("scroll", syncHeader, { passive: true });

// Reveal saat masuk viewport.
//
// Elemennya TIDAK disembunyikan lewat HTML — kelas `data-reveal` baru dipasang
// di sini, jadi kalau JS mati atau IntersectionObserver tidak ada, halaman
// tetap tampil utuh. Menyembunyikan lebih dulu lewat CSS akan membuat konten
// hilang permanen pada kegagalan sekecil apa pun.
const prefersReducedMotion = matchMedia("(prefers-reduced-motion: reduce)").matches;

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
