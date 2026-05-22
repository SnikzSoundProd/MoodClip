#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QDir>
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QQuickStyle>

#include "core/ProjectManager.h"
#include "core/StoryboardModel.h"
#include "core/AssetLibrary.h"
#include "core/ExportManager.h"

static void logMsg(const QString &msg) {
    QFile f(QCoreApplication::applicationDirPath() + "/startup.log");
    if (f.open(QIODevice::Append | QIODevice::Text)) {
        QTextStream ts(&f);
        ts << msg << "\n";
    }
    qDebug() << msg;
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("MoodClip");
    app.setApplicationName("MoodClip");
    QQuickStyle::setStyle("Basic");
    logMsg("=== MoodClip Startup (file log) ===");
    logMsg("QGuiApplication created OK");

    QString appDir = QCoreApplication::applicationDirPath();
    QString qmlDir = QDir(appDir).absoluteFilePath("qml");
    logMsg("App dir: " + appDir);
    logMsg("QML dir: " + qmlDir);

    if (!QDir(qmlDir).exists()) {
        logMsg("FATAL: QML directory not found!");
        return -1;
    }

    QString mainQml = QDir(qmlDir).absoluteFilePath("main.qml");
    logMsg("Main QML: " + mainQml);
    if (!QFile::exists(mainQml)) {
        logMsg("FATAL: main.qml not found!");
        return -1;
    }

    QString themeQml = QDir(qmlDir).absoluteFilePath("Theme.qml");
    logMsg("Theme QML: " + themeQml);
    QString iconsQml = QDir(qmlDir).absoluteFilePath("Icons.qml");
    logMsg("Icons QML: " + iconsQml);

    logMsg("Creating QQmlApplicationEngine...");
    QQmlApplicationEngine engine;
    engine.addImportPath(qmlDir);
    // Add Qt QML module paths
    engine.addImportPath("qrc:/qt-project.org/imports");
    engine.addImportPath("qrc:/qt/qml");
    // MSYS2 ucrt64 QML modules are in share/qt6/qml
    QString msysQmlPath = "C:/msys64/ucrt64/share/qt6/qml";
    if (QDir(msysQmlPath).exists()) {
        engine.addImportPath(msysQmlPath);
        logMsg("Added MSYS2 QML import: " + msysQmlPath);
    }
    logMsg("Import paths: " + engine.importPathList().join(", "));
    logMsg("Plugin paths: " + engine.pluginPathList().join(", "));
    logMsg("Engine created");

    // Load Theme as context property
    if (QFile::exists(themeQml)) {
        logMsg("Loading Theme.qml...");
        QQmlComponent themeComp(&engine, QUrl::fromLocalFile(themeQml));
        logMsg("Theme component status: " + QString::number((int)themeComp.status()));
        if (themeComp.status() == QQmlComponent::Ready) {
            QObject *theme = themeComp.create();
            if (theme) {
                engine.rootContext()->setContextProperty("Theme", theme);
                logMsg("Theme loaded OK");

                // Load Icons as context property too
                if (QFile::exists(iconsQml)) {
                    QQmlComponent iconsComp(&engine, QUrl::fromLocalFile(iconsQml));
                    if (iconsComp.status() == QQmlComponent::Ready) {
                        QObject *icons = iconsComp.create();
                        if (icons) {
                            engine.rootContext()->setContextProperty("Icons", icons);
                            logMsg("Icons loaded OK");
                        }
                    }
                }

                logMsg("Creating C++ models...");
                ProjectManager projectManager;
                logMsg("ProjectManager created");
                StoryboardModel storyboardModel;
                logMsg("StoryboardModel created");
                AssetLibrary assetLibrary;
                logMsg("AssetLibrary created");
                ExportManager exportManager;
                logMsg("ExportManager created");

                // Sync Theme.darkMode with projectManager.isDarkTheme via C++
                // This is reliable vs QML Binding which can fail on externally-created QObjects
                auto syncTheme = [theme, &projectManager]() {
                    theme->setProperty("darkMode", projectManager.isDarkTheme());
                };
                QObject::connect(&projectManager, &ProjectManager::isDarkThemeChanged, syncTheme);
                syncTheme(); // set initial value

                QObject::connect(&projectManager, &ProjectManager::activeClipChanged, [&]() {
                    storyboardModel.loadFrames(projectManager.activeClip());
                });

                engine.rootContext()->setContextProperty("projectManager", &projectManager);
                engine.rootContext()->setContextProperty("storyboardModel", &storyboardModel);
                engine.rootContext()->setContextProperty("assetLibrary", &assetLibrary);
                engine.rootContext()->setContextProperty("exportManager", &exportManager);
                logMsg("Context properties set");

                logMsg("Loading QML...");
                QQmlComponent mainComp(&engine, QUrl::fromLocalFile(mainQml));
                if (mainComp.status() == QQmlComponent::Ready) {
                    QObject *rootObj = mainComp.create();
                    if (rootObj) {
                        logMsg("Main QML loaded successfully as component");
                        logMsg("Root object type: " + QString(rootObj->metaObject()->className()));
                    } else {
                        logMsg("FATAL: Component create failed: " + mainComp.errorString());
                        return -1;
                    }
                } else {
                    logMsg("FATAL: Component status " + QString::number((int)mainComp.status()) + " error: " + mainComp.errorString());
                    return -1;
                }

                logMsg("=== Startup complete, entering event loop ===");
                return app.exec();

            } else {
                logMsg("WARN: Theme create failed: " + themeComp.errorString());
            }
        } else {
            logMsg("WARN: Theme component error: " + themeComp.errorString());
        }
    } else {
        logMsg("WARN: Theme.qml not found");
    }

    logMsg("FATAL: Theme could not be loaded, cannot continue");
    return -1;
}
