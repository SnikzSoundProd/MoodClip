#include "ProjectManager.h"
#include <QDir>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>
#include <QDateTime>
#include <QUrl>
#include <QSaveFile>
#include <QUuid>

ProjectManager::ProjectManager(QObject *parent)
    : QObject(parent)
{
}

ProjectManager::~ProjectManager()
{
    for (auto *clip : m_clips)
        clip->deleteLater();
}

QString ProjectManager::projectName() const
{
    return m_projectName;
}

void ProjectManager::setProjectName(const QString &name)
{
    if (m_projectName != name) {
        m_projectName = name;
        emit projectNameChanged();
        markUnsaved();
    }
}

QString ProjectManager::projectPath() const
{
    return m_projectPath;
}

QList<Clip*> ProjectManager::clips() const
{
    return m_clips;
}

int ProjectManager::activeClipIndex() const
{
    return m_activeClipIndex;
}

void ProjectManager::setActiveClipIndex(int index)
{
    if (m_activeClipIndex != index && index >= -1 && index < m_clips.size()) {
        m_activeClipIndex = index;
        emit activeClipIndexChanged();
        emit activeClipChanged();
    }
}

Clip* ProjectManager::activeClip() const
{
    if (m_activeClipIndex >= 0 && m_activeClipIndex < m_clips.size())
        return m_clips[m_activeClipIndex];
    return nullptr;
}

bool ProjectManager::isDarkTheme() const
{
    return m_isDarkTheme;
}

void ProjectManager::setIsDarkTheme(bool dark)
{
    if (m_isDarkTheme != dark) {
        m_isDarkTheme = dark;
        emit isDarkThemeChanged();
        markUnsaved();
    }
}

bool ProjectManager::hasUnsavedChanges() const
{
    return m_hasUnsavedChanges;
}

void ProjectManager::markUnsaved()
{
    m_hasUnsavedChanges = true;
    emit hasUnsavedChangesChanged();
}

void ProjectManager::newProject(const QString &name, const QUrl &location)
{
    closeProject();

    m_projectName = name;
    m_projectPath = location.toLocalFile();
    m_isDarkTheme = false;
    m_hasUnsavedChanges = true;

    QDir projectDir(m_projectPath);
    projectDir.mkpath("clips");
    projectDir.mkpath("assets/files");
    projectDir.mkpath("assets/thumbs");

    addClip();
    setActiveClipIndex(0);

    emit projectNameChanged();
    emit projectPathChanged();
    emit clipsChanged();
    emit activeClipIndexChanged();
    emit activeClipChanged();
    emit isDarkThemeChanged();
    emit hasUnsavedChangesChanged();
    emit projectLoaded();
}

void ProjectManager::openProject(const QUrl &path)
{
    QString filePath = path.toLocalFile();
    QFileInfo info(filePath);

    if (!info.exists()) {
        emit error(tr("Project path does not exist"));
        return;
    }

    closeProject();

    if (info.suffix().toLower() == "moodclip") {
        loadFromArchive(filePath);
    } else {
        loadFromFolder(filePath);
    }
}

void ProjectManager::saveProject()
{
    emit aboutToSave();

    if (m_projectPath.isEmpty()) {
        emit error(tr("No project path set. Use Save As."));
        return;
    }

    if (m_projectPath.endsWith(".moodclip", Qt::CaseInsensitive)) {
        saveToArchive(m_projectPath);
    } else {
        saveToFolder(m_projectPath);
    }

    m_hasUnsavedChanges = false;
    emit hasUnsavedChangesChanged();
}

void ProjectManager::saveProjectAs(const QUrl &path, bool asArchive)
{
    QString dest = path.toLocalFile();

    if (asArchive) {
        if (!dest.endsWith(".moodclip", Qt::CaseInsensitive))
            dest += ".moodclip";
        saveToArchive(dest);
    } else {
        saveToFolder(dest);
    }

    m_projectPath = dest;
    emit projectPathChanged();

    m_hasUnsavedChanges = false;
    emit hasUnsavedChangesChanged();
}

void ProjectManager::closeProject()
{
    for (auto *clip : m_clips)
        clip->deleteLater();
    m_clips.clear();
    m_activeClipIndex = -1;
    m_projectName.clear();
    m_projectPath.clear();
    m_hasUnsavedChanges = false;

    emit projectClosed();
    emit clipsChanged();
    emit activeClipIndexChanged();
    emit activeClipChanged();
    emit projectNameChanged();
    emit projectPathChanged();
    emit hasUnsavedChangesChanged();
}

void ProjectManager::addClip()
{
    QString clipName = tr("Clip %1").arg(m_clips.size() + 1);
    Clip *clip = new Clip(clipName, this);
    m_clips.append(clip);
    emit clipsChanged();
    markUnsaved();

    if (m_activeClipIndex < 0) {
        setActiveClipIndex(0);
    }
}

