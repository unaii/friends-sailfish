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
import harbour.friends 1.0
import harbour.friends.social 1.0
import harbour.friends.social.extra 1.0

Page {
    id: container
    property string identifier
    property string type
    property bool fql: false
    function load() {
        console.debug(identifier + " " + type)
        if (item.status == SocialNetwork.Idle || item.status == SocialNetwork.Error) {
            if (!item.load()) {
                console.debug("FQL type not supported: " + type)
                item.showUnsolvableObject()
            }
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Active) {
            if (item.source.length > 0) {
                item.pushPage(item.source, item.properties, item.needLoad, item.reparentedItems)
            }
        }
    }

    TypeSolver {
        id: item
        property string source
        property var properties
        property bool needLoad
        property list<QtObject> reparentedItems

        function pushPage(source, properties, needLoad, reparentedItems) {
            if (container.status == PageStatus.Active) {
                var page = pageStack.replace(Qt.resolvedUrl(source), properties,
                                             PageStackAction.Immediate)

                if (reparentedItems.length > 0) {
                    for (var i = 0; i < reparentedItems.length; i++) {
                        NotificationsHelper.reparentObject(reparentedItems[i], page)
                    }
                }

                if (needLoad) {
                    page.load()
                }
            } else {
                item.source = source
                item.properties = properties
                item.needLoad = needLoad
                if (reparentedItems !== null) {
                    item.reparentedItems = reparentedItems
                }
            }
        }

        function showUnsolvableObject() {
            if (item.status == SocialNetwork.Idle) {
                console.debug("Unknown type: " + objectType + " and as string: " + objectTypeString)
                unsupported.enabled = true
            }
        }

        function solveObjectType() {
            console.debug("Object Type:" + objectType + " " + objectTypeString)

            if (objectType == Facebook.Album) {
                item.pushPage("PhotosPage.qml", {"identifier": item.identifier}, true, [])
                return
            } else if (objectType == Facebook.Event) {
                item.pushPage("EventPage.qml", {"identifier": item.identifier}, true, [])
                return
            } else if(objectType == Facebook.Group) {
                item.pushPage("GroupPage.qml", {"identifier": item.identifier}, true, [])
                return
            } else if (objectType == Facebook.Post) {
                if (objectTypeString == "post") {
                    post.filter.fields = "id,from,to,message,story,likes,comments,created_time,tags,story_tags,link,picture,name,caption,description,object_id"
                } else if (objectTypeString == "location") {
                    post.filter.fields = "id,from,to,message,story,likes,comments,created_time,tags"
                } else if (objectTypeString == "link") {
                    post.filter.fields = "id,from,to,message,story,likes,comments,created_time,link,picture,name,caption,description"
                } else if (objectTypeString == "status") {
                    post.filter.fields = "id,from,to,message,story,likes,comments,created_time"
                } else {
                    showUnsolvableObject()
                    return
                }
                indicator.item = post
                post.load()
            } else if (objectType == Facebook.Page) {
                item.pushPage("PagePage.qml", {"identifier": item.identifier}, true, [])
                return
            } else if (objectType == Facebook.Photo) {
                indicator.item = photo
                photo.load()
            } else if (objectType == Facebook.User) {
                item.pushPage("UserPage.qml", {"identifier": item.identifier}, true, [])
                return
            } else {
                showUnsolvableObject()
                return
            }
        }

        socialNetwork: facebook
        filter: TypeSolverFilter {
            identifier: container.identifier
            type: container.type
            fql: container.fql
        }
        onLoaded: solveObjectType()
    }

    FacebookExtraPost {
        id: post
        socialNetwork: facebook
        filter: FacebookItemFilter {
            identifier: item.identifier
        }
        onLoaded: {
            if (ok) {
                var headerProperties = {"post": post}
                item.pushPage(Qt.resolvedUrl("CommentsPage.qml"),
                              {"identifier": post.identifier, "item": post,
                               "headerComponent": postHeaderComponent,
                               "headerProperties": headerProperties}, true, [post])
            }
        }
    }

    ListModel {
        id: photoModel
    }

    FacebookPhoto {
        id: photo
        socialNetwork: facebook
        filter: FacebookItemFilter {
            identifier: item.identifier
            fields: "id,name,updated_time,likes,comments"
        }

        onLoaded: {
            if (ok) {
                var headerProperties = {"post": post}
                photoModel.append({"contentItem": photo})

                item.pushPage(Qt.resolvedUrl("PhotoPage.qml"),
                              {"currentIndex": 0, "model": photoModel,
                               "isFacebookModel": false}, false, [photoModel, photo])
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent

        ViewPlaceholder {
            id: unsupported
            //: Describe that loading this item is not available yet
            //% "Friends cannot load this yet. This feature has not been implemented."
            text: qsTrId("friends_type_unsupported")
        }
    }

    StateIndicator {
        id: indicator
        item: item
    }
}

