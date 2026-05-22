#include "StoryboardFrame.h"
#include <QJsonValue>

StoryboardFrame::StoryboardFrame(QObject *parent)
    : QObject(parent)
{
}

int StoryboardFrame::frameNumber() const
{
    return m_frameNumber;
}

void StoryboardFrame::setFrameNumber(int number)
{
    if (m_frameNumber != number) {
        m_frameNumber = number;
        emit frameNumberChanged();
    }
}

QString StoryboardFrame::description() const
{
    return m_description;
}

void StoryboardFrame::setDescription(const QString &desc)
{
    if (m_description != desc) {
        m_description = desc;
        emit descriptionChanged();
    }
}

QString StoryboardFrame::prompt() const
{
    return m_prompt;
}

void StoryboardFrame::setPrompt(const QString &prompt)
{
    if (m_prompt != prompt) {
        m_prompt = prompt;
        emit promptChanged();
    }
}

QUrl StoryboardFrame::imagePath() const
{
    return m_imagePath;
}

void StoryboardFrame::setImagePath(const QUrl &path)
{
    if (m_imagePath != path) {
        m_imagePath = path;
        emit imagePathChanged();
    }
}

QString StoryboardFrame::notes() const
{
    return m_notes;
}

void StoryboardFrame::setNotes(const QString &notes)
{
    if (m_notes != notes) {
        m_notes = notes;
        emit notesChanged();
    }
}

QJsonObject StoryboardFrame::toJson() const
{
    QJsonObject obj;
    obj["frameNumber"] = m_frameNumber;
    obj["description"] = m_description;
    obj["prompt"] = m_prompt;
    obj["imagePath"] = m_imagePath.toString();
    obj["notes"] = m_notes;
    return obj;
}

StoryboardFrame* StoryboardFrame::fromJson(const QJsonObject &json, QObject *parent)
{
    StoryboardFrame *frame = new StoryboardFrame(parent);
    frame->m_frameNumber = json["frameNumber"].toInt(1);
    frame->m_description = json["description"].toString();
    frame->m_prompt = json["prompt"].toString();
    frame->m_imagePath = QUrl(json["imagePath"].toString());
    frame->m_notes = json["notes"].toString();
    return frame;
}
