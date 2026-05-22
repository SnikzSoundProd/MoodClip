#include "AssetItem.h"
#include <QUuid>

AssetItem::AssetItem(const QString &id, const QUrl &filePath, QObject *parent)
    : QObject(parent)
    , m_id(id.isEmpty() ? QUuid::createUuid().toString(QUuid::WithoutBraces) : id)
    , m_filePath(filePath)
    , m_createdAt(QDateTime::currentDateTime())
{
}

QString AssetItem::id() const
{
    return m_id;
}

QString AssetItem::name() const
{
    return m_name;
}

void AssetItem::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}

QUrl AssetItem::filePath() const
{
    return m_filePath;
}

QUrl AssetItem::thumbnailPath() const
{
    return m_thumbnailPath;
}

void AssetItem::setThumbnailPath(const QUrl &path)
{
    if (m_thumbnailPath != path) {
        m_thumbnailPath = path;
        emit thumbnailPathChanged();
    }
}

QStringList AssetItem::tags() const
{
    return m_tags;
}

void AssetItem::setTags(const QStringList &tags)
{
    if (m_tags != tags) {
        m_tags = tags;
        emit tagsChanged();
    }
}

QString AssetItem::category() const
{
    return m_category;
}

void AssetItem::setCategory(const QString &category)
{
    if (m_category != category) {
        m_category = category;
        emit categoryChanged();
    }
}

QString AssetItem::colorHex() const
{
    return m_colorHex;
}

void AssetItem::setColorHex(const QString &color)
{
    if (m_colorHex != color) {
        m_colorHex = color;
        emit colorHexChanged();
    }
}

QDateTime AssetItem::createdAt() const
{
    return m_createdAt;
}

int AssetItem::usageCount() const
{
    return m_usageCount;
}

void AssetItem::setUsageCount(int count)
{
    if (m_usageCount != count) {
        m_usageCount = count;
        emit usageCountChanged();
    }
}

void AssetItem::incrementUsage()
{
    m_usageCount++;
    emit usageCountChanged();
}
