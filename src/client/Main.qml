import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import "request.js" as XHR

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Button {
        id: button
        x: 198
        y: 192
        text: qsTr("Button")

        onClicked: XHR.sendRequest("http://localhost:8080/healthcheck", function(response) {
            console.log(response.status);
            console.log(response.contentType);
            console.log(response.content);
        });
    }
}
