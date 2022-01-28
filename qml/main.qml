import QtQuick 2.11
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.4
import QtQuick.Window 2.11

ApplicationWindow {
    id: root
    visible: true
    width: 500
    height: 500
    color: "#263740"

    signal move(var direction)

    Action { shortcut: "Up"; onTriggered: move("Up") }
    Action { shortcut: "Down"; onTriggered: move("Down") }
    Action { shortcut: "Left"; onTriggered: move("Left") }
    Action { shortcut: "Right"; onTriggered: move("Right") }

    FileDialog {
        id: fileDialog
        visible: true
        title: "Select Puzzle Image"
        folder: shortcuts.pictures

        onAccepted: puzzleController.puzzleFilename = fileUrl
    }

    Item {
        id: game
        width: 250
        height: width
        anchors { centerIn: parent }

        Repeater {
            model: puzzleController.pieceCount

            Image {
                id: piece
                x: initialX
                y: initialY
                width: game.width / puzzleController.columnCount
                height: game.height / puzzleController.rowCount
                source: "image://imageprovider/" + index + "_" + puzzleController.puzzleFilename

                property int initialX: (index % puzzleController.columnCount) * width
                property int initialY: Math.floor((index / puzzleController.rowCount)) * height

                property bool solved: x === initialX && y === initialY

                property point newPos

                function move(x, y) {
                    newPos = Qt.point(x, y)
                    anim.start()
                }

                SequentialAnimation {
                    id: anim
                    SmoothedAnimation { target: piece; property: "x"; to: newPos.x; duration: 2000 }
                    SmoothedAnimation { target: piece; property: "y"; to: newPos.y; duration: 2000 }

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

                            console.log(solved)
                        }
                    }
                }

                Connections {
                    target: root

                    onMove: {
                        if (index === (puzzleController.pieceCount - 1) && !anim.running) {
                            var obj
                            switch (direction) {
                            case "Up":    obj = game.childAt(x, y + height); break
                            case "Down":  obj = game.childAt(x, y - height); break
                            case "Left":  obj = game.childAt(x + width, y); break
                            case "Right": obj = game.childAt(x - width, y); break
                            }

                            if (obj) {
                                var tempX = obj.x
                                var tempY = obj.y
                                obj.move(x, y)
                                move(tempX, tempY)
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
