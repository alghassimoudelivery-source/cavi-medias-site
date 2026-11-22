# Cavi-Medias — site du groupe

Site vitrine du groupe de presse Cavi-Medias (CaviTV, Cavi FM, Siam Info). Thème WordPress classique `cavi-medias`.

Site réalisé par [ConforDev](https://confordev.com).

## Contenu
- `theme/cavi-medias/` : le thème WordPress.
- `deploy/setup-cavi.sh` : création des pages et réglages (1re installation).
- `deploy/setup-container.sh` : script lancé par le service `setup` (copie du thème avec sauvegarde de l'ancien, configuration).
- `docker-compose.yml` : MariaDB + WordPress (port 8095) + WP-CLI.

## Réglages
Apparence › Personnaliser › Cavi-Medias : réseaux sociaux, liens des applis, flux du direct, coordonnées, codes de suivi et publicité (en-tête, body, ads.txt, emplacements publicitaires).

Aucun mot de passe n'est stocké dans ce dépôt : les variables sont fournies au déploiement.
