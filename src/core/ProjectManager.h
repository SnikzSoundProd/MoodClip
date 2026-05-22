#ifndef PROJECTMANAGER_H
#define PROJECTMANAGER_H

#include <QObject>
#include <QUrl>
#include <QJsonObject>
#include <QList>
#include "Clip.h"

class ProjectManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString projectName READ projectName WRITE setProjectName NOTIFY projectNameChanged)
    Q_PROPERTY(QString projectPath READ projectPath NOTIFY projectPathChanged)
    Q_PROPERTY(QList<Clip*> clips READ clips NOTIFY clipsChanged)
    Q_PROPERTY(int activeClipIndex READ activeClipIndex WRITE setActiveClipIndex NOTIFY activeClipIndexChanged)
    Q_PROPERTY(bool isDarkTheme READ isDarkTheme WRITE setIsDarkTheme NOTIFY isDarkThemeChanged)
    Q_PROPERTY(bool hasUnsavedChanges READ hasUnsavedChanges NOTIFY hasUnsavedChangesChanged)

public:
    explicit ProjectManager(QObject *parent = nullptr);
    ~ProjectManager();

    QString projectName() const;
    void setProjectName(const QString &name);

    QString projectPath() const;

    QList<Clip*> clips() const;

    int activeClipIndex() const;
    void setActiveClipIndex(int index);
    Clip* activeClip() const;

    bool isDarkTheme() const;
    void setIsDarkTheme(bool dark);

    bool hasUnsavedChanges() const;

    Q_INVOKABLE void newProject(const QString &name, const QUrl &location);
    Q_INVOKABLE void openProject(const QUrl &path);
    Q_INVOKABLE void saveProject();
    Q_INVOKABLE void saveProjectAs(const QUrl &path, bool asArchive);
    Q_INVOKABLE void closeProject();

    Q_INVOKABLE void addClip();
    Q_INVOKABLE void removeClip(int index);
    Q_INVOKABLE void duplicateClip(int index);
    Q_INVOKABLE void moveClip(int from, int to);

    Q_INVOKABLE void markUnsaved();

signals:
    void projectNameChanged();
    void projectPathChanged();
    void clipsChanged();
    void activeClipIndexChanged();
    void activeClipChanged();
    void isDarkThemeChanged();
    void hasUnsavedChangesChanged();
    void aboutToSave();
    void projectLoaded();
    void projectClosed();
    void error(const QString &message);

private:
    void saveToFolder(const QString &path);
    void saveToArchive(const QString &path);
    void loadFromFolder(const QString &path);
    void loadFromArchive(const QString &path);
    void writeProjectJson(const QString &path);
    void readProjectJson(const QString &path);

    QString m_projectName;
    QString m_projectPath;
    QList<Clip*> m_clips;
    int m_activeClipIndex = -1;
    bool m_isDarkTheme = false;
    bool m_hasUnsavedChanges = false;
};

#endif // PROJECTMANAGER_H
