# Régénérer les visuels des stores

Les visuels sont produits à partir de pages HTML rendues avec Playwright.
Placer dans ce dossier les polices (Inter, Bebas Neue), le logo blanc SVG et les captures
de l'application (`accueil-0.png`, `cavitv-0.png`, `cavifm-0.png`, `plus-0.png`), puis :

```bash
python3 gen.py
node render.js . sortie
```
