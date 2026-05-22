#include "StoryboardModel.h"
#include <QJsonArray>
#include <QJsonObject>
#include <QFile>
#include <QDir>
#include <QJsonDocument>

StoryboardModel::StoryboardModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int StoryboardModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_frames.size();
}

QVariant StoryboardModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_frames.size())
        return QVariant();

    StoryboardFrame *frame = m_frames[index.row()];
    switch (role) {
    case FrameNumberRole:
        return frame->frameNumber();
    case DescriptionRole:
        return frame->description();
    case PromptRole:
        return frame->prompt();
    case ImagePathRole:
        return frame->imagePath();
    case NotesRole:
        return frame->notes();
    }
    return QVariant();
}

QHash<int, QByteArray> StoryboardModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[FrameNumberRole] = "frameNumber";
    roles[DescriptionRole] = "description";
    roles[PromptRole] = "prompt";
    roles[ImagePathRole] = "imagePath";
    roles[NotesRole] = "notes";
    return roles;
}

int StoryboardModel::totalFrames() const
{
    return m_frames.size();
}

int StoryboardModel::currentFrameIndex() const
{
    return m_currentFrameIndex;
}

void StoryboardModel::setCurrentFrameIndex(int index)
{
    if (m_currentFrameIndex != index && index >= 0 && index < m_frames.size()) {
        m_currentFrameIndex = index;
        emit currentFrameIndexChanged();
    }
}

void StoryboardModel::loadFrames(Clip *clip)
{
    beginResetModel();
    for (auto *f : m_frames)
        f->deleteLater();
    m_frames.clear();

    if (clip) {
        int count = clip->frameCount();
        if (count <= 0) count = 1;
        for (int i = 0; i < count; ++i) {
            StoryboardFrame *frame = new StoryboardFrame(this);
            frame->setFrameNumber(i + 1);
            m_frames.append(frame);
        }
    }
    endResetModel();
    renumberFrames();
    emit totalFramesChanged();

    if (!m_frames.isEmpty()) {
        m_currentFrameIndex = 0;
        emit currentFrameIndexChanged();
    }
}

void StoryboardModel::addFrame()
{
    beginInsertRows(QModelIndex(), m_frames.size(), m_frames.size());
    StoryboardFrame *frame = new StoryboardFrame(this);
    frame->setFrameNumber(m_frames.size() + 1);
    m_frames.append(frame);
    endInsertRows();
    emit totalFramesChanged();
    renumberFrames();
}

void StoryboardModel::insertFrame(int index)
{
    if (index < 0 || index > m_frames.size())
        index = m_frames.size();

    beginInsertRows(QModelIndex(), index, index);
    StoryboardFrame *frame = new StoryboardFrame(this);
    frame->setFrameNumber(index + 1);
    m_frames.insert(index, frame);
    endInsertRows();
    emit totalFramesChanged();
    renumberFrames();
}

void StoryboardModel::removeFrame(int index)
{
    if (index < 0 || index >= m_frames.size())
        return;

    beginRemoveRows(QModelIndex(), index, index);
    StoryboardFrame *frame = m_frames.takeAt(index);
    frame->deleteLater();
    endRemoveRows();
    emit totalFramesChanged();
    renumberFrames();

    if (m_currentFrameIndex >= m_frames.size()) {
        m_currentFrameIndex = qMax(0, m_frames.size() - 1);
        emit currentFrameIndexChanged();
    }
}

void StoryboardModel::moveFrame(int from, int to)
{
    if (from < 0 || from >= m_frames.size() || to < 0 || to >= m_frames.size())
        return;

    if (from == to) return;

    beginMoveRows(QModelIndex(), from, from, QModelIndex(), to > from ? to + 1 : to);
    m_frames.move(from, to);
    endMoveRows();
    renumberFrames();
}

void StoryboardModel::duplicateFrame(int index)
{
    if (index < 0 || index >= m_frames.size())
        return;

    StoryboardFrame *original = m_frames[index];
    StoryboardFrame *copy = new StoryboardFrame(this);
    copy->setDescription(original->description() + tr(" (Copy)"));
    copy->setPrompt(original->prompt());
    copy->setNotes(original->notes());
    copy->setImagePath(original->imagePath());

    beginInsertRows(QModelIndex(), index + 1, index + 1);
    m_frames.insert(index + 1, copy);
    endInsertRows();
    emit totalFramesChanged();
    renumberFrames();
}

void StoryboardModel::updateFrame(int index, const QString &description, const QString &prompt, const QString &notes, const QUrl &imagePath)
{
    if (index < 0 || index >= m_frames.size())
        return;

    StoryboardFrame *frame = m_frames[index];
    frame->setDescription(description);
    frame->setPrompt(prompt);
    frame->setNotes(notes);
    frame->setImagePath(imagePath);
    emit dataChanged(this->index(index), this->index(index));
}

void StoryboardModel::goToFrame(int index)
{
    if (index >= 0 && index < m_frames.size()) {
        m_currentFrameIndex = index;
        emit currentFrameIndexChanged();
    }
}

void StoryboardModel::nextFrame()
{
    goToFrame(m_currentFrameIndex + 1);
}

void StoryboardModel::previousFrame()
{
    goToFrame(m_currentFrameIndex - 1);
}

void StoryboardModel::clearFrames()
{
    beginResetModel();
    for (auto *f : m_frames)
        f->deleteLater();
    m_frames.clear();
    endResetModel();
    emit totalFramesChanged();
    m_currentFrameIndex = -1;
    emit currentFrameIndexChanged();
}

QList<StoryboardFrame*> StoryboardModel::frames() const
{
    return m_frames;
}

QJsonArray StoryboardModel::toJsonArray() const
{
    QJsonArray arr;
    for (auto *frame : m_frames) {
        arr.append(frame->toJson());
    }
    return arr;
}

void StoryboardModel::renumberFrames()
{
    for (int i = 0; i < m_frames.size(); ++i) {
        if (m_frames[i]->frameNumber() != i + 1) {
            m_frames[i]->setFrameNumber(i + 1);
            emit dataChanged(index(i), index(i), {FrameNumberRole});
        }
    }
}
