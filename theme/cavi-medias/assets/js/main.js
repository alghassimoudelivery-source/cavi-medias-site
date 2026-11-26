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
      /* hls.js en priorité (Chrome, Edge, Firefox, Android) ; lecture native seulement sur Safari / iPhone */
      if (window.Hls && window.Hls.isSupported()) {
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

/* Grille des programmes : onglets par jour + émission en cours (heure de Conakry = GMT) */
(function () {
  document.querySelectorAll('[data-grille]').forEach(function (g) {
    var tabs = [].slice.call(g.querySelectorAll('[role="tab"]'));
    var panels = [].slice.call(g.querySelectorAll('[role="tabpanel"]'));
    function show(i, focus) {
      tabs.forEach(function (t, k) {
        var on = k === i;
        t.setAttribute('aria-selected', on ? 'true' : 'false');
        t.tabIndex = on ? 0 : -1;
        panels[k].hidden = !on;
      });
      if (focus) tabs[i].focus();
    }
    tabs.forEach(function (t, i) {
      t.addEventListener('click', function () { show(i); });
      t.addEventListener('keydown', function (e) {
        var n = e.key === 'ArrowRight' ? 1 : e.key === 'ArrowLeft' ? -1 : 0;
        if (n) { e.preventDefault(); show((i + n + tabs.length) % tabs.length, true); }
      });
    });
    function tick(first) {
      var d = new Date();
      var min = d.getUTCHours() * 60 + d.getUTCMinutes();
      var axis = (min - 360 + 1440) % 1440;          /* minutes depuis 6h00 */
      var day = (d.getUTCDay() + 6) % 7;              /* 0 = lundi */
      if (min < 360) day = (day + 6) % 7;             /* avant 6h : journée d'antenne de la veille */
      tabs.forEach(function (t, k) { t.classList.toggle('today', k === day); });
      panels.forEach(function (p, k) {
        [].forEach.call(p.querySelectorAll('li'), function (li) {
          var s = +li.getAttribute('data-s'), e = +li.getAttribute('data-e');
          li.classList.toggle('on', k === day && axis >= s && axis < e);
          li.classList.toggle('past', k === day && axis >= e);
        });
      });
      if (first) {
        show(day);
        var cur = panels[day].querySelector('li.on') || panels[day].querySelector('li:not(.past)');
        var ol = panels[day].querySelector('ol');
        if (cur && ol) ol.scrollTop = Math.max(0, cur.offsetTop - 8);
      }
    }
    tick(true);
    setInterval(tick, 60000);
  });
})();
