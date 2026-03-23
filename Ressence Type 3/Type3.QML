import QtQuick 2.0
import QtQuick.Shapes 1.0

Rectangle {
    
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
    property int fakeSeconds: 0
    antialiasing: true

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
    Rectangle {
        id: cadran
        width: background.width; height: background.height
        radius: height/2
        color: theme.bg
        rotation: (time.getMinutes() * 6) + (time.getSeconds() * 0.1) + (time.getMilliseconds() * 0.0001)

        // AIGUILLE DES MINUTES
        Rectangle {
            id: aiguilleMinutes
            width: 5; height: parent.height / 2 - 20;
            anchors.top: parent.top
            anchors.topMargin: 25
            anchors.horizontalCenter: parent.horizontalCenter
            color: theme.main
        }
        /////////////////////////////////
        //          HEURES             //
        /////////////////////////////////
        Rectangle {
            id: heures
            width: 150; height: width
            color: theme.bg
            radius: height/2

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.width * 0.1
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
                rotation: (time.getHours() % 12) * 30 + (time.getMinutes() * 0.5)

                //AIGUILLE DES HEURES
                Rectangle {
                    id: aiguilleHeure
                    width: heures.width * 0.05; height: heures.width * 0.25;
                    anchors.top: parent.top
                    anchors.topMargin: heures.width * 0.05
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: theme.accent
                }
            }

        }
        /////////////////////////////////
        //         SECONDES            //
        /////////////////////////////////
        Rectangle {
            id: secondes
            width: 50; height: 50
            color: theme.bg
            radius: height/2
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 40
            rotation: -parent.rotation

            Item {
                id: conteneurArc
                width: parent.width - 10; height: parent.height - 10 // Taille du cercle parent
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                // (Secondes * 6) + (Millisecondes * 0.006)
                rotation: (time.getSeconds() * 6) + (time.getMilliseconds() * 0.006)
                // 1. Le Cercle qui donne la courbure
                Rectangle {
                    id: cercleCourbe
                    anchors.fill: parent
                    radius: height / 2
                    color: "transparent"
                    // L'épaisseur de ton arc
                    border.width: 5
                    border.color: theme.accent
                    // Pour lisser la courbe
                    antialiasing: true
                }

                // 2. Le Masque (un rectangle noir qui cache le bas)
                Rectangle {
                    width: parent.width
                    height: parent.height / 2
                    color: theme.bg // La couleur du fond de ta montre
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                }
            }
        }
        /////////////////////////////////
        //            JOURS            //
        /////////////////////////////////
        Rectangle {
            id: jourSemaine
            width: 50; height: 50
            color: theme.bg
            radius: height/2

            // Placement : à droite (à l'opposé des secondes) et centré verticalement
            anchors.right: parent.right
            anchors.rightMargin: 55
            anchors.verticalCenter: parent.verticalCenter

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

            Rectangle{
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

                Rectangle{
                    id: aiguilleJours
                    color: theme.main
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: 4; height: parent.height/2
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: parent // Toujours là, fidèle au poste
                }    
            }
        }
        /////////////////////////////////
        //      TRAITS DES MINUTES     //
        /////////////////////////////////
        Repeater {
            model: 60
            delegate: Rectangle {
                id: minuteMark

                // Style : un peu plus large et long toutes les 5 minutes
                width: (index % 5 === 0) ? 3 : 1
                height: (index % 5 === 0) ? 15 : 8
                color: theme.main

                // On les place sur le bord
                property real rad: 185
                property real angle: (index * (Math.PI * 2 / 60)) - (Math.PI / 2)

                x: (parent.width / 2) + rad * Math.cos(angle) - (width / 2)
                y: (parent.height / 2) + rad * Math.sin(angle) - (height / 2)

                // On fait pivoter le trait pour qu'il pointe vers le centre
                rotation: index * 6
            }
        }
        /////////////////////////////////
        //  HEURE NUMERIQUE - DEBOGAGE //
        /////////////////////////////////
        // Text {
        //     id: debugTime
        //     // On formate l'heure pour qu'elle soit lisible : HH:MM:SS
        //     text: Qt.formatDateTime(background.time, "hh:mm:ss")

        //     color: "cyan" // Une couleur qui tranche avec le reste
        //     font.pixelSize: 24
        //     font.family: "Monospace" // Plus facile à lire pour des chiffres qui bougent
        //     font.bold: true

        //     // On le place en bas au centre
        //     anchors.bottom: parent.bottom
        //     anchors.horizontalCenter: parent.horizontalCenter
        //     anchors.bottomMargin: 20

        //     // On ajoute un petit fond noir semi-transparent pour la lisibilité
        //     Rectangle {
        //         anchors.fill: parent
        //         anchors.margins: -5
        //         color: "black"
        //         opacity: 0.7
        //         z: -1 // Derrière le texte
        //         radius: 5
        //     }
        // }
    }
}