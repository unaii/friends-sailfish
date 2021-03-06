include(social.pri)
include(socialextra/socialextra.pri)
include(login/login.pri)
include(../version.pri)

TEMPLATE = app
TARGET = harbour-friends
TARGETPATH = /usr/bin
DEPLOYMENT_PATH = /usr/share/$$TARGET
DEFINES *= 'VERSION=\'\"$${VERSION}\"\''
DEFINES *= 'CLIENT_ID_PLUGIN=\'\"$${DEPLOYMENT_PATH}/lib/libharbour-friends-clientidplugin.so\"\''
include(data/data.pri)
include(translations/translations.pri)

QT += qml quick quick-private

CONFIG += link_pkgconfig

HEADERS += cachehelper_p.h \
    clientidplugininterface.h \
    tokenmanager.h \
    settingsmanager.h \
    posthelper.h \
    footerhelper.h \
    notificationshelper.h \
    imagehelper.h \
    imagemanager.h \
    changelogmodel.h \
    threadhelper.h \
    objecthelper_p.h \
    abstractdisplayhelper.h \
    userinfohelper.h \
    datehelper.h
SOURCES += main.cpp \
    tokenmanager.cpp \
    settingsmanager.cpp \
    posthelper.cpp \
    footerhelper.cpp \
    notificationshelper.cpp \
    imagehelper.cpp \
    imagemanager.cpp \
    changelogmodel.cpp \
    threadhelper.cpp \
    abstractdisplayhelper.cpp \
    userinfohelper.cpp \
    datehelper.cpp

OTHER_FILES += qml/friends.qml \
    qml/UiConstants.js \
    qml/CoverHeader.qml \
    qml/CoverPage.qml \
    qml/MenuPage.qml \
    qml/NewsPage.qml \
    qml/LoginPage.qml \
    qml/FacebookImage.qml \
    qml/FacebookPicture.qml \
    qml/StateIndicator.qml \
    qml/AlbumsPage.qml \
    qml/UserPage.qml \
    qml/PostDelegate.qml \
    qml/AboutPage.qml \
    qml/DevelopersPage.qml \
    qml/PhotosPage.qml \
    qml/PhotoPage.qml \
    qml/SplitSocialPanel.qml \
    qml/CommentsPage.qml \
    qml/PostCommentHeaderComponent.qml \
    qml/WelcomeDialog.qml \
    qml/SocialButtons.qml \
    qml/PostDialog.qml \
    qml/LikesPage.qml \
    qml/NotificationsPage.qml \
    qml/TypeSolverPage.qml \
    qml/ChangeLogPage.qml \
    qml/UpdatedDialog.qml \
    qml/ChangeLogView.qml \
    qml/GroupPage.qml \
    qml/GroupsPage.qml \
    qml/PagesPage.qml \
    qml/PagePage.qml \
    qml/CoverImage.qml \
    qml/ThreadsPage.qml \
    qml/EventsPage.qml \
    qml/EventPage.qml \
    qml/UserInfoPage.qml \
    qml/GroupInfoPage.qml \
    qml/UsersPage.qml \

target.path = $$TARGETPATH

desktop.path = /usr/share/applications
desktop.files = harbour-friends.desktop

icon.path = /usr/share/icons/hicolor/86x86/apps/
icon.files = harbour-friends.png

DEFINES *= DEPLOYMENT_PATH=\"\\\"\"$${DEPLOYMENT_PATH}/\"\\\"\"
qml.path = $$DEPLOYMENT_PATH/qml
qml.files = $$OTHER_FILES

INSTALLS += target desktop icon qml

CONFIG(desktop):{
RESOURCES += friends.qrc
DEFINES += DESKTOP
}

packagesExist(qdeclarative5-boostable) {
    message("Building with qdeclarative-boostable support")
    DEFINES += HAS_BOOSTER
    PKGCONFIG += qdeclarative5-boostable
} else {
   warning("qdeclarative-boostable not available; startup times will be slower")
}
