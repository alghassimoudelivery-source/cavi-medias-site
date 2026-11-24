<?php
/**
 * Cavi-Medias — fonctions du thème. Site réalisé par ConforDev (https://confordev.com).
 */
if ( ! defined( 'ABSPATH' ) ) { exit; }

const CAVI_VERSION = '1.3.2';
const CAVI_PHONE = '+224 624 39 74 76';
const CAVI_EMAIL = 'contact@cavimedias.com';
const CAVI_ADDRESS = 'Yimbaya carrefour Camp, Commune de Gbessia, Conakry, République de Guinée';
const CAVI_TV    = 'https://broadlio.com/hls/tv/cavi-tv.m3u8';
const CAVI_RADIO = 'https://broadlio.com/radio/cavi-fm.mp3';
const CAVI_APP_ANDROID = 'https://play.google.com/store/apps/details?id=com.cavimedias.app';

add_action( 'after_setup_theme', function () {
	add_theme_support( 'title-tag' );
	add_theme_support( 'html5', array( 'search-form', 'gallery', 'caption', 'style', 'script' ) );
	add_theme_support( 'post-thumbnails' );
} );

/* Page de connexion aux couleurs Cavi-Medias */
add_action( 'login_enqueue_scripts', function () {
	wp_enqueue_style( 'cavi-fonts', 'https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Inter:wght@400;500;600;700&display=swap', array(), null );
	wp_enqueue_style( 'cavi-login', get_theme_file_uri( 'assets/css/login.css' ), array( 'login' ), CAVI_VERSION );
} );
add_filter( 'login_headerurl', function () { return home_url( '/' ); } );
add_filter( 'login_headertext', function () { return 'Cavi-Medias'; } );
add_filter( 'login_display_language_dropdown', '__return_false' );
add_action( 'login_footer', function () {
	echo '<p class="cavi-credit">Site réalisé par <a href="https://confordev.com" target="_blank" rel="noopener">ConforDev</a></p>';
} );

add_action( 'wp_enqueue_scripts', function () {
	wp_enqueue_style( 'cavi-fonts', 'https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Inter:wght@400;500;600;700&display=swap', array(), null );
	wp_enqueue_style( 'cavi-style', get_theme_file_uri( 'assets/css/style.css' ), array( 'cavi-fonts' ), CAVI_VERSION );
	$deps = array();
	if ( is_page( 'cavitv' ) ) {
		wp_enqueue_script( 'hls', 'https://cdn.jsdelivr.net/npm/hls.js@1.5.17/dist/hls.min.js', array(), '1.5.17', array( 'strategy' => 'defer', 'in_footer' => true ) );
		$deps[] = 'hls';
	}
	wp_enqueue_script( 'cavi-main', get_theme_file_uri( 'assets/js/main.js' ), $deps, CAVI_VERSION, array( 'strategy' => 'defer', 'in_footer' => true ) );
} );

/* ---------- Réglages (Apparence > Personnaliser > Cavi-Medias) ---------- */
function cavi_opt( $key, $default = '' ) {
	$v = get_theme_mod( 'cavi_' . $key, '' );
	return ( '' === $v || null === $v ) ? $default : $v;
}
function cavi_url( $key ) {
	$defaults = array( 'app_android' => CAVI_APP_ANDROID );
	echo esc_url( cavi_opt( $key, isset( $defaults[ $key ] ) ? $defaults[ $key ] : '#' ) );
}
function cavi_current( $slug ) {
	$on = ( '' === $slug ) ? is_front_page() : is_page( $slug );
	if ( $on ) { echo ' aria-current="page"'; }
}
function cavi_ad( $slot ) {
	$code = cavi_opt( 'ad_' . str_replace( '-', '_', $slot ), '' );
	if ( $code ) { echo $code; } // Code publicitaire saisi par l'administrateur.
}

