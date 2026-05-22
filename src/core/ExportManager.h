#ifndef EXPORTMANAGER_H
#define EXPORTMANAGER_H

#include <QObject>
#include <QUrl>
#include "Clip.h"
#include "StoryboardModel.h"

class ExportManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isExporting READ isExporting NOTIFY isExportingChanged)
    Q_PROPERTY(QString lastExportPath READ lastExportPath NOTIFY lastExportPathChanged)

public:
    explicit ExportManager(QObject *parent = nullptr);

    bool isExporting() const;
    QString lastExportPath() const;

    Q_INVOKABLE void exportMarkdown(Clip *clip, StoryboardModel *storyboard, const QUrl &destFolder, bool includeImages);
    Q_INVOKABLE void exportJson(Clip *clip, StoryboardModel *storyboard, const QUrl &destFolder);

signals:
    void isExportingChanged();
    void lastExportPathChanged();
    void exportFinished(const QString &path);
    void exportError(const QString &message);

private:
    QString generateMarkdown(Clip *clip, StoryboardModel *storyboard, const QString &basePath, bool includeImages);
    QString generateJson(Clip *clip, StoryboardModel *storyboard);
    void copyAssetImages(const QString &sourcePath, const QString &destPath);

    bool m_isExporting = false;
    QString m_lastExportPath;
};

#endif // EXPORTMANAGER_H
