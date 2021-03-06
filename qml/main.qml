import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.0
import QtGraphicalEffects 1.12
import Qt.labs.settings 1.0

import OpenHD 1.0

import "./ui"
import "./ui/widgets"


ApplicationWindow {
    id: applicationWindow
    visible: true
    width: 800
    height: 480
    minimumHeight: 320
    minimumWidth: 480
    title: qsTr("Open.HD")
    color: EnableMainVideo ? "black" : "#00000000"

    visibility: UseFullscreen ? "FullScreen" : "AutomaticVisibility"

    property bool initialised: false

    onAfterSynchronizing: {
        if (!initialised) {
            hudOverlayGrid.messageHUD.pushMessage("Initializing", 1)

            initialised = true;
            if (EnableMainVideo) {
                MainStream.startVideo();
            }
            if (EnablePiP) {
                PiPStream.startVideo();
            }
        }
    }

    // this is not used but must stay right here, it forces qmlglsink to completely
    // initialize the rendering system early. Without this, the next GstGLVideoItem
    // to be initialized, depending on the order they appear in the QML, will simply
    // not work on desktop linux.
    Loader {
        source:  (EnableMainVideo && EnablePiP)  ? "DummyVideoItem.qml" : ""
    }

    /*
     * Local app settings. Uses the "user defaults" system on Mac/iOS, the Registry on Windows,
     * and equivalent settings systems on Linux and Android
     *
     */
    Settings {
        id: settings
        property int main_video_port: 5600
        property int pip_video_port: 5601
        property int battery_cells: 3
        property bool show_pip_video: false
        property bool enable_software_video_decoder: false
        property bool enable_rtp: true
        property bool hide_watermark: false

        property bool enable_speech: true
        property bool enable_imperial: false
        property bool enable_rc: false

        property bool show_downlink_rssi: true
        property bool show_uplink_rssi: true
        property bool show_bitrate: true
        property bool show_air_battery: true
        property bool show_gps: true
        property bool show_home_distance: true
        property bool show_flight_timer: true
        property bool show_flight_mode: true
        property bool show_ground_status: true
        property bool show_air_status: true
        property bool show_message_hud: true
        property bool show_horizon: true
        property bool show_fpv: true
        property bool show_altitude: true
        property bool show_speed: true
        property bool show_heading: true
        property bool show_altitude_second: true
        property bool show_arrow: true
        property bool show_map: false
        property bool show_throttle: true
    }

    OpenHDRC {
        id: openHDRC
    }

    QOpenHDLink {
        id: link
    }

    OpenHDSettings {
        id: openHDSettings
    }

    Connections {
        target: openHDSettings
        onGroundStationIPUpdated: {
            link.setGroundIP(address)
            openHDRC.setGroundIP(address)
            mavlinkTelemetry.setGroundIP(address)
        }
    }

    OpenHDTelemetry {
        id: openHDTelemetry
    }

    MavlinkTelemetry {
        id: mavlinkTelemetry
    }

    //FrSkyTelemetry {
    //    id: frskyTelemetry
    //}

    //MSPTelemetry {
    //    id: mspTelemetry
    //}

    //LTMTelemetry {
    //    id: ltmTelemetry
    //}

    Loader {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        z: 1.0
        source: EnableMainVideo ? "MainVideoItem.qml" : ""
    }

    Connections {
        target: OpenHD
        onMessageReceived: {
            hudOverlayGrid.messageHUD.pushMessage(message, level)
        }
    }

    Connections {
        target: LocalMessage
        onMessageReceived: {
            hudOverlayGrid.messageHUD.pushMessage(message, level)
        }
    }

    Connections {
        target: MainStream
        onVideoRunning: {
            if (running) {
                //console.log("Main stream running");
            } else {
                //console.log("Main stream lost");
            }
        }
    }

    // UI areas

    UpperOverlayBar {
        id: upperOverlayBar
        onSettingsButtonClicked: {
            settings_panel.openSettings();
        }
    }

    HUDOverlayGrid {
        id: hudOverlayGrid
        anchors.fill: parent
        z: 3.0
    }

    LowerOverlayBar {
        id: lowerOverlayBar
    }


    SettingsPopup {
        id: settings_panel
        onLocalMessage: {
            hudOverlayGrid.messageHUD.pushMessage(message, level)
        }
    }
}

/*##^##
Designer {
    D{i:6;anchors_y:8}D{i:7;anchors_y:32}D{i:8;anchors_y:32}D{i:9;anchors_y:8}D{i:10;anchors_y:32}
D{i:11;anchors_y:32}D{i:12;anchors_y:11}D{i:13;anchors_y:11}D{i:14;anchors_x:62}D{i:15;anchors_x:128}
D{i:16;anchors_x:136;anchors_y:11}D{i:17;anchors_x:82;anchors_y:8}D{i:19;anchors_y:8}
D{i:21;anchors_y:31}D{i:22;anchors_y:8}D{i:23;anchors_y:11}D{i:24;anchors_y:32}
}
##^##*/