add_action( 'customize_register', function ( $wp ) {
	$wp->add_panel( 'cavi', array( 'title' => 'Cavi-Medias', 'priority' => 20 ) );
	$sections = array(
		'cavi_reseaux' => array( 'Réseaux sociaux', array(
			'soc_facebook' => 'Lien Facebook', 'soc_messenger' => 'Lien Messenger (m.me/…)', 'soc_x' => 'Lien X (Twitter)', 'soc_tiktok' => 'Lien TikTok',
			'soc_instagram' => 'Lien Instagram', 'soc_youtube' => 'Lien YouTube' ), 'url' ),
		'cavi_liens' => array( 'Application, vidéo et radio', array(
			'app_ios' => 'Lien App Store', 'app_android' => 'Lien Google Play',
			'video' => 'Lien du film de présentation (YouTube)', 'tv_stream' => 'Flux du direct CaviTV (.m3u8)', 'radio' => 'Flux du direct Cavi FM',
			'kit' => 'Lien du kit média (PDF)' ), 'url' ),
		'cavi_contact' => array( 'Coordonnées', array(
			'c_phone' => 'Téléphone', 'c_email' => 'E-mail affiché', 'c_address' => 'Adresse',
			'c_dest' => 'E-mail qui reçoit les messages du formulaire' ), 'text' ),
		'cavi_codes' => array( 'Codes de suivi et publicité', array(
			'code_head' => 'Code dans l\'en-tête (Google Analytics, Search Console, AdSense auto)',
			'code_body' => 'Code juste après l\'ouverture de <body> (Tag Manager)',
			'ads_txt' => 'Contenu du fichier ads.txt',
			'ad_accueil_haut' => 'Publicité : accueil, après « Nos médias »', 'ad_accueil_bas' => 'Publicité : accueil, bas de page',
			'ad_groupe' => 'Publicité : page Le groupe', 'ad_cavitv' => 'Publicité : page CaviTV', 'ad_cavi_fm' => 'Publicité : page Cavi FM',
			'ad_siam_info' => 'Publicité : page Siam Info', 'ad_publicite' => 'Publicité : page Publicité' ), 'code' ),
	);
	foreach ( $sections as $id => $s ) {
		$wp->add_section( $id, array( 'title' => $s[0], 'panel' => 'cavi' ) );
		foreach ( $s[1] as $key => $label ) {
			$san = 'url' === $s[2] ? 'esc_url_raw' : ( 'code' === $s[2] ? 'cavi_keep_code' : 'sanitize_text_field' );
			$wp->add_setting( 'cavi_' . $key, array( 'default' => '', 'sanitize_callback' => $san ) );
			$wp->add_control( 'cavi_' . $key, array( 'label' => $label, 'section' => $id, 'type' => 'code' === $s[2] ? 'textarea' : ( 'url' === $s[2] ? 'url' : 'text' ) ) );
		}
	}
} );
function cavi_keep_code( $v ) { return current_user_can( 'unfiltered_html' ) ? $v : wp_kses_post( $v ); }

add_action( 'wp_head', function () { echo cavi_opt( 'code_head', '' ); }, 99 );
add_action( 'wp_body_open', function () { echo cavi_opt( 'code_body', '' ); } );

/* ---------- ads.txt servi depuis le réglage ---------- */
add_action( 'init', function () {
	$path = wp_parse_url( $_SERVER['REQUEST_URI'] ?? '', PHP_URL_PATH );
	if ( '/ads.txt' === $path ) {
		header( 'Content-Type: text/plain; charset=utf-8' );
		$txt = cavi_opt( 'ads_txt', '' );
		echo $txt ? $txt : "# ads.txt de Cavi-Medias : ajoutez la ligne fournie par Google AdSense dans Apparence > Personnaliser > Cavi-Medias.\n";
		exit;
	}
}, 0 );

