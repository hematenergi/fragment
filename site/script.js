const installPrompt = document.querySelector("#install-prompt code").textContent;
const copyButtons = document.querySelectorAll("[data-copy-install]");
const copyStatus = document.querySelector(".copy-status");

copyButtons.forEach((button) => {
  button.addEventListener("click", async () => {
    try {
      await navigator.clipboard.writeText(installPrompt);
      copyButtons.forEach((item) => { item.textContent = "Copied"; });
      copyStatus.textContent = "Install prompt copied to clipboard.";
    } catch {
      document.querySelector("#install-prompt").focus();
      copyStatus.textContent = "Select the prompt above to copy it.";
    }
  });
});
