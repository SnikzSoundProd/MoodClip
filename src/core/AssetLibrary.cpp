#include "AssetLibrary.h"
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QUuid>
#include <QImage>
#include <QStandardPaths>

AssetLibrary::AssetLibrary(QObject *parent)
    : QAbstractListModel(parent)
{
}

AssetLibrary::~AssetLibrary()
{
    if (m_db.isOpen())
        m_db.close();
    for (auto *asset : m_assets)
        asset->deleteLater();
}

int AssetLibrary::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_assets.size();
}

QVariant AssetLibrary::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_assets.size())
        return QVariant();

    AssetItem *item = m_assets[index.row()];
    switch (role) {
    case IdRole:
        return item->id();
    case NameRole:
        return item->name();
    case FilePathRole:
        return item->filePath().toString();
    case ThumbnailPathRole:
        return item->thumbnailPath().toString();
    case TagsRole:
        return item->tags();
    case CategoryRole:
        return item->category();
    case ColorRole:
        return item->colorHex();
    case UsageCountRole:
        return item->usageCount();
    }
    return QVariant();
}

QHash<int, QByteArray> AssetLibrary::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "assetId";
    roles[NameRole] = "assetName";
    roles[FilePathRole] = "filePath";
    roles[ThumbnailPathRole] = "thumbnailPath";
    roles[TagsRole] = "tags";
    roles[CategoryRole] = "category";
    roles[ColorRole] = "colorHex";
    roles[UsageCountRole] = "usageCount";
    return roles;
}

QStringList AssetLibrary::allTags() const
{
    return extractTags();
}

QStringList AssetLibrary::allCategories() const
{
    return extractCategories();
}

QString AssetLibrary::searchQuery() const
{
    return m_searchQuery;
}

void AssetLibrary::setSearchQuery(const QString &query)
{
    if (m_searchQuery != query) {
        m_searchQuery = query;
        emit searchQueryChanged();
        refresh();
    }
}

QString AssetLibrary::filterTag() const
{
    return m_filterTag;
}

void AssetLibrary::setFilterTag(const QString &tag)
{
    if (m_filterTag != tag) {
        m_filterTag = tag;
        emit filterTagChanged();
        refresh();
    }
}

QString AssetLibrary::filterCategory() const
{
    return m_filterCategory;
}

void AssetLibrary::setFilterCategory(const QString &category)
{
    if (m_filterCategory != category) {
        m_filterCategory = category;
        emit filterCategoryChanged();
        refresh();
    }
}

void AssetLibrary::initDatabase(const QUrl &projectPath)
{
    if (m_db.isOpen())
        m_db.close();

    QDir dir(projectPath.toLocalFile());
    m_dbPath = dir.absoluteFilePath("assets/library.db");
    m_thumbsPath = dir.absoluteFilePath("assets/thumbs");
    m_filesPath = dir.absoluteFilePath("assets/files");
    QDir().mkpath(m_thumbsPath);
    QDir().mkpath(m_filesPath);

    m_db = QSqlDatabase::addDatabase("QSQLITE", "moodclip_assets");
    m_db.setDatabaseName(m_dbPath);

    if (!m_db.open()) {
        emit error(tr("Failed to open asset database: %1").arg(m_db.lastError().text()));
        return;
    }

    createTables();
    loadAssets();
}

void AssetLibrary::createTables()
{
    QSqlQuery query(m_db);
    query.exec("CREATE TABLE IF NOT EXISTS assets ("
               "id TEXT PRIMARY KEY,"
               "name TEXT,"
               "file_path TEXT,"
               "thumbnail_path TEXT,"
               "tags TEXT,"
               "category TEXT,"
               "color_hex TEXT,"
               "created_at TEXT,"
               "usage_count INTEGER DEFAULT 0"
               ")");
}

