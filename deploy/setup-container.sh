#!/bin/sh
# Installe / met à jour le thème Cavi-Medias depuis GitHub, puis configure WordPress (1re installation seulement).
set -e
cd /var/www/html
REPO_TGZ="${REPO_TGZ:-https://codeload.github.com/alghassimoudelivery-source/cavi-medias-site/tar.gz/refs/heads/main}"
echo "Attente de WordPress..."
until [ -f wp-config.php ]; do sleep 2; done
until wp db check >/dev/null 2>&1; do sleep 3; done
mkdir -p /tmp/src
php -r '$d=@file_get_contents(getenv("REPO_TGZ")?:$argv[1]); if($d===false){fwrite(STDERR,"telechargement impossible\n"); exit(1);} file_put_contents("/tmp/src.tgz",$d);' "$REPO_TGZ"
tar xzf /tmp/src.tgz -C /tmp/src --strip-components=1
if [ -d wp-content/themes/cavi-medias ]; then
  mkdir -p wp-content/cavi-backups
  tar czf "wp-content/cavi-backups/theme-$(date +%Y%m%d-%H%M%S).tgz" -C wp-content/themes cavi-medias
fi
mkdir -p wp-content/themes/cavi-medias
cp -r /tmp/src/theme/cavi-medias/. wp-content/themes/cavi-medias/
if ! wp core is-installed; then
  wp core install --url="$SITE_URL" --title="Cavi-Medias" --admin_user="$ADMIN_USER" --admin_password="$ADMIN_PASS" --admin_email="$ADMIN_EMAIL" --skip-email
  WP=wp sh /tmp/src/deploy/setup-cavi.sh
fi
wp option update home "$SITE_URL"
wp option update siteurl "$SITE_URL"
wp option update blog_public "${INDEXABLE:-0}"
wp language core install fr_FR --activate || echo "Langue FR non installee"
wp rewrite flush --hard || true
echo "CAVI-SETUP-OK $(wp core version) theme=$(wp theme list --status=active --field=name)"
