#ifndef ASSETITEM_H
#define ASSETITEM_H

#include <QObject>
#include <QUrl>
#include <QStringList>
#include <QDateTime>

class AssetItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QUrl filePath READ filePath CONSTANT)
    Q_PROPERTY(QUrl thumbnailPath READ thumbnailPath WRITE setThumbnailPath NOTIFY thumbnailPathChanged)
    Q_PROPERTY(QStringList tags READ tags WRITE setTags NOTIFY tagsChanged)
    Q_PROPERTY(QString category READ category WRITE setCategory NOTIFY categoryChanged)
    Q_PROPERTY(QString colorHex READ colorHex WRITE setColorHex NOTIFY colorHexChanged)
    Q_PROPERTY(QDateTime createdAt READ createdAt CONSTANT)
    Q_PROPERTY(int usageCount READ usageCount WRITE setUsageCount NOTIFY usageCountChanged)

public:
    explicit AssetItem(const QString &id, const QUrl &filePath, QObject *parent = nullptr);

    QString id() const;
    QString name() const;
    void setName(const QString &name);
    QUrl filePath() const;
    QUrl thumbnailPath() const;
    void setThumbnailPath(const QUrl &path);
    QStringList tags() const;
    void setTags(const QStringList &tags);
    QString category() const;
    void setCategory(const QString &category);
    QString colorHex() const;
    void setColorHex(const QString &color);
    QDateTime createdAt() const;
    int usageCount() const;
    void setUsageCount(int count);

    void incrementUsage();

signals:
    void nameChanged();
    void thumbnailPathChanged();
    void tagsChanged();
    void categoryChanged();
    void colorHexChanged();
    void usageCountChanged();

private:
    QString m_id;
    QString m_name;
    QUrl m_filePath;
    QUrl m_thumbnailPath;
    QStringList m_tags;
    QString m_category;
    QString m_colorHex;
    QDateTime m_createdAt;
    int m_usageCount = 0;
};

#endif // ASSETITEM_H
