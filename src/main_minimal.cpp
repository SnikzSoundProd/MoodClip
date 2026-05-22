#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include <QDebug>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("MoodClip");
    app.setApplicationName("MoodClip");

    qDebug() << "=== MoodClip Minimal Startup ===";

    QString appDir = QCoreApplication::applicationDirPath();
    QString qmlDir = QDir(appDir).absoluteFilePath("qml");
    QString mainQml = QDir(qmlDir).absoluteFilePath("minimal_main.qml");

    qDebug() << "App dir:" << appDir;
    qDebug() << "QML dir:" << qmlDir;
    qDebug() << "Main QML:" << mainQml;
    qDebug() << "Exists:" << QFile::exists(mainQml);

    QQmlApplicationEngine engine;
    engine.addImportPath(qmlDir);

    qDebug() << "Loading...";
    engine.load(QUrl::fromLocalFile(mainQml));

    if (engine.rootObjects().isEmpty()) {
        qDebug() << "FATAL: Failed to load QML!";
        return -1;
    }

    qDebug() << "Loaded OK!";
    return app.exec();
}
