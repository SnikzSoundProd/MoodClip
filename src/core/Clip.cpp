#include "Clip.h"
#include <QUuid>
#include <QJsonValue>
#include <QJsonArray>

Clip::Clip(const QString &name, QObject *parent)
    : QObject(parent)
    , m_id(QUuid::createUuid().toString(QUuid::WithoutBraces))
    , m_name(name)
    , m_createdAt(QDateTime::currentDateTime())
{
}

QString Clip::id() const
{
    return m_id;
}

QString Clip::name() const
{
    return m_name;
}

void Clip::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}

QString Clip::script() const
{
    return m_script;
}

void Clip::setScript(const QString &script)
{
    if (m_script != script) {
        m_script = script;
        emit scriptChanged();
    }
}

int Clip::durationSeconds() const
{
    return m_durationSeconds;
}

void Clip::setDurationSeconds(int seconds)
{
    if (m_durationSeconds != seconds) {
        m_durationSeconds = seconds;
        emit durationSecondsChanged();
    }
}

QDateTime Clip::createdAt() const
{
    return m_createdAt;
}

int Clip::frameCount() const
{
    return m_frameCount;
}

void Clip::setFrameCount(int count)
{
    if (m_frameCount != count) {
        m_frameCount = count;
        emit frameCountChanged();
    }
}

QUrl Clip::moodboardData() const
{
    return m_moodboardData;
}

void Clip::setMoodboardData(const QUrl &url)
{
    if (m_moodboardData != url) {
        m_moodboardData = url;
        emit moodboardDataChanged();
    }
}

QVariantList Clip::moodboardItems() const
{
    return m_moodboardItems;
}

void Clip::setMoodboardItems(const QVariantList &items)
{
    m_moodboardItems = items;
    emit moodboardItemsChanged();
}

QJsonObject Clip::toJson() const
{
    QJsonObject obj;
    obj["id"] = m_id;
    obj["name"] = m_name;
    obj["script"] = m_script;
    obj["durationSeconds"] = m_durationSeconds;
    obj["createdAt"] = m_createdAt.toString(Qt::ISODate);
    obj["frameCount"] = m_frameCount;
    obj["moodboardData"] = m_moodboardData.toString();

    QJsonArray itemsArr;
    for (const QVariant &v : m_moodboardItems)
        itemsArr.append(QJsonObject::fromVariantMap(v.toMap()));
    obj["moodboardItems"] = itemsArr;

    return obj;
}

Clip* Clip::fromJson(const QJsonObject &json, QObject *parent)
{
    Clip *clip = new Clip(QString(), parent);
    clip->m_id = json["id"].toString(QUuid::createUuid().toString(QUuid::WithoutBraces));
    clip->m_name = json["name"].toString();
    clip->m_script = json["script"].toString();
    clip->m_durationSeconds = json["durationSeconds"].toInt(0);
    clip->m_createdAt = QDateTime::fromString(json["createdAt"].toString(), Qt::ISODate);
    clip->m_frameCount = json["frameCount"].toInt(0);
    clip->m_moodboardData = QUrl(json["moodboardData"].toString());

    QVariantList items;
    for (const QJsonValue &v : json["moodboardItems"].toArray())
        items.append(v.toObject().toVariantMap());
    clip->m_moodboardItems = items;

    return clip;
}

QString Clip::clipFolderName() const
{
    return m_id;
}
