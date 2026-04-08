import QtQuick 2.0
import QtQuick.Shapes 1.0
import Nemo.Mce 1.0

Rectangle { // Le conteneur principal QML

    id: background
    width: 390; height: 390
    color: theme.main

    /////////////////////////////////
    //           TIMER             //
    /////////////////////////////////
    Timer {
        interval: 16
        running: true
        repeat: true
        onTriggered: {
            background.time = new Date()
        }
    }
    /////////////////////////////////
    //         VARIABLES           //
    /////////////////////////////////
    property int angle: 0;
    property date time: new Date()
    antialiasing: true

    /////////////////////////////////
    //         CAPTEURS            //
    /////////////////////////////////
    MceBatteryLevel {
        id: infoBatterie
    }

    /////////////////////////////////
    //           THÈME             //
    /////////////////////////////////
    QtObject {
        id: theme
        // Noir absolu pour économiser l'OLED
        property color bg: "#000000"

        // Blanc pur pour la lisibilité maximale
        property color main: "#FFFFFF"

        // Orange vif pour les touches d'accent (Ressence Type 1)
        property color accent: '#ff9900'

        // Gris de soutien pour les éléments secondaires
        property color muted: "#333333"

        // Tailles de police centralisées
        property int fontSizeSmall: 12
        property int fontSizeMedium: 18
        property int fontSizeLarge: 24
    }

    /////////////////////////////////
    //          CADRAN             //
    /////////////////////////////////
    Rectangle { // Le cadran qui tourne pour les minutes
        id: cadran
        width: background.width; height: background.height
        radius: height/2
        color: theme.bg
        rotation: (time.getMinutes() * 6) + (time.getSeconds() * 0.1) + (time.getMilliseconds() * 0.0001)

        Item { // Aiguille des minutes
            id: aiguilleHeures
            width: 16
            height: parent.height / 2 - 45
            antialiasing: true

            anchors.bottom: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            Shape {
                anchors.fill: parent
                antialiasing: true

                ShapePath {
                    id: aiguilleHeuresPath
                    fillColor: theme.main
                    strokeColor: "transparent"

                    property real tipW: 4

                    // 0. Point de départ : Haut-GAUCHE de la pointe
                    startX: (aiguilleHeures.width / 2) - (tipW / 2)
                    startY: tipW / 2

                    // 1. Le dôme de la pointe (de Gauche à Droite -> bombe vers le HAUT)
                    PathArc {
                        x: (aiguilleHeures.width / 2) + (aiguilleHeuresPath.tipW / 2)
                        y: aiguilleHeuresPath.tipW / 2
                        radiusX: aiguilleHeuresPath.tipW / 2
                        radiusY: aiguilleHeuresPath.tipW / 2
                        // On laisse la direction par défaut (Clockwise)
                    }

                    // 2. Le flanc DROIT (descend en s'évasant vers la base droite)
                    PathLine {
                        x: aiguilleHeures.width
                        y: aiguilleHeures.height - (aiguilleHeures.width / 2)
                    }

                    // 3. L'arrondi de la base (de Droite à Gauche -> bombe vers le BAS)
                    PathArc {
                        x: 0
                        y: aiguilleHeures.height - (aiguilleHeures.width / 2)
                        radiusX: aiguilleHeures.width / 2
                        radiusY: aiguilleHeures.width / 2
                        // On laisse la direction par défaut (Clockwise)
                    }

                    // 4. Le flanc GAUCHE (remonte vers le point de départ pour fermer)
                    PathLine {
                        x: aiguilleHeuresPath.startX
                        y: aiguilleHeuresPath.startY
                    }
                }
            }
        }

        /////////////////////////////////
        //          HEURES             //
        /////////////////////////////////
        Rectangle { // Disque des heures
            id: heures
            width: 150; height: width
            color: theme.bg
            radius: height/2

            scale: 1 // 1.0 = taille normale, 0.8 = 20% plus petit, 1.5 = 50% plus gros

            // anchors.horizontalCenter: parent.horizontalCenter
            // anchors.bottom: parent.bottom
            // anchors.bottomMargin: parent.width * 0.1

            // --- CONTRÔLE DU PLACEMENT ---
            property real distanceCentre: 80 // Éloignement du centre (0 = collé au centre)
            property real anglePlacement: 180  // Angle (0 = 12h, 90 = 3h, 180 = 6h, 270 = 9h)

            // Ne touche pas à cette formule, elle place l'élément automatiquement
            x: (parent.width / 2) - (width / 2) + distanceCentre * Math.sin(anglePlacement * Math.PI / 180)
            y: (parent.height / 2) - (height / 2) - distanceCentre * Math.cos(anglePlacement * Math.PI / 180)

            rotation: -parent.rotation

            Text {
                text: "♥" // Ou un symbole de ton choix
                color: theme.accent
                font.pixelSize: heures.width * 0.15
                anchors.horizontalCenter: parent.horizontalCenter
                y: (heures.height / 2) - (heures.width * 0.4) - (height / 2)
            }

            // CHIFFRES DU CADRAN DES HEURES, FIXE
            Repeater {
                model: 12
                delegate: Text {
                    text: {
                        let val = index + 1
                        if (val === 12) return "";

                        return (val % 2 === 0) ? val : ".";

                    }
                    color: theme.main
                    font.pixelSize: heures.width * 0.12
                    font.bold: true

                    // Calcul trigonométrique (ajusté pour que 12 soit en haut)
                    property real rad: heures.width * 0.4
                    property real angle: (index - 2) * (Math.PI * 2 / 12)

                    x: (heures.width / 2) + rad * Math.cos(angle) - (width / 2)
                    y: (heures.height / 2) + rad * Math.sin(angle) - (height / 2)
                }
            }

            // PARTIE ROTATIVE DU CADRAN DES HEURES
            Rectangle {
                id: rondAiguille
                width: parent.width * 0.65; height: width
                radius: height/2
                color: theme.bg
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                rotation: (time.getHours() % 12) * 30 + (time.getMinutes() * 0.5) - 15

                // ==========================================
                // AIGUILLE VECTORIELLE "GOUTTE D'EAU"
                // ==========================================
                Item {
                    id: aiguilleHeure
                    width: 9
                    height: parent.height / 2 - 5

                    anchors.bottom: parent.verticalCenter
                    anchors.bottomMargin: -(width / 2)
                    anchors.horizontalCenter: parent.horizontalCenter

                    Shape {
                        anchors.fill: parent
                        antialiasing: true

                        ShapePath {
                            id: aiguilleHeurePath
                            fillColor: theme.main
                            strokeColor: "transparent"

                            property real tipW: 4

                            // 0. Point de départ : Haut-GAUCHE de la pointe
                            startX: (aiguilleHeure.width / 2) - (tipW / 2)
                            startY: tipW / 2

                            // 1. Le dôme de la pointe (de Gauche à Droite -> bombe vers le HAUT)
                            PathArc {
                                x: (aiguilleHeure.width / 2) + (aiguilleHeurePath.tipW / 2)
                                y: aiguilleHeurePath.tipW / 2
                                radiusX: aiguilleHeurePath.tipW / 2
                                radiusY: aiguilleHeurePath.tipW / 2
                                // On laisse la direction par défaut (Clockwise)
                            }

                            // 2. Le flanc DROIT (descend en s'évasant vers la base droite)
                            PathLine {
                                x: aiguilleHeure.width
                                y: aiguilleHeure.height - (aiguilleHeure.width / 2)
                            }

                            // 3. L'arrondi de la base (de Droite à Gauche -> bombe vers le BAS)
                            PathArc {
                                x: 0
                                y: aiguilleHeure.height - (aiguilleHeure.width / 2)
                                radiusX: aiguilleHeure.width / 2
                                radiusY: aiguilleHeure.width / 2
                                // On laisse la direction par défaut (Clockwise)
                            }

                            // 4. Le flanc GAUCHE (remonte vers le point de départ pour fermer)
                            PathLine {
                                x: aiguilleHeurePath.startX
                                y: aiguilleHeurePath.startY
                            }
                        }
                    }
                }
            }

        }
        /////////////////////////////////
        //         SECONDES            //
        /////////////////////////////////
        Rectangle { // Disque des secondes
            id: secondes
            width: 50; height: width
            color: theme.bg
            radius: height/2

            scale: 0.8 // 1.0 = taille normale, 0.8 = 20% plus petit, 1.5 = 50% plus gros

            // --- CONTRÔLE DU PLACEMENT ---
            property real distanceCentre: 120 // Éloignement du centre (0 = collé au centre)
            property real anglePlacement:  115 // Angle (0 = 12h, 90 = 3h, 180 = 6h, 270 = 9h)

            // Ne touche pas à cette formule, elle place l'élément automatiquement
            x: (parent.width / 2) - (width / 2) + distanceCentre * Math.sin(anglePlacement * Math.PI / 180)
            y: (parent.height / 2) - (height / 2) - distanceCentre * Math.cos(anglePlacement * Math.PI / 180)
            rotation: -parent.rotation

            Item {
                id: conteneurArc
                width: parent.width - 10; height: parent.height - 10
                anchors.centerIn: parent
                // La rotation fluide des secondes est conservée ici
                rotation: (time.getSeconds() * 6) + (time.getMilliseconds() * 0.006)

                // --- LES 2 ARCS VECTORIELS ---
                Repeater {
                    model: 2 // 2 arcs opposés

                    delegate: Shape {
                        anchors.fill: parent
                        antialiasing: true

                        ShapePath {
                            id: secArcPath
                            strokeWidth: 5 // Ton ancienne épaisseur
                            strokeColor: theme.accent
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap // Bouts ronds

                            // --- CALCULS GÉOMÉTRIQUES ---
                            // Rayon adapté à la taille du conteneur (40x40)
                            readonly property real rayonOrbite: 16

                            // Un segment prend la moitié du cercle (PI radians = 180°)
                            readonly property real angleTotalSegment: Math.PI

                            // On définit la taille de l'arc visuel (ex: 60% du demi-cercle)
                            // Plus ce chiffre est proche de 1, plus le trou sera petit
                            readonly property real angleSweepArc: angleTotalSegment * 0.75

                            // Décalage pour centrer l'arc dans son segment
                            readonly property real angleDepartBase: (index * angleTotalSegment) - (Math.PI / 2)
                            readonly property real angleDepartAjuste: angleDepartBase + ((angleTotalSegment - angleSweepArc) / 2)

                            // Point de départ
                            startX: (conteneurArc.width / 2) + rayonOrbite * Math.cos(angleDepartAjuste)
                            startY: (conteneurArc.height / 2) + rayonOrbite * Math.sin(angleDepartAjuste)

                            // Tracé de la courbe
                            PathArc {
                                radiusX: secArcPath.rayonOrbite
                                radiusY: secArcPath.rayonOrbite

                                x: (conteneurArc.width / 2) + secArcPath.rayonOrbite * Math.cos(secArcPath.angleDepartAjuste + secArcPath.angleSweepArc)
                                y: (conteneurArc.height / 2) + secArcPath.rayonOrbite * Math.sin(secArcPath.angleDepartAjuste + secArcPath.angleSweepArc)

                                useLargeArc: false
                            }
                        }
                    }
                }
            }
        }
        /////////////////////////////////
        //            JOURS            //
        /////////////////////////////////
        Rectangle { // Disque des jours
            id: jourSemaine
            width: 50; height: width
            color: theme.bg
            radius: height/2

            scale: 1 // 1.0 = taille normale, 0.8 = 20% plus petit, 1.5 = 50% plus gros

            // --- CONTRÔLE DU PLACEMENT ---
            property real distanceCentre: 90 // Éloignement du centre (0 = collé au centre)
            property real anglePlacement: 290  // Angle (0 = 12h, 90 = 3h, 180 = 6h, 270 = 9h)

            // Ne touche pas à cette formule, elle place l'élément automatiquement
            x: (parent.width / 2) - (width / 2) + distanceCentre * Math.sin(anglePlacement * Math.PI / 180)
            y: (parent.height / 2) - (height / 2) - distanceCentre * Math.cos(anglePlacement * Math.PI / 180)

            rotation: -parent.rotation
            Repeater {
                model: 7 // Les 7 jours de la semaine

                delegate: Shape {
                    anchors.fill: parent // Chaque Shape occupe tout le disque
                    antialiasing: true

                    ShapePath {
                        id: jourArcPath

                        // DESIGN DU TRAIT
                        strokeWidth: 4 // Épaisseur du trait
                        // L'arc du jour en cours est orange, les autres sont blancs
                        strokeColor: (index === 5 || index === 6) ? theme.accent : theme.main
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap // Bouts arrondis

                        // CALCULS GÉOMÉTRIQUES
                        readonly property real rayonOrbite: 35
                        readonly property real angleTotalSegment: (Math.PI * 2) / 7
                        readonly property real angleSweepArc: angleTotalSegment * 0.75

                        readonly property real angleDepartBase: (index * angleTotalSegment) - (Math.PI / 2)
                        readonly property real angleDepartAjuste: angleDepartBase + ((angleTotalSegment - angleSweepArc) / 2)

                        // Point de départ de l'arc
                        startX: (jourSemaine.width / 2) + rayonOrbite * Math.cos(angleDepartAjuste)
                        startY: (jourSemaine.height / 2) + rayonOrbite * Math.sin(angleDepartAjuste)

                        // L'arc de cercle
                        PathArc {
                            radiusX: jourArcPath.rayonOrbite
                            radiusY: jourArcPath.rayonOrbite

                            x: (jourSemaine.width / 2) + jourArcPath.rayonOrbite * Math.cos(jourArcPath.angleDepartAjuste + jourArcPath.angleSweepArc)
                            y: (jourSemaine.height / 2) + jourArcPath.rayonOrbite * Math.sin(jourArcPath.angleDepartAjuste + jourArcPath.angleSweepArc)

                            useLargeArc: false
                        }
                    }
                }
            }

            Rectangle{ // Aiguille des jours
                id: zoneAiguille
                color: theme.bg
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 2; height: width;
                radius: width/2

                // --- ROTATION CONTINUE (Lundi = 0 en haut) ---
                rotation: {
                    let degParJour = 360 / 7;

                    // L'astuce magique pour recadrer la semaine sur le Lundi
                    let jour = (time.getDay() + 6) % 7;

                    let heure = time.getHours();
                    let minute = time.getMinutes();

                    // L'aiguille avance doucement tout au long de la journée
                    return (jour * degParJour) + ((heure / 24) * degParJour) + ((minute / 1440) * degParJour);
                }

                // ==========================================
                // AIGUILLE VECTORIELLE DES JOURS
                // ==========================================
                Item {
                    id: aiguilleJours

                    // 1. LES BONNES PROPORTIONS (Base > Pointe)
                    width: 8
                    height: 32

                    // 2. LE PLACEMENT DU PIVOT EXACT AU CENTRE
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.verticalCenter
                    // On abaisse de la moitié de la base pour centrer le cercle
                    anchors.bottomMargin: -(width / 2)

                    // (Plus de propriété 'rotation' ici !)

                    Shape {
                        anchors.fill: parent
                        antialiasing: true

                        ShapePath {
                            id: aiguilleJoursPath
                            fillColor: theme.main // Orange pour les heures
                            strokeColor: "transparent"

                            property real tipW: 3 // La pointe est bien plus fine que la base (12)

                            // 0. Point de départ : Haut-GAUCHE de la pointe
                            startX: (aiguilleJours.width / 2) - (tipW / 2)
                            startY: tipW / 2

                            // 1. Le dôme de la pointe
                            PathArc {
                                x: (aiguilleJours.width / 2) + (aiguilleJoursPath.tipW / 2)
                                y: aiguilleJoursPath.tipW / 2
                                radiusX: aiguilleJoursPath.tipW / 2
                                radiusY: aiguilleJoursPath.tipW / 2
                            }

                            // 2. Le flanc DROIT
                            PathLine {
                                x: aiguilleJours.width
                                y: aiguilleJours.height - (aiguilleJours.width / 2)
                            }

                            // 3. L'arrondi de la base
                            PathArc {
                                x: 0
                                y: aiguilleJours.height - (aiguilleJours.width / 2)
                                radiusX: aiguilleJours.width / 2
                                radiusY: aiguilleJours.width / 2
                            }

                            // 4. Le flanc GAUCHE
                            PathLine {
                                x: aiguilleJoursPath.startX
                                y: aiguilleJoursPath.startY
                            }
                        }
                    }
                }
            }
        }
        /////////////////////////////////
        //          BATTERIE           //
        /////////////////////////////////
        Rectangle { // Cadran batterile
            id: batterieSatellite
            width: 50; height: 50
            color: theme.bg
            radius: height / 2

            scale: 1.6 // 1.0 = taille normale, 0.8 = 20% plus petit, 1.5 = 50% plus gros

            // --- CONTRÔLE DU PLACEMENT ---
            property real distanceCentre: 95 // Éloignement du centre (0 = collé au centre)
            property real anglePlacement: 70  // Angle (0 = 12h, 90 = 3h, 180 = 6h, 270 = 9h)

            // Ne touche pas à cette formule, elle place l'élément automatiquement
            x: (parent.width / 2) - (width / 2) + distanceCentre * Math.sin(anglePlacement * Math.PI / 180)
            y: (parent.height / 2) - (height / 2) - distanceCentre * Math.cos(anglePlacement * Math.PI / 180)

            rotation: -parent.rotation // Reste droit

            // --- 1. LES 3 ARCS FIXES (Vectoriel Pur) ---
            // LE REPEATER EST À L'EXTÉRIEUR !
            Repeater {
                model: 3

                delegate: Shape {
                    anchors.fill: parent
                    antialiasing: true

                    ShapePath {
                        id: arcPath
                        strokeWidth: 3
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap

                        // L'arc index 0 (en bas à gauche) est orange, les autres blancs
                        strokeColor: (index === 0) ? theme.accent : theme.main

                        // --- MATHÉMATIQUES DES ARCS ---
                        readonly property real rad: 20
                        readonly property real startAngle: 220 + (index * 100)
                        readonly property real endAngle: startAngle + 85

                        // Conversion en radians (-90 pour que 0° soit bien à Midi)
                        readonly property real startRad: (startAngle - 90) * (Math.PI / 180)
                        readonly property real endRad: (endAngle - 90) * (Math.PI / 180)

                        // 1. Point de départ
                        startX: (batterieSatellite.width / 2) + rad * Math.cos(startRad)
                        startY: (batterieSatellite.height / 2) + rad * Math.sin(startRad)

                        // 2. Tracé jusqu'au point d'arrivée
                        PathArc {
                            x: (batterieSatellite.width / 2) + arcPath.rad * Math.cos(arcPath.endRad)
                            y: (batterieSatellite.height / 2) + arcPath.rad * Math.sin(arcPath.endRad)
                            radiusX: arcPath.rad
                            radiusY: arcPath.rad
                            useLargeArc: false
                        }
                    }
                }
            }

            // --- 2. L'AIGUILLE INDICATRICE ---
            Rectangle {
                id: zoneAiguilleBatterie
                anchors.centerIn: parent
                width: parent.width; height: parent.height
                color: "transparent"

                // Rotation de 210° (0%) à 510° (100%)
                // Utilise batteryChargePercentage.value pour le vrai pourcentage
                property int niveauActuel: infoBatterie.percent
                rotation: 210 + ((niveauActuel / 100) * 300)

                // ==========================================
                // AIGUILLE VECTORIELLE DE LA BATTERIE
                // ==========================================
                Item {
                    id: aiguilleBatterie

                    // 1. LES BONNES PROPORTIONS (Base > Pointe)
                    width: 4
                    height: parent.height / 2 - 10

                    // 2. LE PLACEMENT DU PIVOT EXACT AU CENTRE
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.verticalCenter
                    // On abaisse de la moitié de la base pour centrer le cercle
                    anchors.bottomMargin: -(width / 2)

                    // (Plus de propriété 'rotation' ici !)

                    Shape {
                        anchors.fill: parent
                        antialiasing: true

                        ShapePath {
                            id: aiguilleBatteriePath
                            fillColor: theme.main // Orange pour les heures
                            strokeColor: "transparent"

                            property real tipW: 2 // La pointe est bien plus fine que la base (12)

                            // 0. Point de départ : Haut-GAUCHE de la pointe
                            startX: (aiguilleBatterie.width / 2) - (tipW / 2)
                            startY: tipW / 2

                            // 1. Le dôme de la pointe
                            PathArc {
                                x: (aiguilleBatterie.width / 2) + (aiguilleBatteriePath.tipW / 2)
                                y: aiguilleBatteriePath.tipW / 2
                                radiusX: aiguilleBatteriePath.tipW / 2
                                radiusY: aiguilleBatteriePath.tipW / 2
                            }

                            // 2. Le flanc DROIT
                            PathLine {
                                x: aiguilleBatterie.width
                                y: aiguilleBatterie.height - (aiguilleBatterie.width / 2)
                            }

                            // 3. L'arrondi de la base
                            PathArc {
                                x: 0
                                y: aiguilleBatterie.height - (aiguilleBatterie.width / 2)
                                radiusX: aiguilleBatterie.width / 2
                                radiusY: aiguilleBatterie.width / 2
                            }

                            // 4. Le flanc GAUCHE
                            PathLine {
                                x: aiguilleBatteriePath.startX
                                y: aiguilleBatteriePath.startY
                            }
                        }
                    }
                }
            }

            // --- 3. LOGO BATTERIE VECTORIEL FIXE (À 6H) ---
            Item {
                width: 7; height: 11
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 2

                // Gestion de la couleur (orange si < 33%, sinon gris)
                property color iconColor: (aiguilleBatterie.niveauActuel <= 33) ? theme.accent : theme.main

                // Le corps de la pile (contour)
                Rectangle {
                    width: 7; height: 10
                    anchors.bottom: parent.bottom
                    color: "transparent"
                    border.width: 1
                    border.color: parent.iconColor
                    radius: 1.5
                }

                // Le plot positif en haut
                Rectangle {
                    width: 3; height: 1.5
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: parent.iconColor
                    radius: 0.5
                }
            }
        }
    }

    /////////////////////////////////
    //      TRAITS DES MINUTES     //
    /////////////////////////////////
    Repeater {
        model: 60

        // Le delegate devient un conteneur global "Item"
        delegate: Item {
            id: minuteMarkWrapper

            // On lui donne une petite taille pour que la rotation s'axe bien au centre
            width: 15; height: 15

            // --- PLACEMENT ET ROTATION (Identique à ton code) ---
            property real rad: 165
            property real angle: (index * (Math.PI * 2 / 60)) - (Math.PI / 2)

            x: (parent.width / 2) + rad * Math.cos(angle) - (width / 2)
            y: (parent.height / 2) + rad * Math.sin(angle) - (height / 2)

            rotation: index * 6

            // --- 1. LE TRAIT CLASSIQUE ---
            Rectangle {
                anchors.centerIn: parent
                width: (index % 5 === 0) ? 3 : 1
                height: (index % 5 === 0) ? 15 : 8
                color: theme.main

                // LA MAGIE EST ICI : Invisible si on est à 6h (index 30)
                visible: index !== 30
            }

            // --- 2. LE TRIANGLE DE LA DATE ---
            Shape {
                anchors.centerIn: parent
                width: 12; height: 10 // Largeur et hauteur du triangle
                antialiasing: true

                // LA MAGIE EST ICI : Visible UNIQUEMENT à 6h
                visible: index === 30

                ShapePath {
                    fillColor: theme.accent // Orange pour guider l'œil vers la date
                    strokeColor: "transparent"

                    // Dessin vectoriel du triangle
                    // Il pointe vers le "haut" de sa propre boîte.
                    // Comme l'index 30 est tourné à 180°, il pointera vers le bas, droit sur la date !
                    startX: 0; startY: 10      // Coin en bas à gauche
                    PathLine { x: 12; y: 10 }  // Ligne vers le coin en bas à droite
                    PathLine { x: 6; y: 0 }    // Ligne vers la pointe en haut au centre
                    PathLine { x: 0; y: 10 }   // Retour au point de départ pour fermer
                }
            }
        }
    }
    /////////////////////////////////
    //             DATE            //
    /////////////////////////////////
    Item {
        id: anneauDate
        anchors.fill: parent // Prend toute la taille de la montre

        // --- LA ROTATION INTELLIGENTE ---
        // On tourne l'anneau entier pour que la date actuelle tombe à 6h.
        // Formule : -(Jour actuel - 1) * (360° / 31)
        // On retire 0.5 jour au total pour que le chiffre soit aligné à midi pile
        rotation: -((time.getDate() - 1) + (time.getHours() / 24) + (time.getMinutes() / 1440) - 0.5) * (360 / 31)

        // Génération des 31 chiffres
        Repeater {
            model: 31

            delegate: Item {
                anchors.fill: parent
                // On répartit les 31 Item en cercle.
                // L'index 0 (le chiffre 1) est placé sans rotation (donc en bas grâce à l'ancre)
                rotation: index * (360 / 31)

                Text {
                    text: index + 1
                    // Le jour actuel s'allume en orange, les autres restent discrets
                    color: (index + 1 === time.getDate()) ? theme.accent : theme.main
                    font.pixelSize: 14
                    font.bold: (index + 1 === time.getDate())

                    // On place le chiffre tout en bas
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 2 // Petit espace avec le bord de l'écran
                }
            }
        }
    }
}
