/*
 * Copyright (C) 2013 Lucien XU <sfietkonstantin@free.fr>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * The names of its contributors may not be used to endorse or promote
 *     products derived from this software without specific prior written
 *     permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.friends.social 1.0
import "UiConstants.js" as Ui

Page {
    id: container
    property string identifier
    function load() {
        user.load()
    }

    onStatusChanged: {
        if (status == PageStatus.Active) {
            pageStack.pushAttached(menuPage)
        }
    }

    StateIndicator {
        busy: user.status == SocialNetwork.Busy
        error: user.status == SocialNetwork.Error
        onReload: container.load()
    }

    FacebookUser {
        id: user
        socialNetwork: facebook
        filter: FacebookItemFilter {
            identifier: container.identifier
            fields: "name,cover"
        }
    }

    SilicaListView {
        id: view
        anchors.fill: parent
        header: Item {
            width: view.width
            height: childrenRect.height
            Item {
                anchors.left: parent.left; anchors.right: parent.right
                height: 2 * Theme.itemSizeExtraLarge + Theme.itemSizeSmall + 0.5 * Theme.paddingSmall

                Rectangle {
                    id: coverBackground
                    anchors.left: parent.left; anchors.right: parent.right
                    height: 2 * Theme.itemSizeExtraLarge
                    color: Theme.secondaryHighlightColor
                    clip: true

                    FacebookImage {
                        id: image
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        url: user.cover.source
                    }

                    Rectangle {
                        id: gradient
                        opacity: 0
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left; anchors.right: parent.right
                        height: Theme.paddingLarge + Theme.fontSizeLarge + Theme.paddingMedium
                        gradient: Gradient {
                            GradientStop {position: 0; color: "#00000000"}
                            GradientStop {position: 1; color: "black"}
                        }
                    }

                    Label {
                        id: nameText
                        anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingMedium + Theme.itemSizeSmall * 2
                        anchors.bottom: parent.bottom; anchors.bottomMargin: Theme.paddingMedium
                        opacity: 0
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeLarge
                        states: [
                            State {
                                name: "visible"; when: user.name != ""
                                PropertyChanges {
                                    target: nameText
                                    opacity: 1
                                    text: user.name
                                }
                                PropertyChanges {
                                    target: gradient
                                    opacity: 0.8
                                }
                            }
                        ]
                        Behavior on opacity {
                            NumberAnimation {duration: Ui.ANIMATION_DURATION_NORMAL}
                        }
                    }
                }

                Rectangle {
                    id: pictureContainer
                    opacity: 0
                    anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                    anchors.verticalCenter: coverBackground.bottom
                    color: Theme.primaryColor
                    width: Theme.itemSizeSmall * 2 + Theme.paddingSmall
                    height: Theme.itemSizeSmall * 2 + Theme.paddingSmall

                    states: [
                        State {
                            name: "visible"; when: picture.status == Image.Ready
                            PropertyChanges {
                                target: pictureContainer
                                opacity: 1
                            }
                        }
                    ]
                    Behavior on opacity {
                        NumberAnimation {duration: Ui.ANIMATION_DURATION_NORMAL}
                    }

                    FacebookPicture {
                        id: picture
                        identifier: user.identifier
                        anchors.centerIn: parent
                        imageWidth: Theme.itemSizeSmall * 2
                        imageHeight: Theme.itemSizeSmall * 2
                    }
                }
            }
        }



        PullDownMenu {
            z: 1000

            MenuItem {
                text: qsTr("Photos")
                enabled: false
            }

            MenuItem {
                text: qsTr("Albums")
                onClicked: {
                    var page = pageStack.push(Qt.resolvedUrl("AlbumsPage.qml"),
                                              {"identifier": user.identifier})
                    page.load()
                }
            }

            MenuItem {
                text: user.identifier == me.identifier ? qsTr("Personnal informations")
                                                       : qsTr("About %1").arg(user.name)
                enabled: false
            }
        }
    }

}
