#include "ExportManager.h"
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrl>

ExportManager::ExportManager(QObject *parent)
    : QObject(parent)
{
}

bool ExportManager::isExporting() const
{
    return m_isExporting;
}

QString ExportManager::lastExportPath() const
{
    return m_lastExportPath;
}

void ExportManager::exportMarkdown(Clip *clip, StoryboardModel *storyboard, const QUrl &destFolder, bool includeImages)
{
    if (!clip || !storyboard) {
        emit exportError(tr("No clip or storyboard to export"));
        return;
    }

    m_isExporting = true;
    emit isExportingChanged();

    QString folder = destFolder.toLocalFile();
    QDir().mkpath(folder);

    QString md = generateMarkdown(clip, storyboard, folder, includeImages);
    QString outPath = QDir(folder).absoluteFilePath(clip->name() + ".md");

    QFile file(outPath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream stream(&file);
        stream.setEncoding(QStringConverter::Utf8);
        stream << md;
        file.close();

        m_lastExportPath = outPath;
        emit lastExportPathChanged();
        emit exportFinished(outPath);
    } else {
        emit exportError(tr("Failed to write file: %1").arg(outPath));
    }

    m_isExporting = false;
    emit isExportingChanged();
}

void ExportManager::exportJson(Clip *clip, StoryboardModel *storyboard, const QUrl &destFolder)
{
    if (!clip || !storyboard) {
        emit exportError(tr("No clip or storyboard to export"));
        return;
    }

    m_isExporting = true;
    emit isExportingChanged();

    QString folder = destFolder.toLocalFile();
    QDir().mkpath(folder);

    QString json = generateJson(clip, storyboard);
    QString outPath = QDir(folder).absoluteFilePath(clip->name() + ".json");

    QFile file(outPath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream stream(&file);
        stream.setEncoding(QStringConverter::Utf8);
        stream << json;
        file.close();

        m_lastExportPath = outPath;
        emit lastExportPathChanged();
        emit exportFinished(outPath);
    } else {
        emit exportError(tr("Failed to write file: %1").arg(outPath));
    }

    m_isExporting = false;
    emit isExportingChanged();
}

QString ExportManager::generateMarkdown(Clip *clip, StoryboardModel *storyboard, const QString &basePath, bool includeImages)
{
    QString md;
    md += QString("# %1\n\n").arg(clip->name());
    md += QString("**Created:** %1\n\n").arg(clip->createdAt().toString(Qt::ISODate));
    md += QString("**Duration:** %1 seconds\n\n").arg(clip->durationSeconds());

    md += "## Scenario\n\n";
    md += clip->script();
    md += "\n\n";

    md += "## Storyboard\n\n";
    auto frames = storyboard->frames();
    for (int i = 0; i < frames.size(); ++i) {
        StoryboardFrame *f = frames[i];
        md += QString("### Frame %1\n\n").arg(f->frameNumber());

        if (includeImages && !f->imagePath().isEmpty()) {
            QString imgFile = f->imagePath().toLocalFile();
            QFileInfo info(imgFile);
            if (info.exists()) {
                QString destImg = QDir(basePath).absoluteFilePath(info.fileName());
                if (!QFile::exists(destImg))
                    QFile::copy(imgFile, destImg);
                md += QString("![Frame %1](%2)\n\n").arg(f->frameNumber()).arg(info.fileName());
            }
        }

        md += QString("**Description:** %1\n\n").arg(f->description());
        md += QString("**Prompt:** %1\n\n").arg(f->prompt());
        if (!f->notes().isEmpty()) {
            md += QString("**Notes:** %1\n\n").arg(f->notes());
        }
    }

    md += "---\n\n";
    md += "*Exported by MoodClip*\n";
    return md;
}

QString ExportManager::generateJson(Clip *clip, StoryboardModel *storyboard)
{
    QJsonObject root;
    root["clipName"] = clip->name();
    root["createdAt"] = clip->createdAt().toString(Qt::ISODate);
    root["durationSeconds"] = clip->durationSeconds();
    root["script"] = clip->script();
    root["frames"] = storyboard->toJsonArray();

    QJsonDocument doc(root);
    return doc.toJson(QJsonDocument::Indented);
}

void ExportManager::copyAssetImages(const QString &sourcePath, const QString &destPath)
{
    Q_UNUSED(sourcePath)
    Q_UNUSED(destPath)
    // Asset images are handled inline during markdown generation
}
