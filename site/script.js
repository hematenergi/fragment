const installPrompt = document.querySelector("#install-prompt code").textContent;
const copyButtons = document.querySelectorAll("[data-copy-install]");
const copyStatus = document.querySelector(".copy-status");

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
  copyStatus.textContent = "";
};

copyButtons.forEach((button) => {
  button.addEventListener("click", async () => {
    clearTimeout(resetTimer);

    try {
      await navigator.clipboard.writeText(installPrompt);
      copyButtons.forEach((item) => { item.textContent = "Copied"; });
      copyStatus.textContent = "Install prompt copied to clipboard.";
      resetTimer = setTimeout(restoreLabels, 2400);
    } catch {
      // Clipboard ditolak (izin, atau halaman bukan konteks aman). Arahkan ke
      // teksnya supaya masih bisa disalin manual — label tombol tidak diubah,
      // karena tidak ada yang tersalin.
      document.querySelector("#install-prompt").focus();
      copyStatus.textContent = "Select the prompt above to copy it.";
    }
  });
});
