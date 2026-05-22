#ifndef STORYBOARDMODEL_H
#define STORYBOARDMODEL_H

#include <QAbstractListModel>
#include <QList>
#include "StoryboardFrame.h"
#include "Clip.h"

class StoryboardModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int totalFrames READ totalFrames NOTIFY totalFramesChanged)
    Q_PROPERTY(int currentFrameIndex READ currentFrameIndex WRITE setCurrentFrameIndex NOTIFY currentFrameIndexChanged)

public:
    enum Roles {
        FrameNumberRole = Qt::UserRole + 1,
        DescriptionRole,
        PromptRole,
        ImagePathRole,
        NotesRole
    };

    explicit StoryboardModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int totalFrames() const;
    int currentFrameIndex() const;
    void setCurrentFrameIndex(int index);

    Q_INVOKABLE void loadFrames(Clip *clip);
    Q_INVOKABLE void addFrame();
    Q_INVOKABLE void insertFrame(int index);
    Q_INVOKABLE void removeFrame(int index);
    Q_INVOKABLE void moveFrame(int from, int to);
    Q_INVOKABLE void duplicateFrame(int index);
    Q_INVOKABLE void updateFrame(int index, const QString &description, const QString &prompt, const QString &notes, const QUrl &imagePath);
    Q_INVOKABLE void goToFrame(int index);
    Q_INVOKABLE void nextFrame();
    Q_INVOKABLE void previousFrame();
    Q_INVOKABLE void clearFrames();

    QList<StoryboardFrame*> frames() const;
    QJsonArray toJsonArray() const;

signals:
    void totalFramesChanged();
    void currentFrameIndexChanged();

private:
    void renumberFrames();

    QList<StoryboardFrame*> m_frames;
    int m_currentFrameIndex = 0;
};

#endif // STORYBOARDMODEL_H