void ProjectManager::removeClip(int index)
{
    if (index < 0 || index >= m_clips.size())
        return;

    Clip *clip = m_clips.takeAt(index);
    clip->deleteLater();

    emit clipsChanged();
    markUnsaved();

    if (m_activeClipIndex >= m_clips.size()) {
        setActiveClipIndex(m_clips.size() - 1);
    } else {
        emit activeClipChanged();
    }
}

void ProjectManager::duplicateClip(int index)
{
    if (index < 0 || index >= m_clips.size())
        return;

    Clip *original = m_clips[index];
    Clip *copy = new Clip(original->name() + tr(" (Copy)"), this);
    copy->setScript(original->script());
    copy->setDurationSeconds(original->durationSeconds());
    copy->setMoodboardData(original->moodboardData());

    m_clips.insert(index + 1, copy);
    emit clipsChanged();
    markUnsaved();
}

void ProjectManager::moveClip(int from, int to)
{
    if (from < 0 || from >= m_clips.size() || to < 0 || to >= m_clips.size())
        return;

    m_clips.move(from, to);
    emit clipsChanged();
    markUnsaved();
}

void ProjectManager::saveToFolder(const QString &path)
{
    QDir dir(path);
    dir.mkpath("clips");
    dir.mkpath("assets/files");
    dir.mkpath("assets/thumbs");

    writeProjectJson(path);

    for (auto *clip : m_clips) {
        QString clipDir = dir.absoluteFilePath("clips/" + clip->clipFolderName());
        QDir().mkpath(clipDir);

        QJsonObject clipJson = clip->toJson();
        QString clipFile = QDir(clipDir).absoluteFilePath("clip.json");
        QSaveFile file(clipFile);
        if (file.open(QIODevice::WriteOnly)) {
            file.write(QJsonDocument(clipJson).toJson(QJsonDocument::Indented));
            file.commit();
        }
    }
}

void ProjectManager::saveToArchive(const QString &path)
{
    // .moodclip is a zip archive — simplified: save to temp then zip
    // For now fallback to folder + note
    QString tempDir = QStandardPaths::writableLocation(QStandardPaths::TempLocation)
                      + "/moodclip_" + QUuid::createUuid().toString(QUuid::WithoutBraces);
    saveToFolder(tempDir);
    // TODO: compress tempDir to path as zip
    Q_UNUSED(path)
    emit error(tr("Archive saving requires zlib/zip implementation (TODO). Saved to folder fallback."));
}

void ProjectManager::loadFromFolder(const QString &path)
{
    readProjectJson(path);

    QDir dir(path);
    QDir clipsDir(dir.absoluteFilePath("clips"));
    QStringList clipFolders = clipsDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);

    for (const QString &folder : clipFolders) {
        QString clipFile = clipsDir.absoluteFilePath(folder + "/clip.json");
        QFile file(clipFile);
        if (!file.open(QIODevice::ReadOnly))
            continue;

        QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
        Clip *clip = Clip::fromJson(doc.object(), this);
        if (clip) {
            m_clips.append(clip);
        }
    }

    if (!m_clips.isEmpty()) {
        setActiveClipIndex(0);
    }

    m_hasUnsavedChanges = false;
    emit clipsChanged();
    emit activeClipIndexChanged();
    emit activeClipChanged();
    emit projectNameChanged();
    emit projectPathChanged();
    emit isDarkThemeChanged();
    emit hasUnsavedChangesChanged();
    emit projectLoaded();
}

void ProjectManager::loadFromArchive(const QString &path)
{
    Q_UNUSED(path)
    // TODO: decompress zip to temp, then loadFromFolder
    emit error(tr("Archive loading requires zlib/zip implementation (TODO)."));
}

void ProjectManager::writeProjectJson(const QString &path)
{
    QJsonObject root;
    root["name"] = m_projectName;
    root["version"] = "1.0";
    root["theme"] = m_isDarkTheme ? "dark" : "light";
    root["created"] = QDateTime::currentDateTime().toString(Qt::ISODate);

    QJsonArray clipsArray;
    for (auto *clip : m_clips) {
        clipsArray.append(clip->id());
    }
    root["clips"] = clipsArray;
    root["activeClip"] = m_activeClipIndex;

    QString projectFile = QDir(path).absoluteFilePath("project.json");
    QSaveFile file(projectFile);
    if (file.open(QIODevice::WriteOnly)) {
        file.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
        file.commit();
    }
}

void ProjectManager::readProjectJson(const QString &path)
{
    QString projectFile = QDir(path).absoluteFilePath("project.json");
    QFile file(projectFile);
    if (!file.open(QIODevice::ReadOnly))
        return;

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    QJsonObject root = doc.object();

    m_projectName = root["name"].toString();
    m_isDarkTheme = (root["theme"].toString() == "dark");
    m_activeClipIndex = root["activeClip"].toInt(-1);
}