void AssetLibrary::loadAssets()
{
    beginResetModel();
    for (auto *a : m_assets)
        a->deleteLater();
    m_assets.clear();

    QSqlQuery query(m_db);
    QString sql = "SELECT * FROM assets WHERE 1=1";
    if (!m_filterCategory.isEmpty())
        sql += " AND category = :category";
    if (!m_searchQuery.isEmpty())
        sql += " AND name LIKE :search";
    if (!m_filterTag.isEmpty())
        sql += " AND tags LIKE :tag";
    sql += " ORDER BY created_at DESC";

    query.prepare(sql);
    if (!m_filterCategory.isEmpty())
        query.bindValue(":category", m_filterCategory);
    if (!m_searchQuery.isEmpty())
        query.bindValue(":search", "%" + m_searchQuery + "%");
    if (!m_filterTag.isEmpty())
        query.bindValue(":tag", "%" + m_filterTag + "%");

    if (query.exec()) {
        while (query.next()) {
            AssetItem *item = new AssetItem(query.value("id").toString(),
                                            QUrl::fromLocalFile(query.value("file_path").toString()),
                                            this);
            item->setName(query.value("name").toString());
            item->setThumbnailPath(QUrl::fromLocalFile(query.value("thumbnail_path").toString()));
            item->setTags(query.value("tags").toString().split(",", Qt::SkipEmptyParts));
            item->setCategory(query.value("category").toString());
            item->setColorHex(query.value("color_hex").toString());
            item->setUsageCount(query.value("usage_count").toInt());
            m_assets.append(item);
        }
    }
    endResetModel();
    emit allTagsChanged();
    emit allCategoriesChanged();
}

void AssetLibrary::importAsset(const QUrl &filePath, const QString &name, const QString &category, const QStringList &tags, const QString &colorHex)
{
    QString source = filePath.toLocalFile();
    QFileInfo info(source);
    if (!info.exists()) {
        emit error(tr("File does not exist: %1").arg(source));
        return;
    }

    QString id = QUuid::createUuid().toString(QUuid::WithoutBraces);
    QString ext = info.suffix();
    QString destFile = QDir(m_filesPath).absoluteFilePath(id + "." + ext);
    QString thumbFile = generateThumbnail(source, m_thumbsPath);

    if (!QFile::copy(source, destFile)) {
        emit error(tr("Failed to copy file to assets"));
        return;
    }

    QSqlQuery query(m_db);
    query.prepare("INSERT INTO assets (id, name, file_path, thumbnail_path, tags, category, color_hex, created_at, usage_count) "
                  "VALUES (:id, :name, :file_path, :thumb, :tags, :category, :color, :created, 0)");
    query.bindValue(":id", id);
    query.bindValue(":name", name.isEmpty() ? info.baseName() : name);
    query.bindValue(":file_path", destFile);
    query.bindValue(":thumb", thumbFile);
    query.bindValue(":tags", tags.join(","));
    query.bindValue(":category", category);
    query.bindValue(":color", colorHex);
    query.bindValue(":created", QDateTime::currentDateTime().toString(Qt::ISODate));

    if (!query.exec()) {
        emit error(tr("Database error: %1").arg(query.lastError().text()));
        return;
    }

    AssetItem *item = new AssetItem(id, QUrl::fromLocalFile(destFile), this);
    item->setName(name.isEmpty() ? info.baseName() : name);
    item->setThumbnailPath(QUrl::fromLocalFile(thumbFile));
    item->setTags(tags);
    item->setCategory(category);
    item->setColorHex(colorHex);

    beginInsertRows(QModelIndex(), m_assets.size(), m_assets.size());
    m_assets.append(item);
    endInsertRows();

    emit allTagsChanged();
    emit allCategoriesChanged();
    emit assetImported(id);
}

