/* Cavi-Medias — site réalisé par ConforDev */
(function () {
  var doc = document.documentElement;
  var header = document.querySelector('.site-header');
  var burger = document.querySelector('.burger');

  function onScroll() {
    if (header) header.classList.toggle('scrolled', window.scrollY > 20);
  }
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  if (burger) {
    burger.addEventListener('click', function () {
      var open = doc.classList.toggle('menu-open');
      burger.setAttribute('aria-expanded', open ? 'true' : 'false');
      burger.setAttribute('aria-label', open ? 'Fermer le menu' : 'Ouvrir le menu');
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && doc.classList.contains('menu-open')) burger.click();
    });
  }

  /* Boutons de partage : URL et titre de la page courante */
  var url = encodeURIComponent(location.href);
  var title = encodeURIComponent(document.title);
  var targets = {
    facebook: 'https://www.facebook.com/sharer/sharer.php?u=' + url,
    x: 'https://twitter.com/intent/tweet?url=' + url + '&text=' + title,
    whatsapp: 'https://wa.me/?text=' + title + '%20' + url,
    linkedin: 'https://www.linkedin.com/sharing/share-offsite/?url=' + url
  };
  document.querySelectorAll('[data-share]').forEach(function (a) {
    var t = targets[a.getAttribute('data-share')];
    if (t) a.href = t;
  });

  /* Formulaire de contact (aperçu statique ; branché sur WordPress en production) */
  document.querySelectorAll('form.cf[data-static]').forEach(function (f) {
    f.addEventListener('submit', function (e) {
      e.preventDefault();
      if (!f.reportValidity()) return;
      var ok = f.querySelector('.ok');
      if (ok) ok.hidden = false;
      f.reset();
    });
  });
})();

/* Direct CaviTV (HLS) */
(function () {
  var v = document.getElementById('cavi-tv');
  if (!v) return;
  var box = v.closest('.player'), btn = box.querySelector('.bigplay'), err = box.querySelector('.player-err');
  var src = v.getAttribute('data-hls'), ready = false, hls = null;
  function fail() { if (err) err.hidden = false; box.classList.remove('playing'); }
  function start() {
    if (!ready) {
      ready = true;
      if (v.canPlayType('application/vnd.apple.mpegurl')) { v.src = src; }
      else if (window.Hls && window.Hls.isSupported()) {
        hls = new window.Hls({ lowLatencyMode: true });
        hls.on(window.Hls.Events.ERROR, function (e, d) { if (d && d.fatal) fail(); });
        hls.loadSource(src); hls.attachMedia(v);
      } else { v.src = src; }
      v.addEventListener('error', fail);
    }
    box.classList.add('playing');
    var p = v.play(); if (p && p.catch) p.catch(function () {});
  }
  btn.addEventListener('click', start);
  v.addEventListener('play', function () { if (!ready) start(); box.classList.add('playing'); });
})();

/* Direct Cavi FM */
(function () {
  var box = document.querySelector('.radio-player');
  if (!box) return;
  var a = box.querySelector('audio'), btn = box.querySelector('.rp-btn'), st = box.querySelector('.rp-state'),
      err = box.querySelector('.player-err'), ip = box.querySelector('.i-play'), ipa = box.querySelector('.i-pause');
  function ui(on) {
    box.classList.toggle('playing', on); ip.hidden = on; ipa.hidden = !on;
    btn.setAttribute('aria-label', on ? 'Mettre en pause Cavi FM' : 'Écouter Cavi FM en direct');
    st.textContent = on ? 'Vous écoutez Cavi FM en direct' : 'Appuyez sur lecture pour écouter la radio';
  }
  btn.addEventListener('click', function () {
    if (a.paused) {
      st.textContent = 'Connexion au direct…';
      var p = a.play(); if (p && p.catch) p.catch(function () { ui(false); err.hidden = false; });
    } else { a.pause(); }
  });
  a.addEventListener('playing', function () { ui(true); err.hidden = true; });
  a.addEventListener('pause', function () { ui(false); });
  a.addEventListener('error', function () { ui(false); err.hidden = false; });
})();
