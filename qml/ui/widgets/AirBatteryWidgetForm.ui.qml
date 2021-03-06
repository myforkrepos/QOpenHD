import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12
import Qt.labs.settings 1.0

import OpenHD 1.0

BaseWidget {
    id: airBatteryWidget
    width: 96
    height: 48

    visible: settings.show_air_battery

    widgetIdentifier: "air_battery_widget"

    defaultAlignment: 3
    defaultXOffset: 0
    defaultYOffset: 0
    defaultHCenter: false
    defaultVCenter: false

    hasWidgetDetail: true
    widgetDetailComponent: Column {
        Item {
            width: parent.width
            height: 24
            Text { text: "Voltage:";  color: "white"; font.bold: true; font.pixelSize: detailPanelFontPixels; anchors.left: parent.left }
            Text {
                text: Number(OpenHD.battery_voltage/1000.0).toLocaleString(Qt.locale(), 'f', 1) + "V";
                color: "white";
                font.bold: true;
                font.pixelSize: detailPanelFontPixels;
                anchors.right: parent.right
            }
        }
        Item {
            width: parent.width
            height: 24
            Text { text: "Current:";  color: "white"; font.bold: true; font.pixelSize: detailPanelFontPixels; anchors.left: parent.left }
            Text {
                text: Number(OpenHD.battery_current/100.0).toLocaleString(Qt.locale(), 'f', 1) + "A";
                color: "white";
                font.bold: true;
                font.pixelSize: detailPanelFontPixels;
                anchors.right: parent.right
            }
        }
    }

    Item {
        id: widgetInner

        anchors.fill: parent
        Text {
            id: battery_percent
            y: 0
            width: 48
            height: 24
            color: "#ffffff"
            text: qsTr("%L1%").arg(OpenHD.battery_percent)
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: batteryGauge.right
            anchors.leftMargin: 0
            clip: true
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignLeft
            font.pixelSize: 14
        }

        Text {
            id: batteryGauge
            y: 8
            width: 36
            height: 48
            // @disable-check M223
            color: {
                // todo: expose battery_voltage_to_percent to QML instead of using cell levels here
                // @disable-check M222
                var cells = settings.value("show_ground_status", true);
                var cellVoltage = OpenHD.battery_voltage / cells;
                // 20% warning, 15% critical
                return cellVoltage < 3.73 ? (cellVoltage < 3.71 ? "#ff0000" : "#fbfd15") : "#ffffff"
            }
            text: OpenHD.battery_gauge
            anchors.left: parent.left
            anchors.leftMargin: 12
            fontSizeMode: Text.VerticalFit
            anchors.verticalCenter: parent.verticalCenter
            clip: true
            elide: Text.ElideMiddle
            font.family: "Material Design Icons"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 36
        }
    }
}