void AssetLibrary::deleteAsset(const QString &id)
{
    int idx = -1;
    for (int i = 0; i < m_assets.size(); ++i) {
        if (m_assets[i]->id() == id) {
            idx = i;
            break;
        }
    }
    if (idx < 0) return;

    QSqlQuery query(m_db);
    query.prepare("DELETE FROM assets WHERE id = :id");
    query.bindValue(":id", id);
    query.exec();

    beginRemoveRows(QModelIndex(), idx, idx);
    AssetItem *item = m_assets.takeAt(idx);
    QFile::remove(item->filePath().toLocalFile());
    QFile::remove(item->thumbnailPath().toLocalFile());
    item->deleteLater();
    endRemoveRows();

    emit allTagsChanged();
    emit allCategoriesChanged();
    emit assetDeleted(id);
}

void AssetLibrary::updateAssetTags(const QString &id, const QStringList &tags)
{
    QSqlQuery query(m_db);
    query.prepare("UPDATE assets SET tags = :tags WHERE id = :id");
    query.bindValue(":tags", tags.join(","));
    query.bindValue(":id", id);
    query.exec();
    refresh();
}

void AssetLibrary::updateAssetCategory(const QString &id, const QString &category)
{
    QSqlQuery query(m_db);
    query.prepare("UPDATE assets SET category = :category WHERE id = :id");
    query.bindValue(":category", category);
    query.bindValue(":id", id);
    query.exec();
    refresh();
}

void AssetLibrary::updateAssetName(const QString &id, const QString &name)
{
    QSqlQuery query(m_db);
    query.prepare("UPDATE assets SET name = :name WHERE id = :id");
    query.bindValue(":name", name);
    query.bindValue(":id", id);
    query.exec();
    refresh();
}

void AssetLibrary::incrementAssetUsage(const QString &id)
{
    QSqlQuery query(m_db);
    query.prepare("UPDATE assets SET usage_count = usage_count + 1 WHERE id = :id");
    query.bindValue(":id", id);
    query.exec();
    refresh();
}

QStringList AssetLibrary::getAssetTags(const QString &id) const
{
    for (auto *a : m_assets) {
        if (a->id() == id)
            return a->tags();
    }
    return QStringList();
}

void AssetLibrary::addCategory(const QString &category)
{
    Q_UNUSED(category)
    // Categories are implicitly managed through asset records
}

void AssetLibrary::removeCategory(const QString &category)
{
    QSqlQuery query(m_db);
    query.prepare("UPDATE assets SET category = '' WHERE category = :category");
    query.bindValue(":category", category);
    query.exec();
    refresh();
}

void AssetLibrary::renameCategory(const QString &oldName, const QString &newName)
{
    QSqlQuery query(m_db);
    query.prepare("UPDATE assets SET category = :new WHERE category = :old");
    query.bindValue(":new", newName);
    query.bindValue(":old", oldName);
    query.exec();
    refresh();
}

void AssetLibrary::refresh()
{
    loadAssets();
}

QString AssetLibrary::generateThumbnail(const QUrl &source, const QString &destFolder)
{
    QImage img(source.toLocalFile());
    if (img.isNull())
        return QString();

    QImage thumb = img.scaled(200, 200, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    QString dest = QDir(destFolder).absoluteFilePath(QUuid::createUuid().toString(QUuid::WithoutBraces) + ".png");
    thumb.save(dest, "PNG");
    return dest;
}

QStringList AssetLibrary::extractTags() const
{
    QSet<QString> tags;
    for (auto *a : m_assets) {
        for (const QString &t : a->tags())
            tags.insert(t.trimmed());
    }
    return QStringList(tags.values());
}

QStringList AssetLibrary::extractCategories() const
{
    QSet<QString> cats;
    for (auto *a : m_assets) {
        if (!a->category().isEmpty())
            cats.insert(a->category());
    }
    cats.insert(tr("Colors"));
    cats.insert(tr("Textures"));
    cats.insert(tr("Characters"));
    cats.insert(tr("Locations"));
    cats.insert(tr("Composition"));
    cats.insert(tr("References"));
    return QStringList(cats.values());
}
