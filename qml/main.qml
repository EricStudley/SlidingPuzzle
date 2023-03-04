import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.0
import Qt.labs.platform 1.0

ApplicationWindow {
    id: root
    visible: true
    width: 500
    height: 500
    color: "#2e1500"

    signal move(var direction)

    Action { shortcut: "Up"; onTriggered: move("Up") }
    Action { shortcut: "Down"; onTriggered: move("Down") }
    Action { shortcut: "Left"; onTriggered: move("Left") }
    Action { shortcut: "Right"; onTriggered: move("Right") }

    FileDialog {
        id: fileDialog
        visible: true
        title: "Select Puzzle Image"

        onAccepted: {
            repeater.model = 0
            puzzleController.puzzleFilename = fileDialog.file
            repeater.model = puzzleController.pieceCount
        }
    }

    BorderImage {
        id: borderImage
        anchors { fill: parent }
        border { left: 14; top: 14; right: 14; bottom: 14 }
        horizontalTileMode: BorderImage.Stretch
        verticalTileMode: BorderImage.Stretch
        source: "qrc:/images/background_border.png"

        Item {
            id: game
            anchors { fill: parent; margins: borderImage.border.left }

            Repeater {
                id: repeater
                model: puzzleController.pieceCount

                Image {
                    id: piece
                    x: initialX
                    y: initialY
                    width: game.width / puzzleController.columnCount
                    height: game.height / puzzleController.rowCount
                    source: "image://imageprovider/" + index + "_" + puzzleController.puzzleFilename

                    property double initialX: (index % puzzleController.columnCount) * width
                    property double initialY: Math.floor((index / puzzleController.rowCount)) * height

                    property bool solved: x === initialX && y === initialY

                    property point newPos

                    function move(x, y) {
                        newPos = Qt.point(x, y)
                        anim.start()
                    }

                    SequentialAnimation {
                        id: anim

                        SmoothedAnimation { target: piece; property: "x"; to: newPos.x; duration: 1000 }
                        SmoothedAnimation { target: piece; property: "y"; to: newPos.y; duration: 1000 }

                        onRunningChanged: {
                            if (index === (puzzleController.pieceCount - 1)) {
                                var solved = true
                                for (var i = 0; i < puzzleController.pieceCount; i++) {
                                    var objX = (i % puzzleController.columnCount) * width
                                    var objY = Math.floor((i / puzzleController.rowCount)) * height

                                    var obj = game.childAt(objX, objY)
                                    if (obj && !obj.solved) {
                                        solved = false
                                    }
                                }
                            }
                        }
                    }

                    Connections {
                        target: root

                        function onMove(direction) {
                            if (index === (puzzleController.pieceCount - 1) && !anim.running) {
                                var obj
                                switch (direction) {
                                case "Up":    obj = game.childAt(x + (width * 0.5), y + (height * 1.5)); break
                                case "Down":  obj = game.childAt(x + (width * 0.5), y - (height * 0.5)); break
                                case "Left":  obj = game.childAt(x + (width * 1.5), y + (height * 0.5)); break
                                case "Right": obj = game.childAt(x - (width * 0.5), y + (height * 0.5)); break
                                }

                                if (obj) {
                                    var tempX = obj.x
                                    var tempY = obj.y
                                    obj.move(x, y)
                                    piece.move(tempX, tempY)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        anchors { fill: parent }

        onClicked: fileDialog.open()
    }
}
