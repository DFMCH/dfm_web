(function () {
  const dfmWeb = window.DfmWeb || (window.DfmWeb = {});
  if (dfmWeb.eventsRegistered) {
    dfmWeb.activate_dfm_web();
    return;
  }

  function isDesktop() {
    return window.matchMedia("(min-width: 1024px)").matches;
  }

  function setMenuOpen(menu, open) {
    menu.classList.toggle("is_open", open);
    const toggle = menu.parentElement.querySelector("[data-dfm-menu-toggle]");
    if (toggle) toggle.setAttribute("aria-expanded", String(isDesktop() || open));
  }

  function resetMenus() {
    document.querySelectorAll("nav #nav ul.has_hamburger").forEach(function (menu) {
      setMenuOpen(menu, false);
    });
  }

  dfmWeb.activate_dfm_web = function () {
    document.querySelectorAll("nav #nav ul.right").forEach(function (menu, index) {
      if (menu.children.length < 2) return;
      menu.classList.add("has_hamburger");
      if (!menu.id) menu.id = "dfm-web-menu-" + index;
      let toggle = menu.parentElement.querySelector("[data-dfm-menu-toggle]");
      if (!toggle) {
        toggle = document.createElement("button");
        toggle.type = "button";
        toggle.id = "hamburger";
        toggle.setAttribute("data-dfm-menu-toggle", "");
        toggle.setAttribute("aria-label", "Toggle navigation");
        toggle.setAttribute("aria-controls", menu.id);
        menu.after(toggle);
      }
      setMenuOpen(menu, menu.classList.contains("is_open"));
    });

    document.querySelectorAll("#notice > div, #alert > div").forEach(function (message) {
      if (message.querySelector("[data-dfm-dismiss]")) return;
      const button = document.createElement("button");
      button.type = "button";
      button.className = "dfm_flash_close";
      button.setAttribute("data-dfm-dismiss", "");
      button.setAttribute("aria-label", "Dismiss " + message.parentElement.id);
      button.textContent = "\u00d7";
      message.prepend(button);
    });

    document.querySelectorAll("#nav > ul > li > ul").forEach(function (menu) {
      menu.classList.toggle("crowded", menu.children.length > 10);
    });
  };

  document.addEventListener("click", function (event) {
    if (!(event.target instanceof Element)) return;
    const toggle = event.target.closest("nav [data-dfm-menu-toggle]");
    if (toggle) {
      const menu = document.getElementById(toggle.getAttribute("aria-controls"));
      if (menu) setMenuOpen(menu, !menu.classList.contains("is_open"));
      return;
    }
    const dismiss = event.target.closest("[data-dfm-dismiss]");
    if (dismiss) {
      const message = dismiss.closest("#notice, #alert");
      if (message) message.hidden = true;
      return;
    }
    if (!isDesktop() && event.target.closest("main")) resetMenus();
  });

  document.addEventListener("keydown", function (event) {
    if (event.key !== "Escape") return;
    const openMenu = document.querySelector("nav #nav ul.has_hamburger.is_open");
    resetMenus();
    if (openMenu) {
      const toggle = openMenu.parentElement.querySelector("[data-dfm-menu-toggle]");
      if (toggle && !isDesktop()) toggle.focus();
    }
    document.querySelectorAll("#notice, #alert").forEach(function (message) {
      message.hidden = true;
    });
  });

  window.addEventListener("resize", resetMenus);
  document.addEventListener("turbo:load", dfmWeb.activate_dfm_web);
  document.addEventListener("turbo:frame-load", dfmWeb.activate_dfm_web);
  document.addEventListener("turbo:before-cache", function () {
    resetMenus();
    document.querySelectorAll("#notice, #alert").forEach(function (message) {
      message.remove();
    });
  });
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", dfmWeb.activate_dfm_web, { once: true });
  } else {
    dfmWeb.activate_dfm_web();
  }
  dfmWeb.eventsRegistered = true;
})();
