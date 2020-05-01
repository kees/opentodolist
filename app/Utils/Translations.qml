pragma Singleton

import QtQuick 2.0

Item {

    readonly property ListModel languages: languageModel

    ListModel {
        id: languageModel

        ListElement {
            key: ""
            name: qsTr("System Language")
        }
        ListElement {
            key: "da"
            name: qsTr("Danish")
        }
        ListElement {
            key: "de"
            name: qsTr("German")
        }
        ListElement {
            key: "el"
            name: qsTr("Greek")
        }
        ListElement {
            key: "en"
            name: qsTr("English")
        }
        ListElement {
            key: "es"
            name: qsTr("Spanish")
        }
        ListElement {
            key: "es_LA_C"
            name: qsTr("Spanish (Latin America & Caribbean)")
        }
        ListElement {
            key: "fil"
            name: qsTr("Filipino")
        }
        ListElement {
            key: "fr"
            name: qsTr("French")
        }
        ListElement {
            key: "hu"
            name: qsTr("Hungarian")
        }
        ListElement {
            key: "it"
            name: qsTr("Italian")
        }
        ListElement {
            key: "nl"
            name: qsTr("Dutch")
        }
        ListElement {
            key: "no"
            name: qsTr("Norwegian")
        }
        ListElement {
            key: "pl"
            name: qsTr("Polish")
        }
        ListElement {
            key: "pt"
            name: qsTr("Portuguese")
        }
        ListElement {
            key: "pt_BR"
            name: qsTr("Portuguese (Brazil)")
        }
        ListElement {
            key: "ru"
            name: qsTr("Russian")
        }
        ListElement {
            key: "sv"
            name: qsTr("Swedish")
        }
        ListElement {
            key: "tk"
            name: qsTr("Turkmen")
        }
        ListElement {
            key: "tr"
            name: qsTr("Turkish")
        }
        ListElement {
            key: "vi"
            name: qsTr("Vietnamese")
        }
    }

    Component.onCompleted: {
        var availableLangs = translations.allLanguages();
        for (var i = 0; i < availableLangs.length; ++i) {
            var availableLang = availableLangs[i];
            var found = false;
            for (var j = 0; j < languageModel.count; ++j) {
                var lang = languageModel.get(j);
                if (lang.key === availableLang) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                languageModel.append(
                    {
                        "key": availableLang,
                        "name": availableLang
                    });
            }
        }
    }

}
