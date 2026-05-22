#ifndef ASSETLIBRARY_H
#define ASSETLIBRARY_H

#include <QAbstractListModel>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QUrl>
#include <QList>
#include "AssetItem.h"

class AssetLibrary : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QStringList allTags READ allTags NOTIFY allTagsChanged)
    Q_PROPERTY(QStringList allCategories READ allCategories NOTIFY allCategoriesChanged)
    Q_PROPERTY(QString searchQuery READ searchQuery WRITE setSearchQuery NOTIFY searchQueryChanged)
    Q_PROPERTY(QString filterTag READ filterTag WRITE setFilterTag NOTIFY filterTagChanged)
    Q_PROPERTY(QString filterCategory READ filterCategory WRITE setFilterCategory NOTIFY filterCategoryChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        FilePathRole,
        ThumbnailPathRole,
        TagsRole,
        CategoryRole,
        ColorRole,
        UsageCountRole
    };

    explicit AssetLibrary(QObject *parent = nullptr);
    ~AssetLibrary();

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    QStringList allTags() const;
    QStringList allCategories() const;

    QString searchQuery() const;
    void setSearchQuery(const QString &query);

    QString filterTag() const;
    void setFilterTag(const QString &tag);

    QString filterCategory() const;
    void setFilterCategory(const QString &category);

    Q_INVOKABLE void initDatabase(const QUrl &projectPath);
    Q_INVOKABLE void importAsset(const QUrl &filePath, const QString &name, const QString &category, const QStringList &tags, const QString &colorHex);
    Q_INVOKABLE void deleteAsset(const QString &id);
    Q_INVOKABLE void updateAssetTags(const QString &id, const QStringList &tags);
    Q_INVOKABLE void updateAssetCategory(const QString &id, const QString &category);
    Q_INVOKABLE void updateAssetName(const QString &id, const QString &name);
    Q_INVOKABLE void incrementAssetUsage(const QString &id);
    Q_INVOKABLE QStringList getAssetTags(const QString &id) const;

    Q_INVOKABLE void addCategory(const QString &category);
    Q_INVOKABLE void removeCategory(const QString &category);
    Q_INVOKABLE void renameCategory(const QString &oldName, const QString &newName);

    Q_INVOKABLE void refresh();

signals:
    void allTagsChanged();
    void allCategoriesChanged();
    void searchQueryChanged();
    void filterTagChanged();
    void filterCategoryChanged();
    void assetImported(const QString &id);
    void assetDeleted(const QString &id);
    void error(const QString &message);

private:
    void createTables();
    void loadAssets();
    QString generateThumbnail(const QUrl &source, const QString &destFolder);
    QStringList extractTags() const;
    QStringList extractCategories() const;

    QList<AssetItem*> m_assets;
    QSqlDatabase m_db;
    QString m_dbPath;
    QString m_thumbsPath;
    QString m_filesPath;
    QString m_searchQuery;
    QString m_filterTag;
    QString m_filterCategory;
};

#endif // ASSETLIBRARY_H
