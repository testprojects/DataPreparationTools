import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Window 2.12
import QtQml 2.12
import QtQuick.Layouts 1.14
import Qt.labs.settings 1.0

ApplicationWindow {
    id: window
    visibility: Window.Maximized
    visible: true
    title: qsTr("DataPreparationTools")

    property var configConnectToDB: ({})

    Settings {
        id: settingsConnectDatabase
        property string host: "localhost"
        property int port: 5432
        property string nameDatabase: "postgres"
        property string user: "postgres"
        property string password: ""
        property string pathToPython: ""
    }

    header: ToolBar {
        contentHeight: toolButton.implicitHeight

        RowLayout {
            anchors.fill: parent
            ToolButton {
                id: toolButton
                text: stackView.depth > 1 ? "\u25C0" : "\u2630"
                font.pixelSize: Qt.application.font.pixelSize * 1.6
                onClicked: {
                    if (stackView.depth > 1) {
                        stackView.pop()
                    } else {
                        drawer.open()
                    }
                }
            }

            Label {
                text: stackView.currentItem.title
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                rightPadding: getButton.visible ? 0 : getButton.implicitWidth
            }

            ToolButton {
                id: getButton
                icon.source: "qrc:/icons/res/icons/1x/outline_download_white_24dp.png"
                visible: stackView.currentItem.objectName == "ViewData"
                onClicked: {
                    startStopProcess()
                    dataManagement.createShp()
                    startStopProcess()
                }
            }
        }
    }

    Drawer {
        id: drawer
        width: window.width * 0.66
        height: window.height

        Column {
            anchors.fill: parent

            ItemDelegate {
                text: qsTr("View data")
                width: parent.width
                onClicked: {
                    stackView.push("ViewData.qml")
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Settings")
                width: parent.width
                onClicked: {
                    stackView.push("SettingsView.qml")
//                    stackView.currentItem.readSettings()
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Quit")
                width: parent.width
                onClicked: {
                    drawer.close()
                    window.close()
                }
            }
        }
    }

    StackView {
        id: stackView
        initialItem: "MainForm.qml"
        anchors.fill: parent
        property string titleViewData: ''
    }

    BusyIndicator {
        id: processIndicator
        anchors.centerIn: parent
        running: false
        z: 1
    }

    function startStopProcess() {
        processIndicator.running = !processIndicator.running
        window.header.enabled = !window.header.enabled
        window.contentItem.enabled = !window.contentItem.enabled
    }

    function readSettings() {
        configConnectToDB["host"] = settingsConnectDatabase.host
        configConnectToDB["port"] = settingsConnectDatabase.port
        configConnectToDB["nameDatabase"] = settingsConnectDatabase.nameDatabase
        configConnectToDB["user"] = settingsConnectDatabase.user
        configConnectToDB["password"] = settingsConnectDatabase.password

        console.log('---ReadSettings[main]---')
        console.log(configConnectToDB["host"])
        console.log(configConnectToDB["port"])
        console.log(configConnectToDB["nameDatabase"])
        console.log(configConnectToDB["user"])
        console.log(configConnectToDB["password"])
        console.log('---')
    }

    Component.onCompleted: {
        readSettings();
        dataManagement.connectToSourceData(configConnectToDB)
        dataManagement.pathToPython = settingsConnectDatabase.pathToPython
    }
}
