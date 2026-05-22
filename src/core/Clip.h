#ifndef CLIP_H
#define CLIP_H

#include <QObject>
#include <QJsonObject>
#include <QUrl>
#include <QDateTime>
#include <QVariantList>

class Clip : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString script READ script WRITE setScript NOTIFY scriptChanged)
    Q_PROPERTY(int durationSeconds READ durationSeconds WRITE setDurationSeconds NOTIFY durationSecondsChanged)
    Q_PROPERTY(QDateTime createdAt READ createdAt CONSTANT)
    Q_PROPERTY(int frameCount READ frameCount NOTIFY frameCountChanged)
    Q_PROPERTY(QUrl moodboardData READ moodboardData WRITE setMoodboardData NOTIFY moodboardDataChanged)
    Q_PROPERTY(QVariantList moodboardItems READ moodboardItems WRITE setMoodboardItems NOTIFY moodboardItemsChanged)

public:
    explicit Clip(const QString &name = QString(), QObject *parent = nullptr);

    QString id() const;

    QString name() const;
    void setName(const QString &name);

    QString script() const;
    void setScript(const QString &script);

    int durationSeconds() const;
    void setDurationSeconds(int seconds);

    QDateTime createdAt() const;

    int frameCount() const;
    void setFrameCount(int count);

    QUrl moodboardData() const;
    void setMoodboardData(const QUrl &url);

    QVariantList moodboardItems() const;
    void setMoodboardItems(const QVariantList &items);

    QJsonObject toJson() const;
    static Clip* fromJson(const QJsonObject &json, QObject *parent = nullptr);

    QString clipFolderName() const;

signals:
    void nameChanged();
    void scriptChanged();
    void durationSecondsChanged();
    void frameCountChanged();
    void moodboardDataChanged();
    void moodboardItemsChanged();

private:
    QString m_id;
    QString m_name;
    QString m_script;
    int m_durationSeconds = 0;
    QDateTime m_createdAt;
    int m_frameCount = 0;
    QUrl m_moodboardData;
    QVariantList m_moodboardItems;
};

#endif // CLIP_H
