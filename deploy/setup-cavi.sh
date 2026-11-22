#!/bin/sh
# Configuration WordPress du site Cavi-Medias (ConforDev). Usage : WP="wp --allow-root" sh setup-cavi.sh
set -e
WP=${WP:-wp}
$WP theme activate cavi-medias
$WP option update blogname "Cavi-Medias"
$WP option update blogdescription "Groupe de presse : CaviTV, Cavi FM et Siam Info"
$WP option update timezone_string "Africa/Conakry" || true
$WP option update date_format "j F Y"
$WP rewrite structure '/%postname%/' --hard
# Nettoyage du contenu d'exemple
for id in $($WP post list --post_type=post,page --format=ids); do $WP post delete $id --force >/dev/null; done
$WP comment delete $($WP comment list --format=ids) --force >/dev/null 2>&1 || true
mk() { $WP post create --post_type=page --post_status=publish --post_title="$1" --post_name="$2" --porcelain; }
HOME_ID=$(mk "Accueil" "accueil")
mk "Le groupe" "le-groupe" >/dev/null
mk "CaviTV" "cavitv" >/dev/null
mk "Cavi FM" "cavi-fm" >/dev/null
mk "Siam Info" "siam-info" >/dev/null
mk "Publicité" "publicite" >/dev/null
mk "Contact" "contact" >/dev/null
mk "Mentions légales" "mentions-legales" >/dev/null
$WP option update show_on_front page
$WP option update page_on_front "$HOME_ID"
$WP option update default_comment_status closed
$WP option update default_ping_status closed
$WP option update blog_public 1
$WP rewrite flush --hard
echo "Cavi-Medias configuré."
