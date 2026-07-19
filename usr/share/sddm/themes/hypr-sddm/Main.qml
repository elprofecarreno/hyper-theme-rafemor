import QtQuick 2.15
import Qt5Compat.GraphicalEffects 6.0
import QtQuick.Controls 2.15
import SddmComponents 2.0

Rectangle {
    id: container
    width: screenModel.geometry(screenModel.primary).width
    height: screenModel.geometry(screenModel.primary).height

    Image {
        id: backgroundImage
        source: "4k-hogwarts-wallpapers.jpg"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 80 
        anchors.verticalCenter: parent.verticalCenter
        width: 320
        height: 180
        color: "transparent"
        radius: 12
        border.color: "#ffffff"
        border.width: 2

        Column {
            anchors.centerIn: parent
            spacing: 15

            TextField {
                id: name
                width: 260
                height: 40
                text: userModel.lastUser
                font.pixelSize: 14
                color: "#ffffff"
                echoMode: TextInput.Normal
                placeholderText: "Usuario"
                placeholderTextColor: "#80ffffff"

                background: Rectangle {
                    color: "transparent"
                    border.color: "#ffffff"
                    border.width: 1
                    radius: 6
                }
            }

            TextField {
                id: password
                width: 260
                height: 40
                font.pixelSize: 14
                color: "#ffffff"
                echoMode: TextInput.Password
                focus: true
                placeholderText: "Contraseña"
                placeholderTextColor: "#80ffffff"

                background: Rectangle {
                    color: "transparent"
                    border.color: "#ffffff"
                    border.width: 1
                    radius: 6
                }

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        sddm.login(name.text, password.text, sessionModel.lastIndex)
                    }
                }
            }

            Text {
                id: errorMessage
                text: sddm.errorString
                color: "#ffffff"
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