/* ---------- SEO : titres, descriptions, Open Graph, données structurées ---------- */
function cavi_meta() {
	static $m = null;
	if ( null === $m ) { $m = json_decode( '{"": ["Cavi-Medias, groupe de presse : CaviTV, Cavi FM et Siam Info", "Cavi-Medias réunit la chaîne de télévision CaviTV, la radio Cavi FM et le site d\'information Siam Info. Découvrez le groupe, ses médias et ses offres pour les annonceurs."], "le-groupe": ["Le groupe Cavi-Medias : mission et valeurs", "Découvrez Cavi-Medias, groupe de presse réunissant une télévision, une radio FM et un site d\'information, sa mission et ses engagements."], "cavitv": ["CaviTV, la chaîne de télévision du groupe Cavi-Medias", "CaviTV, la chaîne de télévision du groupe Cavi-Medias : information, débats, culture et divertissement. Suivez-nous sur YouTube et les réseaux sociaux."], "cavi-fm": ["Cavi FM, la radio du groupe Cavi-Medias", "Cavi FM, la radio FM du groupe Cavi-Medias : musique, information et émissions interactives. Écoutez-nous et suivez-nous sur les réseaux sociaux."], "siam-info": ["Siam Info, le site d\'information du groupe Cavi-Medias", "Siam Info est le site d\'information en ligne du groupe Cavi-Medias. Retrouvez l\'actualité sur siaminfos.com."], "publicite": ["Publicité : annoncer sur CaviTV, Cavi FM et Siam Info", "Faites connaître votre marque sur la télévision, la radio et le site d\'information du groupe Cavi-Medias. Formats, kit média et demande de devis."], "contact": ["Contacter le groupe Cavi-Medias", "Contactez le groupe Cavi-Medias : renseignements, partenariats, publicité et demandes de devis."], "mentions-legales": ["Mentions légales et confidentialité | Cavi-Medias", "Mentions légales, politique de confidentialité et gestion des cookies du site Cavi-Medias."]}', true ); }
	if ( is_front_page() ) { return $m['']; }
	if ( is_page() ) {
		$slug = get_post_field( 'post_name', get_queried_object_id() );
		if ( isset( $m[ $slug ] ) ) { return $m[ $slug ]; }
		$desc = has_excerpt() ? get_the_excerpt() : wp_trim_words( wp_strip_all_tags( get_post_field( 'post_content', get_queried_object_id() ) ), 28 );
		return array( get_the_title() . ' | Cavi-Medias', $desc );
	}
	return array( wp_get_document_title(), get_bloginfo( 'description' ) );
}
function cavi_seo_plugin_active() { return defined( 'WPSEO_VERSION' ) || defined( 'RANK_MATH_VERSION' ) || class_exists( 'All_in_One_SEO_Pack' ); }

add_filter( 'pre_get_document_title', function ( $t ) {
	if ( cavi_seo_plugin_active() ) { return $t; }
	return ( is_front_page() || is_page() ) ? cavi_meta()[0] : $t;
} );

add_action( 'wp_head', function () {
	echo '<meta name="theme-color" content="#0b0b0f">' . "\n";
	if ( ! has_site_icon() ) {
		echo '<link rel="icon" href="' . esc_url( get_theme_file_uri( 'assets/img/favicon.ico' ) ) . '" sizes="48x48">' . "\n";
		echo '<link rel="apple-touch-icon" href="' . esc_url( get_theme_file_uri( 'assets/img/apple-touch-icon.png' ) ) . '">' . "\n";
	}
	if ( cavi_seo_plugin_active() ) { return; }
	list( $title, $desc ) = cavi_meta();
	$url = is_front_page() ? home_url( '/' ) : get_permalink();
	$img = get_theme_file_uri( 'assets/img/og-cavi-medias.jpg' );
	printf( '<meta name="description" content="%s">' . "\n", esc_attr( $desc ) );
	printf( '<link rel="canonical" href="%s">' . "\n", esc_url( $url ) );
	if ( is_page( 'mentions-legales' ) ) { echo '<meta name="robots" content="noindex, follow">' . "\n"; }
	$og = array( 'og:type' => 'website', 'og:locale' => 'fr_FR', 'og:site_name' => 'Cavi-Medias', 'og:title' => $title, 'og:description' => $desc, 'og:url' => $url, 'og:image' => $img, 'og:image:width' => '1200', 'og:image:height' => '630' );
	foreach ( $og as $k => $v ) { printf( '<meta property="%s" content="%s">' . "\n", esc_attr( $k ), esc_attr( $v ) ); }
	$tw = array( 'twitter:card' => 'summary_large_image', 'twitter:title' => $title, 'twitter:description' => $desc, 'twitter:image' => $img );
	foreach ( $tw as $k => $v ) { printf( '<meta name="%s" content="%s">' . "\n", esc_attr( $k ), esc_attr( $v ) ); }
	$home = home_url( '/' );
	$same = array_values( array_filter( array_map( function ( $k ) { return cavi_opt( 'soc_' . $k, '' ); }, array( 'facebook', 'x', 'tiktok', 'instagram', 'youtube' ) ) ) );
	$ld = array( '@context' => 'https://schema.org', '@graph' => array(
		array( '@type' => 'NewsMediaOrganization', '@id' => $home . '#organisation', 'name' => 'Cavi-Medias', 'url' => $home,
			'logo' => get_theme_file_uri( 'assets/img/cavi-medias-icone.png' ), 'sameAs' => $same, 'telephone' => cavi_opt( 'c_phone', CAVI_PHONE ), 'email' => cavi_opt( 'c_email', CAVI_EMAIL ), 'address' => array( '@type' => 'PostalAddress', 'streetAddress' => cavi_opt( 'c_address', CAVI_ADDRESS ), 'addressLocality' => 'Conakry', 'addressCountry' => 'GN' ),
			'subOrganization' => array(
				array( '@type' => 'TelevisionChannel', 'name' => 'CaviTV', 'url' => home_url( '/cavitv/' ) ),
				array( '@type' => 'RadioStation', 'name' => 'Cavi FM', 'url' => home_url( '/cavi-fm/' ) ),
				array( '@type' => 'NewsMediaOrganization', 'name' => 'Siam Info', 'url' => 'https://www.siaminfos.com/' ) ) ),
		array( '@type' => 'WebSite', '@id' => $home . '#site', 'url' => $home, 'name' => 'Cavi-Medias', 'inLanguage' => 'fr', 'publisher' => array( '@id' => $home . '#organisation' ) ) ) );
	echo '<script type="application/ld+json">' . wp_json_encode( $ld, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES ) . '</script>' . "\n";
}, 1 );

/* Le plan du site natif (wp-sitemap.xml) ne liste que les pages. */
add_filter( 'wp_sitemaps_add_provider', function ( $provider, $name ) { return 'users' === $name ? false : $provider; }, 10, 2 );
add_filter( 'wp_sitemaps_post_types', function ( $types ) { unset( $types['post'] ); return $types; } );
add_filter( 'wp_sitemaps_taxonomies', '__return_empty_array' );
add_filter( 'wp_sitemaps_posts_query_args', function ( $args, $type ) {
	if ( 'page' === $type ) { $p = get_page_by_path( 'mentions-legales' ); if ( $p ) { $args['post__not_in'] = array( $p->ID ); } }
	return $args;
}, 10, 2 );

/* ---------- Formulaire de contact ---------- */
function cavi_contact_handler() {
	$back = home_url( '/contact/' );
	if ( ! isset( $_POST['cavi_nonce'] ) || ! wp_verify_nonce( sanitize_text_field( wp_unslash( $_POST['cavi_nonce'] ) ), 'cavi_contact' ) || ! empty( $_POST['site_web'] ) ) {
		wp_safe_redirect( add_query_arg( 'envoye', '0', $back ) . '#contenu' ); exit;
	}
	$nom   = sanitize_text_field( wp_unslash( $_POST['nom'] ?? '' ) );
	$email = sanitize_email( wp_unslash( $_POST['email'] ?? '' ) );
	$tel   = sanitize_text_field( wp_unslash( $_POST['tel'] ?? '' ) );
	$obj   = sanitize_text_field( wp_unslash( $_POST['objet'] ?? '' ) );
	$msg   = sanitize_textarea_field( wp_unslash( $_POST['message'] ?? '' ) );
	$ok = false;
	if ( $nom && is_email( $email ) && $msg ) {
		$to = cavi_opt( 'c_dest', cavi_opt( 'c_email', CAVI_EMAIL ) );
		$ok = wp_mail( $to, '[Cavi-Medias] ' . $obj . ' : ' . $nom, "Nom : $nom\nE-mail : $email\nTéléphone : $tel\nObjet : $obj\n\n$msg", array( 'Reply-To: ' . $nom . ' <' . $email . '>' ) );
	}
	wp_safe_redirect( add_query_arg( 'envoye', $ok ? '1' : '0', $back ) . '#contenu' ); exit;
}
add_action( 'admin_post_nopriv_cavi_contact', 'cavi_contact_handler' );
add_action( 'admin_post_cavi_contact', 'cavi_contact_handler' );

/* Nettoyage de l'en-tête */
remove_action( 'wp_head', 'wp_generator' );
remove_action( 'wp_head', 'print_emoji_detection_script', 7 );
remove_action( 'wp_print_styles', 'print_emoji_styles' );
